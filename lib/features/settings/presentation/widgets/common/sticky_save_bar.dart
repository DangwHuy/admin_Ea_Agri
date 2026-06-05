import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/constants/app_text_styles.dart';

class StickySaveBar extends StatelessWidget {
  const StickySaveBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Bạn có thay đổi chưa lưu',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textHeading),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: provider.isLoading ? null : () => provider.discardChanges(),
                child: Text(
                  'Hủy thay đổi',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await _saveAll(provider);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật cấu hình thành công!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textInverse,
                        ),
                      )
                    : Text(
                        'Lưu thay đổi',
                        style: AppTextStyles.buttonText,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _saveAll(SettingsProvider provider) async {
    bool success = true;
    if (provider.isGlobalDirty) success &= await provider.saveGlobal();
    if (provider.isBusinessDirty) success &= await provider.saveBusiness();
    if (provider.isAIDirty) success &= await provider.saveAI();
    if (provider.isSecurityDirty) success &= await provider.saveSecurity();
    if (provider.isFeatureFlagsDirty) success &= await provider.saveFeatureFlags();
    if (provider.isNotificationDirty) success &= await provider.saveNotification();
    if (provider.isMonitoringDirty) success &= await provider.saveMonitoring();
    if (provider.isLocalizationDirty) success &= await provider.saveLocalization();
    if (provider.isBackupDirty) success &= await provider.saveBackup();
    return success;
  }
}
