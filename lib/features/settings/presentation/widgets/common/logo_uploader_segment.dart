import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

class LogoUploaderSegment extends StatefulWidget {
  final String? initialLogoUrl;
  final String appInitial;
  final Function(Uint8List?) onLogoChanged;

  const LogoUploaderSegment({
    super.key,
    this.initialLogoUrl,
    required this.appInitial,
    required this.onLogoChanged,
  });

  @override
  State<LogoUploaderSegment> createState() => _LogoUploaderSegmentState();
}

class _LogoUploaderSegmentState extends State<LogoUploaderSegment> {
  Uint8List? _previewData;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _previewData = bytes);
      widget.onLogoChanged(bytes);
    }
  }

  void _removeImage() {
    setState(() => _previewData = null);
    widget.onLogoChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo thương hiệu',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Logo Preview
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _previewData != null
                      ? Image.memory(_previewData!, fit: BoxFit.cover)
                      : widget.initialLogoUrl != null && widget.initialLogoUrl!.isNotEmpty
                          ? Image.network(widget.initialLogoUrl!, fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                widget.appInitial,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 24),
              // Controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Định dạng khuyên dùng: PNG, SVG (Tối đa 2MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.surfaceVariant,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Thay đổi', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _removeImage,
                          child: const Text(
                            'Gỡ bỏ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
