import 'package:flutter/widgets.dart';

class SettingsGroup {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  SettingsGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}
