import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  int _passwordStrength = 0;
  String? _email;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _newPasswordController.addListener(_checkStrength);
  }

  Future<void> _loadEmail() async {
    _email = await StorageService.getResetEmail();
    if (mounted) setState(() {});
  }

  void _checkStrength() {
    final password = _newPasswordController.text;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    setState(() => _passwordStrength = strength);
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0:
        return 'Enter a password';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (_email == null || _email!.isEmpty) {
      CustomSnackbar.showError(context, 'Session expired. Please try again.');
      return;
    }

    if (newPassword.isEmpty || confirm.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill all fields');
      return;
    }

    if (newPassword.length < 6) {
      CustomSnackbar.showError(
          context, 'Password must be at least 6 characters');
      return;
    }

    if (newPassword != confirm) {
      CustomSnackbar.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.resetPassword(
      email: _email!,
      newPassword: newPassword,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, response['message'] ?? 'Password reset successfully');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.login,
            (route) => false,
          );
        }
      });
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to reset password');
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                AppStrings.secureAccess,
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 32),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.resetPassword,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      AppStrings.resetPasswordSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      AppStrings.newPassword,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hint: AppStrings.enterNewPassword,
                      icon: Icons.lock_outline,
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 14),
                    _buildStrengthBar(),
                    const SizedBox(height: 8),
                    Text(
                      _strengthLabel,
                      style: TextStyle(
                        color: _passwordStrength == 0
                            ? AppColors.textLight
                            : _getStrengthColor(),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      AppStrings.confirmPassword,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: AppStrings.repeatNewPassword,
                      icon: Icons.lock_reset,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                    AppStrings.resetPasswordBtn,
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
              const Text(
                AppStrings.splashTagline,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.login,
                    (route) => false,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      AppStrings.backToLogin,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.textGrey),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textGrey,
            ),
            onPressed: onToggle,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          hintStyle: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i < _passwordStrength
                  ? _getStrengthColor()
                  : AppColors.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return Colors.blue;
      case 4:
        return AppColors.success;
      default:
        return AppColors.borderGrey;
    }
  }
}