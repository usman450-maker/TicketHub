import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 57;
  bool _isLoading = false;
  bool _isResending = false;
  String? _email;

  @override
  void initState() {
    super.initState();
     for (var controller in _controllers) {
    controller.addListener(() {
      setState(() {});
    });
  }
  for (var focusNode in _focusNodes) {
    focusNode.addListener(() {
      setState(() {});
    });
  }
    _loadEmail();
    _startTimer();
  }

  Future<void> _loadEmail() async {
    _email = await StorageService.getResetEmail();
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  String get _maskedEmail {
    if (_email == null || _email!.isEmpty) return '';
    final parts = _email!.split('@');
    if (parts.length != 2) return _email!;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  Future<void> _resendOtp() async {
    if (_email == null || _email!.isEmpty) {
      CustomSnackbar.showError(context, 'Email not found. Go back and try again.');
      return;
    }

    setState(() => _isResending = true);

    final response = await AuthService.resendOtp(email: _email!);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, response['message'] ?? 'OTP resent successfully');
      // Clear all fields
      for (var c in _controllers) {
        c.clear();
      }
      setState(() => _secondsRemaining = 57);
      _startTimer();
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to resend OTP');
    }
  }

  Future<void> _verify() async {
    if (_email == null || _email!.isEmpty) {
      CustomSnackbar.showError(context, 'Email not found. Go back and try again.');
      return;
    }

    if (_otpCode.length != 6) {
      CustomSnackbar.showError(context, 'Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.verifyOtp(
      email: _email!,
      otp: _otpCode,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, response['message'] ?? 'OTP verified successfully');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, RouteNames.resetPassword);
        }
      });
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Invalid OTP');
    }
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.securityCheck,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: '${AppStrings.otpSubtitle}\nto '),
                    TextSpan(
                      text: _maskedEmail,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return _buildOtpBox(index);
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: Color(0xFFB8860B),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: (_secondsRemaining == 0 && !_isResending)
                          ? _resendOtp
                          : null,
                      child: _isResending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppStrings.resendOtp,
                              style: TextStyle(
                                color: _secondsRemaining == 0
                                    ? AppColors.primary
                                    : AppColors.textGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    AppStrings.verify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.didntReceive,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      AppStrings.contactSupport,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildOtpBox(int index) {
  final bool hasValue = _controllers[index].text.isNotEmpty;
  final bool isFocused = _focusNodes[index].hasFocus;

  Color borderColor;
  Color backgroundColor;
  double borderWidth;

  if (hasValue) {
    borderColor = AppColors.primary;
    backgroundColor = AppColors.primary.withValues(alpha: 0.08);
    borderWidth = 2;
  } else if (isFocused) {
    borderColor = AppColors.primary;
    backgroundColor = Colors.white;
    borderWidth = 2;
  } else {
    borderColor = AppColors.borderGrey;
    backgroundColor = Colors.white;
    borderWidth = 1.5;
  }

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 48,
    height: 58,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: hasValue || isFocused
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
    ),
    child: TextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: hasValue ? AppColors.primary : AppColors.textDark,
      ),
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (value) {
        if (value.isNotEmpty && index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else if (value.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
        setState(() {});
      },
    ),
  );
}
}