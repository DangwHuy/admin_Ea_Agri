import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_input.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class BackupSettingsForm extends StatelessWidget {
  const BackupSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.backup;

    if (config == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Backup Schedule
        ConfigCard(
          title: 'Lịch trình sao lưu',
          icon: Icons.calendar_month_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Tự động sao lưu',
              subtitle: 'Hệ thống sẽ tự động thực hiện sao lưu theo lịch',
              value: config.enableAutoBackup,
              onChanged: (val) => provider.updateBackup(config.copyWith(enableAutoBackup: val)),
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: 'Tần suất sao lưu',
                    value: config.backupFrequency,
                    isDark: isDark,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                      DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                      DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.updateBackup(config.copyWith(backupFrequency: val));
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: CustomAdminInput(
                    label: 'Thời điểm sao lưu (HH:mm)',
                    initialValue: config.backupTime,
                    hintText: 'Ví dụ: 02:00',
                    onChanged: (val) => provider.updateBackup(config.copyWith(backupTime: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomAdminInput(
              label: 'Thời gian lưu trữ bản sao (Ngày)',
              initialValue: config.retentionDays.toString(),
              keyboardType: TextInputType.number,
              helperText: 'Các bản sao cũ hơn số ngày này sẽ bị tự động xóa.',
              onChanged: (val) {
                final days = int.tryParse(val);
                if (days != null) provider.updateBackup(config.copyWith(retentionDays: days));
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Backup Destination
        ConfigCard(
          title: 'Điểm đến sao lưu',
          icon: Icons.storage_rounded,
          children: [
            _buildSwitchTile(
              context,
              title: 'Sao lưu lên Cloud Storage',
              subtitle: 'Firebase Storage / Google Cloud',
              value: config.backupToCloudStorage,
              onChanged: (val) => provider.updateBackup(config.copyWith(backupToCloudStorage: val)),
            ),
            Divider(height: 32, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            _buildSwitchTile(
              context,
              title: 'Sao lưu lên Server bên ngoài',
              subtitle: 'Tự lưu trữ trên hạ tầng riêng (SFTP/API)',
              value: config.backupToExternalServer,
              onChanged: (val) => provider.updateBackup(config.copyWith(backupToExternalServer: val)),
            ),
            if (config.backupToExternalServer) ...[
              const SizedBox(height: 24),
              CustomAdminInput(
                label: 'URL Server External',
                initialValue: config.externalServerUrl,
                hintText: 'https://backup.yourdomain.com/api',
                onChanged: (val) => provider.updateBackup(config.copyWith(externalServerUrl: val)),
              ),
            ],
          ],
        ),

        // 3. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveBackup(),
          onDiscard: () => provider.discardChanges(),
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

  Widget _buildDropdown(BuildContext context, {required String label, required String value, required bool isDark, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) {
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
