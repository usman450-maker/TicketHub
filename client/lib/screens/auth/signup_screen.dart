import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/route_names.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/logo_widget.dart';
import '../../services/google_auth_service.dart';
import 'google_signup_confirm_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    final response = await GoogleAuthService.pickGoogleEmail();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoogleSignupConfirmScreen(
            email: response['email'],
            name: response['name'],
          ),
        ),
      );
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to get Google account');
    }
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill all fields');
      return;
    }

    if (!email.contains('@')) {
      CustomSnackbar.showError(context, 'Please enter a valid email');
      return;
    }

    if (phone.length < 10) {
      CustomSnackbar.showError(context, 'Please enter a valid phone number');
      return;
    }

    if (password.length < 6) {
      CustomSnackbar.showError(
          context, 'Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      CustomSnackbar.showError(context, 'Passwords do not match');
      return;
    }

    if (!_agreeTerms) {
      CustomSnackbar.showError(
          context, 'Please agree to Terms & Conditions');
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.sendSignupOtp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, response['message'] ?? 'OTP sent to your email');

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushNamed(context, RouteNames.signupOtp);
        }
      });
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to send OTP');
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
              const SizedBox(height: 6), // ✅ Reduced from 10
              const LogoWidget(size: 60), // ✅ Reduced from 80
              const SizedBox(height: 10), // ✅ Reduced from 16
              const Text(
                AppStrings.joinTicketHub,
                style: TextStyle(
                  fontSize: 22, // ✅ Reduced from 28
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4), // ✅ Reduced from 8
              const Text(
                AppStrings.signupSubtitle,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textGrey), // ✅ Reduced
              ),
              const SizedBox(height: 16), // ✅ Reduced from 24
              Container(
                padding: const EdgeInsets.all(16), // ✅ Reduced from 20
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildBoxInput(
                        controller: _nameController,
                        hint: AppStrings.fullName),
                    const SizedBox(height: 10), // ✅ Reduced from 14
                    _buildBoxInput(
                      controller: _emailController,
                      hint: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildBoxInput(
                      controller: _phoneController,
                      hint: AppStrings.phoneNumber,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildBoxInput(
                      controller: _passwordController,
                      hint: AppStrings.password,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textGrey,
                          size: 20, // ✅ Reduced
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBoxInput(
                      controller: _confirmController,
                      hint: AppStrings.confirmPassword,
                      obscure: _obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textGrey,
                          size: 20, // ✅ Reduced
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 12), // ✅ Reduced from 16
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20, // ✅ Reduced from 24
                          height: 20,
                          child: Checkbox(
                            value: _agreeTerms,
                            onChanged: (v) =>
                                setState(() => _agreeTerms = v ?? false),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12, // ✅ Reduced from 13
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14), // ✅ Reduced from 20
                    SizedBox(
                      width: double.infinity,
                      height: 46, // ✅ Reduced from 52
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
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
                                AppStrings.createAccount,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13, // ✅ Reduced from 14
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14), // ✅ Reduced from 20
                    Row(
                      children: const [
                        Expanded(child: Divider(color: AppColors.borderGrey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            AppStrings.orContinueWith,
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10, // ✅ Reduced from 11
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.borderGrey)),
                      ],
                    ),
                    const SizedBox(height: 12), // ✅ Reduced from 16
                    // ✅ Google Signup Button with Real Icon
                    GestureDetector(
                      onTap: _isLoading ? null : _handleGoogleSignup,
                      child: Container(
                        width: double.infinity,
                        height: 44, // ✅ Reduced from 50
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderGrey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ Real Google Icon (4 colors)
                       Image.network(
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
                            const SizedBox(width: 10),
                            const Text(
                              'Sign up with Google',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14, // ✅ Reduced from 15
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14), // ✅ Reduced from 20
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.haveAccount,
                    style: TextStyle(
                        color: AppColors.textDark, fontSize: 13), // ✅ Reduced
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      AppStrings.logIn,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // ✅ Reduced
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // ✅ Reduced from 20
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14), // ✅ Added smaller text
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true, // ✅ Compact
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12), // ✅ Reduced padding
          suffixIcon: suffix,
          hintStyle: const TextStyle(
              color: AppColors.textGrey, fontSize: 14), // ✅ Reduced
        ),
      ),
    );
  }
}

// ✅ Real Google Icon with 4 Colors (Custom Painter)
