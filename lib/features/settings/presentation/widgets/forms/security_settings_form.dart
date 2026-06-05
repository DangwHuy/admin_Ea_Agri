import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_input.dart';

class SecuritySettingsForm extends StatelessWidget {
  const SecuritySettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.security;

    if (config == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Access Policy
        ConfigCard(
          title: 'Chính sách truy cập',
          icon: Icons.lock_person_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomAdminInput(
                    label: 'Số lần đăng nhập sai tối đa',
                    initialValue: config.maxLoginAttempts.toString(),
                    helperText: 'Khóa tạm thời nếu vượt quá số lần này.',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 5;
                      provider.updateSecurity(config.copyWith(maxLoginAttempts: parsed));
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: CustomAdminInput(
                    label: 'Thời gian khóa (Phút)',
                    initialValue: config.lockoutDurationMinutes.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 15;
                      provider.updateSecurity(config.copyWith(lockoutDurationMinutes: parsed));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: Text('Bắt buộc xác thực 2 lớp (2FA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Áp dụng cho tất cả tài khoản quản trị viên và chuyên gia.', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                value: config.forceTwoFactorAuth,
                onChanged: (val) {
                  provider.updateSecurity(config.copyWith(forceTwoFactorAuth: val));
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Emergency Actions
        ConfigCard(
          title: 'Hành động khẩn cấp',
          icon: Icons.emergency_share_rounded,
          subtitle: 'Các thao tác ảnh hưởng đến tất cả người dùng.',
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Buộc đăng xuất toàn hệ thống',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thao tác này sẽ yêu cầu TẤT CẢ người dùng phải xác thực lại. Chỉ sử dụng trong sự cố bảo mật nghiêm trọng.',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showForceLogoutDialog(context, provider),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Buộc đăng xuất tất cả thiết bị'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (config.globalForceLogoutTimestamp != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Lần thực hiện cuối: ${DateFormat('HH:mm dd/MM/yyyy').format(config.globalForceLogoutTimestamp!)}',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // 4. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveSecurity(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  void _showForceLogoutDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận lệnh tối cao?'),
        content: const Text(
          'Hệ thống sẽ ngay lập tức vô hiệu hóa mọi phiên đăng nhập hiện hữu. Quản trị viên cũng sẽ phải đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.triggerGlobalForceLogout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Lệnh đăng xuất toàn cầu đã được phát đi!' : 'Không thể thực hiện lệnh.'),
                    backgroundColor: success ? AppColors.primary : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
