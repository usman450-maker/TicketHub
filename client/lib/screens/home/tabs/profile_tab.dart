import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../notifications/notifications_screen.dart';
import '../../profile/personal_info_screen.dart';
import '../../profile/help_center_screen.dart';
import '../../profile/delete_account_screen.dart';
import '../../profile/about_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? _user;
  bool _pushNotifications = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    final imagePath = await StorageService.getProfileImage();
    if (mounted) {
      setState(() {
        _user = user;
        _profileImagePath = imagePath;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (picked != null) {
      await StorageService.saveProfileImage(picked.path);
      if (mounted) {
        setState(() => _profileImagePath = picked.path);
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              await StorageService.clearProfileImage();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _buildSmallAvatar(),
                  const SizedBox(width: 10),
                  const Text('TicketHub',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const NotificationsScreen())),
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile pic with edit
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3),
                    ),
                    child: ClipOval(
                      child: _profileImagePath != null &&
                              File(_profileImagePath!).existsSync()
                          ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.3),
                              child: const Icon(Icons.person,
                                  size: 50,
                                  color: AppColors.primary),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              _user?['name'] ?? 'User',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _user?['email'] ?? '',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 30),

            // ACCOUNT
            _sectionTitle('ACCOUNT'),
            _menuItem(
                Icons.person_outline, 'Personal Information', () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const PersonalInfoScreen()));
              _loadUser();
            }),
            const SizedBox(height: 20),

            // PREFERENCES
            _sectionTitle('PREFERENCES'),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined,
                      color: AppColors.textDark, size: 22),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Push Notifications',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  Switch(
                    value: _pushNotifications,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) =>
                        setState(() => _pushNotifications = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SUPPORT
            _sectionTitle('SUPPORT'),
            _menuItem(Icons.help_outline, 'Help Center', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HelpCenterScreen()));
            }),
            _menuItem(Icons.info_outline, 'About TicketHub', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AboutScreen()));
            }),
            const SizedBox(height: 20),

            // ✅ DANGER ZONE - No more red
            _sectionTitle('DANGER ZONE'),
            _menuItem(Icons.delete_outline, 'Delete Account', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const DeleteAccountScreen()));
            }),
            const SizedBox(height: 30),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout,
                      color: Colors.white, size: 20),
                  label: const Text('Log Out',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: ClipOval(
        child: _profileImagePath != null &&
                File(_profileImagePath!).existsSync()
            ? Image.file(File(_profileImagePath!),
                fit: BoxFit.cover)
            : const Icon(Icons.person,
                color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.5)),
      ),
    );
  }

  // ✅ Removed isDestructive parameter completely
  Widget _menuItem(IconData icon, String label, VoidCallback onTap,
      {String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textGrey, size: 20),
          ],
        ),
      ),
    );
  }
}