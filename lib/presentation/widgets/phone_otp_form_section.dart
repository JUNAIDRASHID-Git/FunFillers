import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class PhoneOtpFormSection extends StatefulWidget {
  final String buttonText;
  const PhoneOtpFormSection({
    super.key,
    this.buttonText = 'Send Verification Code (OTP)',
  });

  @override
  State<PhoneOtpFormSection> createState() => _PhoneOtpFormSectionState();
}

class _PhoneOtpFormSectionState extends State<PhoneOtpFormSection> {
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
        const SnackBar(content: Text('Please enter a valid mobile number with country code (+91)')),
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSentState) {
          setState(() {
            _isOtpSent = true;
            _activePhone = state.phone;
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
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_isOtpSent
              ? Column(
                  key: const ValueKey('phone_input_mode'),
                  children: [
                    CustomTextField(
                      controller: _phoneCtrl,
                      hintText: '+91 Mobile Number (e.g. +919876543210)',
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: widget.buttonText,
                      isLoading: isLoading,
                      onPressed: _sendOtp,
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('otp_input_mode'),
                  children: [
                    Text(
                      'Enter 6-digit OTP code sent to $_activePhone',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                              fillColor: AppColors.inputBackground,
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
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Verify OTP & Sign In',
                      isLoading: isLoading,
                      onPressed: _verifyOtp,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                        });
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
                  ],
                ),
        );
      },
    );
  }
}
