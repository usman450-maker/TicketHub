import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../core/network/api_endpoints.dart';
import '../../widgets/custom_snackbar.dart';
import 'change_password_screen.dart';
import '../../services/notification_service.dart'; 

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
      });
    }
  }

Future<void> _saveProfile() async {
  if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
    CustomSnackbar.showError(context, 'Name and email required');
    return;
  }

  setState(() => _isLoading = true);

  final token = await StorageService.getToken();
  final response = await ApiService.put(
    url: ApiEndpoints.updateProfile,
    token: token,
    body: {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    },
  );

  if (!mounted) return;
  setState(() => _isLoading = false);

  if (response['success'] == true) {
    await StorageService.saveUser({
      'id': (await StorageService.getUser())?['id'],
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });

    // ✅ Local notification show karo
    await NotificationService.showLocalNotification(
      title: '✅ Profile Updated!',
      message: 'Your profile information has been updated successfully.',
      type: 'account',
    );

    setState(() => _isEditing = false);
    CustomSnackbar.showSuccess(context, 'Profile updated!');
  } else {
    CustomSnackbar.showError(
        context, response['message'] ?? 'Update failed');
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
                  const Text('Personal Information',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const Spacer(),
                  if (!_isEditing)
                    TextButton(
                      onPressed: () => setState(() => _isEditing = true),
                      child: const Text('Edit',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Full Name', _nameController, Icons.person_outline),
                    const SizedBox(height: 14),
                    _buildField('Email Address', _emailController, Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildField('Phone Number', _phoneController, Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 30),

                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save Changes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Change Password Link
                    _menuItem(Icons.lock_outline, 'Change Password', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen()));
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: _isEditing ? AppColors.primary : AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}