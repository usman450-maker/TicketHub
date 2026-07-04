import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../services/google_auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_snackbar.dart';

class GoogleDeviceWaitingScreen extends StatefulWidget {
  const GoogleDeviceWaitingScreen({super.key});

  @override
  State<GoogleDeviceWaitingScreen> createState() =>
      _GoogleDeviceWaitingScreenState();
}

class _GoogleDeviceWaitingScreenState extends State<GoogleDeviceWaitingScreen> {
  Timer? _pollTimer;
  String? _email;
  String? _name;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
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

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_email == null || _isChecking) return;

    _isChecking = true;
    final response =
        await GoogleAuthService.checkDeviceStatus(email: _email!);
    _isChecking = false;

    if (!mounted) return;

    final status = response['status'];

    if (status == 'allowed') {
      _pollTimer?.cancel();
      CustomSnackbar.showSuccess(
          context, 'Device authorized! Enter OTP to complete.');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacementNamed(
              context, RouteNames.googleSignupOtp);
        }
      });
    } else if (status == 'denied') {
      _pollTimer?.cancel();
      _showDeniedDialog();
    } else if (status == 'expired') {
      _pollTimer?.cancel();
      CustomSnackbar.showError(
          context, 'Authorization expired. Please try again.');
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.signup,
            (route) => false,
          );
        }
      });
    }
  }

  // Show confirmation dialog before canceling
  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.help_outline,
                color: AppColors.primary, size: 26),
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
      _pollTimer?.cancel();
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

  void _showDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.block, color: AppColors.error, size: 28),
            SizedBox(width: 10),
            Text('Signup Blocked'),
          ],
        ),
        content: const Text(
          'You have blocked the sign-up attempt. Your account was not created.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.clearPendingSignup();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle Android back button
      onWillPop: () async {
        await _handleCancel();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Waiting for Authorization',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Instructions
                const Text(
                  'We sent an authorization email to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Steps
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStep(1, 'Open your email inbox', true),
                      _buildStep(2, 'Find email from TicketHub', true),
                      _buildStep(3, 'Click "ALLOW" to authorize', false),
                      _buildStep(4, 'Return here for verification', false),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  '🔄 Checking status every 3 seconds...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),

                // Cancel Signup Button - Theme colored (outlined)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.borderGrey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: done ? Colors.white : AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: done ? AppColors.textDark : AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}