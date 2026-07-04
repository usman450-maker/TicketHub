import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../services/google_auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class GoogleSignupOtpScreen extends StatefulWidget {
  const GoogleSignupOtpScreen({super.key});

  @override
  State<GoogleSignupOtpScreen> createState() => _GoogleSignupOtpScreenState();
}

class _GoogleSignupOtpScreenState extends State<GoogleSignupOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isExpired = false;
  String? _email;
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();

    // Add listeners to rebuild UI when text changes (for border color)
    for (var controller in _controllers) {
      controller.addListener(() {
        setState(() {});
      });
    }

    // Add focus listeners
    for (var focusNode in _focusNodes) {
      focusNode.addListener(() {
        setState(() {});
      });
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: AppColors.primary, size: 26),
            SizedBox(width: 10),
            Text(
              'Cancel Signup?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel the signup process? You will need to start over.',
          style: TextStyle(
            height: 1.5,
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No, Continue',
              style: TextStyle(
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _timer?.cancel();
      await StorageService.clearPendingSignup();
      await GoogleAuthService.signOut();

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Signup cancelled');
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.signup,
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadData() async {
    final data = await StorageService.getPendingSignup();
    if (mounted && data != null) {
      setState(() {
        _email = data['email'];
        _name = data['name'];
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _isExpired = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isExpired = true);
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _resendOtp() async {
    if (_email == null || _name == null) {
      CustomSnackbar.showError(context, 'Session expired');
      return;
    }

    setState(() => _isResending = true);

    final response = await GoogleAuthService.resendGoogleSignupOtp(
      email: _email!,
      name: _name!,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    if (response['success'] == true) {
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _startTimer();
      CustomSnackbar.showSuccess(context, 'New OTP sent to your email!');
    } else {
      CustomSnackbar.showError(
        context,
        response['message'] ?? 'Failed to resend OTP',
      );
    }
  }

  Future<void> _verify() async {
    if (_isExpired) {
      CustomSnackbar.showError(
        context,
        'OTP expired. Please click "Resend OTP".',
      );
      return;
    }

    if (_otpCode.length != 6) {
      CustomSnackbar.showError(context, 'Please enter complete OTP');
      return;
    }

    if (_email == null || _name == null) {
      CustomSnackbar.showError(context, 'Session expired');
      return;
    }

    setState(() => _isLoading = true);

    final response = await GoogleAuthService.verifyOtpAndCreateAccount(
      name: _name!,
      email: _email!,
      otp: _otpCode,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      await StorageService.clearPendingSignup();
      CustomSnackbar.showSuccess(context, 'Account created successfully!');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          );
        }
      });
    } else {
      CustomSnackbar.showError(
        context,
        response['message'] ?? 'Verification failed',
      );
    }
  }

  String get _formattedTime {
    final min = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final sec = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$min:$sec';
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
    return WillPopScope(
      onWillPop: () async {
        await _handleCancel();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: AppColors.success,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Device authorized! Enter the 6-digit code sent to:\n$_email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Card
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

                      // Timer or Expired message
                      if (_isExpired)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.timer_off,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'OTP Expired',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _secondsRemaining <= 10
                                ? AppColors.error.withValues(alpha: 0.1)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: _secondsRemaining <= 10
                                    ? AppColors.error
                                    : const Color(0xFFB8860B),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formattedTime,
                                style: TextStyle(
                                  color: _secondsRemaining <= 10
                                      ? AppColors.error
                                      : const Color(0xFFB8860B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Resend OTP button
                      GestureDetector(
                        onTap: (_isExpired && !_isResending)
                            ? _resendOtp
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isExpired
                                  ? AppColors.primary
                                  : AppColors.borderGrey,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: _isExpired
                                          ? AppColors.primary
                                          : AppColors.textGrey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: _isExpired
                                            ? AppColors.primary
                                            : AppColors.textGrey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isExpired)
                              ? null
                              : _verify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'VERIFY & CREATE ACCOUNT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Cancel Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleCancel,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Cancel Signup',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================
  // BEAUTIFUL OTP BOX
  // ==========================
  Widget _buildOtpBox(int index) {
    final bool hasValue = _controllers[index].text.isNotEmpty;
    final bool isFocused = _focusNodes[index].hasFocus;

    // Determine colors based on state
    Color borderColor;
    Color backgroundColor;
    double borderWidth;

    if (_isExpired) {
      borderColor = AppColors.error;
      backgroundColor = AppColors.error.withValues(alpha: 0.05);
      borderWidth = 1.5;
    } else if (hasValue) {
      // Filled state — Green theme
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primary.withValues(alpha: 0.08);
      borderWidth = 2;
    } else if (isFocused) {
      // Focused state — Green highlight
      borderColor = AppColors.primary;
      backgroundColor = Colors.white;
      borderWidth = 2;
    } else {
      // Empty state — Light border
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
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
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
        enabled: !_isExpired,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _isExpired
              ? AppColors.error
              : hasValue
                  ? AppColors.primary
                  : AppColors.textDark,
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