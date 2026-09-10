import 'dart:async';
import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class RazorpayPaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;

  RazorpayPaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });
}

class RazorpayService {
  static const String keyId = 'rzp_test_TaFCXrgrWjxR41';

  static Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    String currency = 'INR',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/payment/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to create Razorpay order');
    }
  }

  static Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/payment/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['status'] == 'success';
    }
    return false;
  }

  static void _ensureJsLibraryLoaded() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('eval', [
        '''
        if (typeof window.openRazorpayCheckout !== 'function') {
          if (!document.getElementById('razorpay-checkout-js')) {
            var script = document.createElement('script');
            script.id = 'razorpay-checkout-js';
            script.src = 'https://checkout.razorpay.com/v1/checkout.js';
            document.head.appendChild(script);
          }
          window.openRazorpayCheckout = function(optionsJson, successCallback, failureCallback) {
            var retries = 0;
            var tryOpen = function() {
              if (typeof Razorpay === 'undefined') {
                if (retries < 50) {
                  retries++;
                  setTimeout(tryOpen, 100);
                } else {
                  if (typeof failureCallback === 'function') {
                    failureCallback('Razorpay SDK failed to load. Check network connection.');
                  }
                }
                return;
              }
              try {
                var options = typeof optionsJson === 'string' ? JSON.parse(optionsJson) : optionsJson;
                options.handler = function(response) {
                  if (typeof successCallback === 'function') {
                    successCallback(
                      response.razorpay_payment_id || '',
                      response.razorpay_order_id || '',
                      response.razorpay_signature || ''
                    );
                  }
                };
                var rzp = new Razorpay(options);
                rzp.on('payment.failed', function(response) {
                  var msg = (response && response.error && response.error.description) ? response.error.description : 'Payment Failed';
                  if (typeof failureCallback === 'function') {
                    failureCallback(msg);
                  }
                });
                rzp.open();
              } catch (err) {
                if (typeof failureCallback === 'function') {
                  failureCallback(err.message || 'Failed to open Razorpay modal');
                }
              }
            };
            tryOpen();
          };
        }
        '''
      ]);
    } catch (_) {}
  }

  static Future<RazorpayPaymentResult> openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String phone,
    String? keyIdOverride,
    String? selectedMethod,
    String description = 'FUNFILLERS Order Payment',
  }) async {
    if (!kIsWeb) {
      return RazorpayPaymentResult(
        isSuccess: false,
        errorMessage: 'Razorpay Standard Web Checkout is configured for Web.',
      );
    }

    _ensureJsLibraryLoaded();

    final int amountInPaise = (amount * 100).round();

    final Map<String, dynamic> prefill = {
      'name': name,
      'email': email,
      'contact': phone,
    };

    final activeKeyId = (keyIdOverride != null && keyIdOverride.isNotEmpty)
        ? keyIdOverride
        : keyId;

    final Map<String, dynamic> options = {
      'key': activeKeyId,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'FUNFILLERS',
      'description': description,
      'order_id': orderId,
      'prefill': prefill,
      'theme': {
        'color': '#161F33',
      },
    };

    if (selectedMethod == 'upi') {
      prefill['method'] = 'upi';
      options['config'] = {
        'display': {
          'blocks': {
            'upi': {
              'name': 'Pay via UPI (Google Pay / PhonePe / Paytm)',
              'instruments': [
                {'method': 'upi'}
              ]
            }
          },
          'sequence': ['block.upi']
        }
      };
    } else if (selectedMethod == 'card') {
      prefill['method'] = 'card';
      options['config'] = {
        'display': {
          'blocks': {
            'card': {
              'name': 'Credit / Debit Card',
              'instruments': [
                {'method': 'card'}
              ]
            }
          },
          'sequence': ['block.card']
        }
      };
    } else if (selectedMethod == 'wallet') {
      prefill['method'] = 'netbanking';
      options['config'] = {
        'display': {
          'blocks': {
            'netbanking': {
              'name': 'Net Banking & Wallets',
              'instruments': [
                {'method': 'netbanking'},
                {'method': 'wallet'}
              ]
            }
          },
          'sequence': ['block.netbanking']
        }
      };
    }

    final completer = Completer<RazorpayPaymentResult>();

    void onSuccess(dynamic pId, dynamic oId, dynamic sig) async {
      try {
        final paymentId = pId?.toString() ?? '';
        final razorpayOrderId = oId?.toString() ?? orderId;
        final signature = sig?.toString() ?? '';

        final isVerified = await verifyPayment(
          orderId: razorpayOrderId,
          paymentId: paymentId,
          signature: signature,
        );

        if (isVerified) {
          completer.complete(RazorpayPaymentResult(
            isSuccess: true,
            paymentId: paymentId,
            orderId: razorpayOrderId,
            signature: signature,
          ));
        } else {
          completer.complete(RazorpayPaymentResult(
            isSuccess: false,
            errorMessage: 'Payment signature verification failed. Please try again.',
          ));
        }
      } catch (e) {
        completer.complete(RazorpayPaymentResult(
          isSuccess: false,
          errorMessage: 'Verification error: $e',
        ));
      }
    }

    void onFailure(dynamic errorMsg) {
      completer.complete(RazorpayPaymentResult(
        isSuccess: false,
        errorMessage: errorMsg?.toString() ?? 'Payment was cancelled or failed.',
      ));
    }

    try {
      js.context.callMethod('openRazorpayCheckout', [
        jsonEncode(options),
        onSuccess,
        onFailure,
      ]);
    } catch (e) {
      completer.complete(RazorpayPaymentResult(
        isSuccess: false,
        errorMessage: 'Failed to launch Razorpay Modal: $e',
      ));
    }

    return completer.future;
  }
}
