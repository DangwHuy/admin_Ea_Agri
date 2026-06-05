import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

class SettingsFormFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final String infoText;
  final String saveButtonLabel;

  const SettingsFormFooter({
    super.key,
    required this.isLoading,
    required this.onSave,
    required this.onDiscard,
    this.infoText = 'Thay đổi sẽ ảnh hưởng đến tất cả giao diện người dùng đầu cuối.',
    this.saveButtonLabel = 'Cập nhật hệ thống',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 100),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            const Icon(Icons.info_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                infoText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 24),
            TextButton(
              onPressed: onDiscard,
              child: Text('Hủy bỏ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                    )
                  : Text(saveButtonLabel, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
