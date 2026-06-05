import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class LocalizationSettingsForm extends StatelessWidget {
  const LocalizationSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.localization;

    if (config == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Regional Settings
        ConfigCard(
          title: 'Cài đặt khu vực',
          icon: Icons.language_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: 'Ngôn ngữ mặc định',
                    value: config.defaultLanguage,
                    isDark: isDark,
                    items: const [
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.updateLocalization(config.copyWith(defaultLanguage: val));
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: 'Tiền tệ mặc định',
                    value: config.defaultCurrency,
                    isDark: isDark,
                    items: const [
                      DropdownMenuItem(value: 'VND', child: Text('Việt Nam Đồng (VND)')),
                      DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.updateLocalization(config.copyWith(defaultCurrency: val));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Time & Units
        ConfigCard(
          title: 'Thời gian & Đơn vị',
          icon: Icons.date_range_rounded,
          children: [
            _buildDropdown(
              context,
              label: 'Múi giờ hệ thống',
              value: config.defaultTimezone,
              isDark: isDark,
              items: const [
                DropdownMenuItem(value: 'Asia/Ho_Chi_Minh', child: Text('Asia/Ho_Chi_Minh (GMT+7)')),
                DropdownMenuItem(value: 'UTC', child: Text('UTC (GMT+0)')),
              ],
              onChanged: (val) {
                if (val != null) provider.updateLocalization(config.copyWith(defaultTimezone: val));
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: 'Định dạng ngày',
                    value: config.dateFormat,
                    isDark: isDark,
                    items: const [
                      DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
                      DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
                      DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.updateLocalization(config.copyWith(dateFormat: val));
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: 'Hệ thống đơn vị',
                    value: config.unitSystem,
                    isDark: isDark,
                    items: const [
                      DropdownMenuItem(value: 'metric', child: Text('Hệ mét (kg, m)')),
                      DropdownMenuItem(value: 'imperial', child: Text('Hệ Anh (lb, ft)')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.updateLocalization(config.copyWith(unitSystem: val));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // 3. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveLocalization(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
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
