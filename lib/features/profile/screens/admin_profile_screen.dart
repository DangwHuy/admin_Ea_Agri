import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/custom_admin_input.dart';
import '../../auth/logic/user_provider.dart';
import '../../settings/presentation/widgets/common/config_card.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _emailController = TextEditingController(); // read-only

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isUploadingAvatar = false;
  bool _isChangingPassword = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = context.read<UserProvider>();
    _nameController.text = userProvider.displayName ?? '';
    _phoneController.text = userProvider.phoneNumber ?? '';
    _emailController.text = userProvider.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSavingProfile = true);
    
    try {
      await context.read<UserProvider>().updateAdminProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      _showSnackBar('Profile updated successfully');
    } catch (e) {
      _showSnackBar('Error updating profile: $e', isError: true);
    } finally {
      setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final user = context.read<UserProvider>();
      
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploadingAvatar = true);

      final Uint8List imageBytes = await image.readAsBytes();
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/admins/admin_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await user.updateAdminProfile(photoURL: downloadUrl);
      
      _showSnackBar('Avatar updated successfully');
    } catch (e) {
      _showSnackBar('Error uploading avatar: $e', isError: true);
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill all password fields', isError: true);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('New passwords do not match', isError: true);
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      _showSnackBar('Password changed successfully');
    } catch (e) {
      _showSnackBar('Error changing password: ${e.toString().split(']').last.trim()}', isError: true);
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tài khoản của tôi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý thông tin hồ sơ và cài đặt bảo mật của bạn.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Profile Info & Avatar
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ConfigCard(
                        title: 'Thông tin cá nhân',
                        subtitle: 'Cập nhật ảnh đại diện và thông tin của bạn.',
                        children: [
                          Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey[200],
                                        shape: BoxShape.circle,
                                        image: userProvider.photoURL != null
                                            ? DecorationImage(
                                                image: NetworkImage(userProvider.photoURL!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: userProvider.photoURL == null
                                          ? Icon(Icons.person, size: 40, color: Theme.of(context).textTheme.bodySmall?.color)
                                          : null,
                                    ),
                                    if (_isUploadingAvatar)
                                      Positioned.fill(
                                        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: _isUploadingAvatar ? null : _uploadAvatar,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              CustomAdminInput(
                                label: 'Địa chỉ Email',
                                hintText: 'admin@domain.com',
                                prefixIcon: Icons.email_outlined,
                                initialValue: _emailController.text,
                                // Email is disabled for change through basic UI without extensive reauth setup usually
                                // Using CustomAdminInput requires an onChanged or we use a separate widget if disabled.
                                // We'll just pass onChanged arbitrarily but not save it. 
                                // To make it read-only, we should ideally use standard TextFormField or just show it as text
                              ),
                              const SizedBox(height: 16),
                              CustomAdminInput(
                                label: 'Tên hiển thị',
                                hintText: 'Nhập tên đầy đủ của bạn',
                                prefixIcon: Icons.badge_outlined,
                                initialValue: _nameController.text,
                                onChanged: (val) => _nameController.text = val,
                              ),
                              const SizedBox(height: 16),
                              CustomAdminInput(
                                label: 'Số điện thoại',
                                hintText: 'Nhập số điện thoại của bạn',
                                prefixIcon: Icons.phone_outlined,
                                initialValue: _phoneController.text,
                                onChanged: (val) => _phoneController.text = val,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isSavingProfile ? null : _updateProfile,
                                    icon: _isSavingProfile 
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Icon(Icons.save, size: 18),
                                    label: Text(
                                      _isSavingProfile ? 'Đang lưu...' : 'Lưu Thông Tin',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ], // Close children array
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),

                // Right Column: Security (Password)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      ConfigCard(
                        title: 'Bảo mật',
                        subtitle: 'Thay đổi mật khẩu của bạn.',
                        children: [
                          Form(
                          key: _passwordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomAdminInput(
                                label: 'Mật khẩu hiện tại',
                                hintText: 'Nhập mật khẩu hiện tại',
                                prefixIcon: Icons.lock_outline,
                                onChanged: (val) => _currentPasswordController.text = val,
                              ),
                              const SizedBox(height: 16),
                              CustomAdminInput(
                                label: 'Mật khẩu mới',
                                hintText: 'Nhập mật khẩu mới',
                                prefixIcon: Icons.lock_reset,
                                onChanged: (val) => _newPasswordController.text = val,
                              ),
                              const SizedBox(height: 16),
                              CustomAdminInput(
                                label: 'Xác nhận mật khẩu mới',
                                hintText: 'Xác nhận lại mật khẩu mới',
                                prefixIcon: Icons.done_all,
                                onChanged: (val) => _confirmPasswordController.text = val,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isChangingPassword ? null : _changePassword,
                                  icon: _isChangingPassword 
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.security, size: 18),
                                  label: Text(
                                    _isChangingPassword ? 'Đang cập nhật...' : 'Cập nhật Mật khẩu',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFF3F4F6),
                                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                                    side: BorderSide(color: Theme.of(context).dividerColor),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ), // Closes Form
                        ], // Closes children
                      ), // Closes ConfigCard
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
