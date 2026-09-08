import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class PhoneOtpModal extends StatefulWidget {
  const PhoneOtpModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const PhoneOtpModal(),
      ),
    );
  }

  @override
  State<PhoneOtpModal> createState() => _PhoneOtpModalState();
}

class _PhoneOtpModalState extends State<PhoneOtpModal> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  bool _isOtpSent = false;
  String _activePhone = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    for (var n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number (e.g. +919876543210)')),
      );
      return;
    }
    _activePhone = phone;
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone));
  }

  void _verifyOtp() {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full 6-digit OTP code')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(_activePhone, otp));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSentState) {
            setState(() {
              _isOtpSent = true;
              _activePhone = state.phone;
              // Clear OTP controllers for clean real user input
              for (var c in _otpCtrls) {
                c.clear();
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Firebase OTP code sent to ${state.phone}'),
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is Authenticated) {
            Navigator.pop(context);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.discountRed),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOtpSent ? 'Verify Phone OTP' : 'Phone Number Verification',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isOtpSent
                            ? 'Enter the 6-digit code sent to $_activePhone'
                            : 'Enter your phone number to receive Firebase OTP',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isOtpSent) ...[
                CustomTextField(
                  controller: _phoneCtrl,
                  hintText: '+91 98765 43210',
                  prefixIcon: Icons.smartphone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Send Verification Code (OTP)',
                  isLoading: isLoading,
                  onPressed: _sendOtp,
                ),
              ] else ...[
                // OTP Code Inputs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 44,
                      height: 52,
                      child: TextField(
                        controller: _otpCtrls[index],
                        focusNode: _otpNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            _otpNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _otpNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Verify OTP & Sign In',
                  isLoading: isLoading,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _isOtpSent = false);
                    },
                    child: const Text(
                      'Change Phone Number',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
