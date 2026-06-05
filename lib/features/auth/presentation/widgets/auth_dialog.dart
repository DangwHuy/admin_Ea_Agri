import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class AuthDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget content;
  final String primaryButtonText;
  final Future<void> Function() onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const AuthDialog({
    super.key,
    required this.title,
    required this.description,
    required this.content,
    required this.primaryButtonText,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    required Widget content,
    required String primaryButtonText,
    required Future<void> Function() onPrimaryAction,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => AuthDialog(
        title: title,
        description: description,
        content: content,
        primaryButtonText: primaryButtonText,
        onPrimaryAction: onPrimaryAction,
        onSecondaryAction: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a StatefulBuilder inside to manage the local loading state of the dialog button.
    bool isLoading = false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            width: 400,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                content,
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSecondaryAction != null)
                      TextButton(
                        onPressed: isLoading ? null : onSecondaryAction,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        ),
                        child: Text(
                          'HỦY',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setDialogState(() => isLoading = true);
                              try {
                                await onPrimaryAction();
                                if (context.mounted) Navigator.of(context).pop(true);
                              } catch (e) {
                                // Error handling happens upstream
                                if (context.mounted) {
                                  setDialogState(() => isLoading = false);
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              primaryButtonText.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      ),
    );
  }
}
