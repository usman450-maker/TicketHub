import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/routes/route_names.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Enter your password');
      return;
    }

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, bookings, and history will be permanently deleted.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Yes, Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final token = await StorageService.getToken();
    final response = await ApiService.delete(
      url: ApiEndpoints.deleteAccount,
      token: token,
      body: {'password': _passwordController.text},
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      await StorageService.logout();
      await StorageService.clearProfileImage();

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Account deleted');
        Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.login, (route) => false);
      }
    } else {
      CustomSnackbar.showError(
          context, response['message'] ?? 'Failed to delete');
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
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.primary),
                  ),
                  const Text('Delete Account',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Warning',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          SizedBox(height: 8),
                          Text(
                            'Deleting your account will:\n'
                            '- Remove all your personal data\n'
                            '- Cancel all upcoming bookings\n'
                            '- Delete all booking history\n'
                            '- Remove all saved persons\n'
                            '- This action cannot be undone',
                            style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text('Enter your password to confirm:',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Your current password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textGrey),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),

                    // ✅ Forgot Password Link
                    const SizedBox(height: 8),
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

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Delete My Account Permanently',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
}