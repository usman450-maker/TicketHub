import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/logo_widget.dart';
import '../../services/google_auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final response = await GoogleAuthService.googleLogin();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(context, 'Login Successful');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          );
        }
      });
    } else {
      if (response['message']?.contains('No account found') == true) {
        _showNoAccountDialog();
      } else {
        CustomSnackbar.showError(
            context, response['message'] ?? 'Login failed');
      }
    }
  }

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 10),
            Text('No Account'),
          ],
        ),
        content: const Text(
          'No account found with this email. Please sign up first.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.signup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child:
                const Text('Sign Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill all fields');
      return;
    }

    if (!email.contains('@')) {
      CustomSnackbar.showError(context, 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, response['message'] ?? 'Login Successful');
      Future.delayed(const Duration(milliseconds: 500), () {
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
          context, response['message'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16), // ✅ Reduced from 20
          child: Column(
            children: [
              const SizedBox(height: 10), // ✅ Reduced from 20
              Container(
                padding: const EdgeInsets.all(20), // ✅ Reduced from 24
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const LogoWidget(),
                    const SizedBox(height: 16), // ✅ Reduced from 24
                    const Text(
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        fontSize: 24, // ✅ Reduced from 28
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6), // ✅ Reduced from 10
                    const Text(
                      AppStrings.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14, // ✅ Reduced from 16
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20), // ✅ Reduced from 32
                    _buildLabel(AppStrings.email),
                    const SizedBox(height: 6), // ✅ Reduced from 8
                    _buildUnderlineInput(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: 'name@example.com',
                    ),
                    const SizedBox(height: 16), // ✅ Reduced from 24
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(AppStrings.password),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RouteNames.forgotPassword);
                          },
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13, // ✅ Reduced from 14
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // ✅ Reduced from 8
                    _buildUnderlineInput(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: '••••••••',
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textGrey,
                          size: 20, // ✅ Added smaller icon
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 20), // ✅ Reduced from 30
                    SizedBox(
                      width: double.infinity,
                      height: 48, // ✅ Reduced from 54
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20, // ✅ Reduced from 24
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                AppStrings.login,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // ✅ Reduced from 15
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16), // ✅ Reduced from 24
                    _buildDividerWithText(AppStrings.orContinueWith),
                    const SizedBox(height: 14), // ✅ Reduced from 20
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleGoogleLogin,
                            child: _buildSocialButton(
                              label: 'Google',
                              // ✅ Real Google icon with 4 colors
                             iconWidget: Image.network(
  'https://developers.google.com/identity/images/g-logo.png',
  width: 18,
  height: 18,
  errorBuilder: (context, error, stackTrace) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  },
),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // ✅ Reduced from 12
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Apple',
                            iconWidget: const Icon(
                              Icons.apple,
                              size: 20, // ✅ Reduced from 22
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // ✅ Reduced from 24
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.noAccount,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13, // ✅ Added smaller
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.signup);
                          },
                          child: const Text(
                            AppStrings.signUp,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13, // ✅ Added smaller
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // ✅ Reduced from 40
              const Text(
                AppStrings.splashTagline,
                style: TextStyle(
                  fontSize: 10, // ✅ Reduced from 11
                  color: AppColors.textGrey,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10), // ✅ Reduced from 20
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14, // ✅ Reduced from 15
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildUnderlineInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType:
            obscure ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14), // ✅ Added smaller text
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20), // ✅ Smaller
          suffixIcon: suffix,
          isDense: true, // ✅ Compact
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12), // ✅ Reduced padding
          hintStyle: const TextStyle(
              color: AppColors.textGrey, fontSize: 14), // ✅ Reduced
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderGrey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 10, // ✅ Reduced from 11
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderGrey)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
  }) {
    return Container(
      height: 44, // ✅ Reduced from 50
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14, // ✅ Reduced from 15
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

