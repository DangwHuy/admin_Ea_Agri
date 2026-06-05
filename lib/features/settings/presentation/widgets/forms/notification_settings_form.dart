import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class NotificationSettingsForm extends StatelessWidget {
  const NotificationSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.notification;

    if (config == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Kênh thông báo (General)
        ConfigCard(
          title: 'Kênh thông báo',
          subtitle: 'Cấu hình các phương thức gửi thông báo chính',
          icon: Icons.hub_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Thông báo qua Email',
              subtitle: 'Gửi báo cáo và thông tin đơn hàng qua email',
              value: config.enableEmailNotifications,
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(enableEmailNotifications: val)),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Thông báo qua SMS',
              subtitle: 'Gửi mã OTP và thông báo khẩn cấp qua tin nhắn',
              value: config.enableSMSNotifications,
              icon: Icons.sms_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(enableSMSNotifications: val)),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Thông báo Push',
              subtitle: 'Gửi thông báo trực tiếp đến ứng dụng di động',
              value: config.enablePushNotifications,
              icon: Icons.notifications_active_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(enablePushNotifications: val)),
            ),
          ],
        ),

        // 2. Thị trường & Tài chính (Market & Finance)
        ConfigCard(
          title: 'Thị trường & Tài chính',
          subtitle: 'Quy tắc cho các sự kiện giao dịch và biến động kho',
          icon: Icons.account_balance_wallet_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Đơn hàng mới',
              subtitle: 'Thông báo khi có khách hàng đặt hàng mới',
              value: config.triggerRules.notifyOnNewOrder,
              icon: Icons.shopping_cart_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnNewOrder: val),
              )),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Sắp hết hàng',
              subtitle: 'Thông báo khi sản phẩm trong kho xuống dưới mức tối thiểu',
              value: config.triggerRules.notifyOnLowStock,
              icon: Icons.inventory_2_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnLowStock: val),
              )),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Yêu cầu rút tiền',
              subtitle: 'Thông báo khi đại lý hoặc chuyên gia yêu cầu rút tiền',
              value: config.triggerRules.notifyOnNewWithdrawal,
              icon: Icons.payments_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnNewWithdrawal: val),
              )),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Biến động giá',
              subtitle: 'Cảnh báo khi giá thị trường thay đổi đột ngột (>15%)',
              value: config.triggerRules.notifyOnPriceSpike,
              icon: Icons.trending_up_rounded,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnPriceSpike: val),
              )),
            ),
          ],
        ),

        // 3. Chuyên gia & Cộng đồng (Expert & Community)
        ConfigCard(
          title: 'Chuyên gia & Cộng đồng',
          subtitle: 'Quản lý tương tác và định danh người dùng',
          icon: Icons.people_alt_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Xác thực chuyên gia',
              subtitle: 'Cảnh báo khi có hồ sơ chuyên gia mới cần duyệt',
              value: config.triggerRules.notifyOnExpertVerification,
              icon: Icons.verified_user_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnExpertVerification: val),
              )),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Báo cáo người dùng',
              subtitle: 'Thông báo khi có nội dung bị báo cáo vi phạm',
              value: config.triggerRules.notifyOnUserReport,
              icon: Icons.gavel_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnUserReport: val),
              )),
            ),
          ],
        ),

        // 4. Hệ thống & Bảo mật (System & Security)
        ConfigCard(
          title: 'Hệ thống & Bảo mật',
          subtitle: 'Theo dõi sức khỏe hệ thống và an toàn dữ liệu',
          icon: Icons.security_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Lỗi hệ thống',
              subtitle: 'Cảnh báo khi phát hiện lỗi logic hoặc crash AI',
              value: config.triggerRules.notifyOnSystemError,
              icon: Icons.bug_report_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnSystemError: val),
              )),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Bảo trì hệ thống',
              subtitle: 'Thông báo về các lịch bảo trì định kỳ sắp tới',
              value: config.triggerRules.notifyOnSystemMaintenance,
              icon: Icons.settings_suggest_outlined,
              isDark: isDark,
              onChanged: (val) => provider.updateNotification(config.copyWith(
                triggerRules: config.triggerRules.copyWith(notifyOnSystemMaintenance: val),
              )),
            ),
          ],
        ),

        // 5. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveNotification(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}
