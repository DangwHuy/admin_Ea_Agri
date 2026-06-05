import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomAdminInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? helperText;
  final Color? fillColor;
  final bool hasBorder;

  const CustomAdminInput({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.helperText,
    this.fillColor,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 13, // Giữ kích thước nhỏ gọn cho nhãn input
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            helperText: helperText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Theme.of(context).textTheme.bodySmall?.color) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasBorder ? BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasBorder ? BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
