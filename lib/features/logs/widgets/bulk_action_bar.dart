import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClearSelection;
  final List<Widget> actions;
  final Color? backgroundColor;

  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.onClearSelection,
    required this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE0E7FF), // Light Indigo/Blue for Selection Mode
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        children: [
          // Select Count & Clear
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF4338CA)),
            onPressed: onClearSelection,
            tooltip: 'Hủy chọn',
          ),
          const SizedBox(width: 8),
          Text(
            "Đã chọn: $selectedCount mục",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4338CA),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Action Buttons
          ...actions,
        ],
      ),
    );
  }
}
