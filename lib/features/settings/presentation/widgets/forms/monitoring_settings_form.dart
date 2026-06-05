import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class MonitoringSettingsForm extends StatelessWidget {
  const MonitoringSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.monitoring;

    if (config == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Performance & Alerts
        ConfigCard(
          title: 'Hiệu năng & Cảnh báo',
          icon: Icons.speed_rounded,
          children: [
            _buildSliderTile(
              context: context,
              label: 'Ngưỡng trễ API (ms)',
              value: config.apiLatencyThresholdMs.toDouble(),
              min: 100,
              max: 5000,
              divisions: 49,
              isDark: isDark,
              displayValue: '${config.apiLatencyThresholdMs}ms',
              onChanged: (val) => provider.updateMonitoring(config.copyWith(apiLatencyThresholdMs: val.toInt())),
            ),
            const SizedBox(height: 32),
            _buildSliderTile(
              context: context,
              label: 'Tỷ lệ lỗi cảnh báo (%)',
              value: config.errorRateAlertThreshold,
              min: 0,
              max: 20,
              divisions: 20,
              isDark: isDark,
              displayValue: '${config.errorRateAlertThreshold}%',
              activeTrackColor: Colors.redAccent,
              onChanged: (val) => provider.updateMonitoring(config.copyWith(errorRateAlertThreshold: val)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Logs Data
        ConfigCard(
          title: 'Dữ liệu nhật ký (Logs)',
          icon: Icons.receipt_long_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Theo dõi Firestore Usage',
              subtitle: 'Ghi lại các hoạt động đọc/ghi để tối ưu chi phí',
              value: config.enableFirestoreUsageTracking,
              onChanged: (val) => provider.updateMonitoring(config.copyWith(enableFirestoreUsageTracking: val)),
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Thống kê AI Usage',
              subtitle: 'Theo dõi mức độ sử dụng AI và token',
              value: config.enableAIUsageStats,
              onChanged: (val) => provider.updateMonitoring(config.copyWith(enableAIUsageStats: val)),
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildDropdown(
              context,
              label: 'Thời gian lưu trữ Logs',
              value: config.logRetentionDays,
              isDark: isDark,
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 Ngày')),
                DropdownMenuItem(value: 30, child: Text('30 Ngày')),
                DropdownMenuItem(value: 90, child: Text('90 Ngày')),
                DropdownMenuItem(value: 365, child: Text('1 Năm')),
              ],
              onChanged: (val) {
                if (val != null) provider.updateMonitoring(config.copyWith(logRetentionDays: val));
              },
            ),
          ],
        ),

        // 3. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveMonitoring(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required bool isDark,
    required String displayValue,
    required ValueChanged<double> onChanged,
    Color? activeTrackColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            Text(displayValue, style: TextStyle(fontWeight: FontWeight.bold, color: activeTrackColor ?? AppColors.primary)),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeTrackColor ?? AppColors.primary,
            inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdown(BuildContext context, {required String label, required int value, required bool isDark, required List<DropdownMenuItem<int>> items, required ValueChanged<int?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          dropdownColor: Theme.of(context).colorScheme.surface,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
