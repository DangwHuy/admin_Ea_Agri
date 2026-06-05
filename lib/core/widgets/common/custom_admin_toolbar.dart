import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../../constants/app_colors.dart';

class CustomAdminToolbar extends StatelessWidget {
  final Widget? searchField;
  final List<Widget>? centerFilters;
  final List<Widget>? trailingActions;
  final List<Widget>? children;
  final double height;
  final EdgeInsets padding;

  const CustomAdminToolbar({
    super.key,
    this.searchField,
    this.centerFilters,
    this.trailingActions,
    this.children,
    this.height = 72,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      height: height,
      padding: padding,
      child: children != null 
        ? Row(children: children!)
        : Row(
            children: [
              if (searchField != null) 
                Expanded(flex: 3, child: searchField!),
              
              if (centerFilters != null && centerFilters!.isNotEmpty) ...[
                const SizedBox(width: 16),
                ...centerFilters!.map((w) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(width: 200, child: w),
                )),
              ],

              if (trailingActions != null && trailingActions!.isNotEmpty) ...[
                const Spacer(),
                ...trailingActions!.map((w) => Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: w,
                )),
              ],
            ],
          ),
    );
  }
}
