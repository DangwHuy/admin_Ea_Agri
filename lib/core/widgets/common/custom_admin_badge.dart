import 'package:flutter/material.dart';

class CustomAdminBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final EdgeInsets padding;

  const CustomAdminBadge({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold, // Giữ nguyên độ đậm cho Badge
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
