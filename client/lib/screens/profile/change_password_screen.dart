import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/routes/route_names.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../services/notification_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

Future<void> _changePassword() async {
  if (_currentController.text.isEmpty ||
      _newController.text.isEmpty ||
      _confirmController.text.isEmpty) {
    CustomSnackbar.showError(context, 'Fill all fields');
    return;
  }

  if (_newController.text.length < 6) {
    CustomSnackbar.showError(
        context, 'New password must be 6+ characters');
    return;
  }

  if (_newController.text != _confirmController.text) {
    CustomSnackbar.showError(context, 'Passwords do not match');
    return;
  }

  setState(() => _isLoading = true);

  final token = await StorageService.getToken();
  final response = await ApiService.put(
    url: ApiEndpoints.changePassword,
    token: token,
    body: {
      'currentPassword': _currentController.text,
      'newPassword': _newController.text,
    },
  );

  if (!mounted) return;
  setState(() => _isLoading = false);

  if (response['success'] == true) {
    // ✅ Local notification show karo
    await NotificationService.showLocalNotification(
      title: '🔒 Password Changed!',
      message: 'Your password has been changed successfully.',
      type: 'security',
    );

    CustomSnackbar.showSuccess(context, 'Password changed!');
    Navigator.pop(context);
  } else {
    CustomSnackbar.showError(
        context, response['message'] ?? 'Failed');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const Text('Change Password',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _passwordField(
                        'Current Password',
                        _currentController,
                        _obscureCurrent,
                        () => setState(
                            () => _obscureCurrent = !_obscureCurrent)),
                    const SizedBox(height: 8),

                    // ✅ Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, RouteNames.forgotPassword);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    _passwordField(
                        'New Password',
                        _newController,
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew)),
                    const SizedBox(height: 14),
                    _passwordField(
                        'Confirm Password',
                        _confirmController,
                        _obscureConfirm,
                        () => setState(
                            () => _obscureConfirm = !_obscureConfirm)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Change Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textGrey),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
      ),
    );
  }
}