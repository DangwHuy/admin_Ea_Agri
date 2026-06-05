import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_input.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class FeatureFlagsForm extends StatelessWidget {
  const FeatureFlagsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.featureFlags;

    if (config == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Operational Status
        ConfigCard(
          title: 'Trạng thái vận hành',
          icon: Icons.power_settings_new_rounded,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: config.isMaintenanceMode 
                    ? Colors.orange.withValues(alpha: isDark ? 0.08 : 0.04) 
                    : isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: config.isMaintenanceMode 
                      ? Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1) 
                      : isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Chế độ bảo trì hệ thống', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    subtitle: Text('Khi bật, người dùng phổ thông sẽ không thể truy cập ứng dụng.', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                    value: config.isMaintenanceMode,
                    activeColor: Colors.orange,
                    onChanged: (val) => provider.updateFeatureFlags(config.copyWith(isMaintenanceMode: val)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (config.isMaintenanceMode) ...[
                    Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.orange.withValues(alpha: 0.2), thickness: 0.5)),
                    CustomAdminInput(
                      label: 'Thông báo hiển thị cho khách hàng',
                      initialValue: config.maintenanceMessage,
                      maxLines: 2,
                      onChanged: (val) => provider.updateFeatureFlags(config.copyWith(maintenanceMessage: val)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Module Management
        ConfigCard(
          title: 'Quản lý Module',
          icon: Icons.view_module_rounded,
          children: [
            _buildModuleSwitch(
              context,
              title: 'Hệ thống AI Analytics',
              subtitle: 'Bật/tắt dashboard phân tích AI, chatbot chuyên gia và dự báo giá.',
              value: config.customFlags['ai_analytics'] ?? true,
              onChanged: (val) {
                final newFlags = Map<String, bool>.from(config.customFlags);
                newFlags['ai_analytics'] = val;
                provider.updateFeatureFlags(config.copyWith(customFlags: newFlags));
              },
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildModuleSwitch(
              context,
              title: 'Hệ thống Voucher & Khuyến mãi',
              subtitle: 'Quản lý việc áp dụng mã giảm giá và các chương trình ưu đãi.',
              value: config.enablePromotions,
              onChanged: (val) => provider.updateFeatureFlags(config.copyWith(enablePromotions: val)),
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildModuleSwitch(
              context,
              title: 'Tính năng Beta',
              subtitle: 'Cho phép một nhóm nhỏ người dùng thử nghiệm các tính năng mới.',
              value: config.enableBetaFeatures,
              onChanged: (val) => provider.updateFeatureFlags(config.copyWith(enableBetaFeatures: val)),
            ),
            if (config.enableBetaFeatures) ...[
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tỷ lệ áp dụng Beta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      Text('${config.betaRolloutPercentage}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: config.betaRolloutPercentage.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      onChanged: (val) => provider.updateFeatureFlags(config.copyWith(betaRolloutPercentage: val.toInt())),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // 3. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveFeatureFlags(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  Widget _buildModuleSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
