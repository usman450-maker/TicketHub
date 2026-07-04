import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../services/google_auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class GoogleSignupConfirmScreen extends StatefulWidget {
  final String email;
  final String name;

  const GoogleSignupConfirmScreen({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<GoogleSignupConfirmScreen> createState() =>
      _GoogleSignupConfirmScreenState();
}

class _GoogleSignupConfirmScreenState extends State<GoogleSignupConfirmScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSend() async {
    final typedEmail = _emailController.text.trim().toLowerCase();

    if (typedEmail.isEmpty) {
      CustomSnackbar.showError(context, 'Please type your email');
      return;
    }

    if (typedEmail != widget.email.toLowerCase()) {
      CustomSnackbar.showError(
          context, 'Email does not match your selected Google account');
      return;
    }

    setState(() => _isLoading = true);

    // Save pending signup data
    await StorageService.savePendingSignup({
      'name': widget.name,
      'email': widget.email,
      'phone': '',
      'password': '',
      'isGoogle': true,
    });

    final response = await GoogleAuthService.sendDeviceAuthorization(
      email: widget.email,
      name: widget.name,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
          context, 'Authorization email sent! Check your inbox.');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushNamed(context, RouteNames.googleDeviceWaiting);
        }
      });
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to send email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Confirm Your Email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Please re-type your email to confirm you\'re the account owner.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Selected email display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Google Account:',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type your email to confirm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.textGrey,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline,
                        color: Color(0xFF92400E), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We\'ll send an authorization email. You must click "Allow" from that email to continue.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmAndSend,
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
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'SEND AUTHORIZATION EMAIL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}