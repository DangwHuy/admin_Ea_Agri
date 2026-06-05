import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/constants/app_text_styles.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

// --- KPI Card with Drill-down Effect ---

class ReportKPICard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const ReportKPICard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<ReportKPICard> createState() => _ReportKPICardState();
}

class _ReportKPICardState extends State<ReportKPICard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.trend,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.isPositive
                            ? Colors.green[400]
                            : Colors.red[400],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// --- AI System Health Card (Fallback %) ---

class AIHealthCard extends StatefulWidget {
  final double fallbackPercent;
  final int totalQuestions;

  const AIHealthCard({
    super.key,
    required this.fallbackPercent,
    required this.totalQuestions,
  });

  @override
  State<AIHealthCard> createState() => _AIHealthCardState();
}

class _AIHealthCardState extends State<AIHealthCard> {
  bool _isHovered = false;

  Color get _healthColor {
    if (widget.fallbackPercent < 5) return Colors.green;
    if (widget.fallbackPercent <= 15) return Colors.orange;
    return Colors.red;
  }

  String get _statusText {
    if (widget.fallbackPercent < 5) return "Hoạt động tối ưu";
    if (widget.fallbackPercent <= 15) return "Cần thêm dữ liệu";
    return "Hệ thống quá tải";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => context.go('/ai-logs'),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Theo dõi sức khỏe AI",
                    style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Icon(Icons.psychology, color: _healthColor),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.fallbackPercent.toStringAsFixed(1)}%",
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _healthColor,
                              ),
                        ),
                        Text(
                          "Tỷ lệ Fallback",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusText,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _healthColor,
                              ),
                        ),
                        Text(
                          "Trạng thái",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.fallbackPercent / 100,
                  backgroundColor: _healthColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_healthColor),
                  minHeight: 8,
                ),
              ),
              if (_isHovered) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Xem nhật ký chi tiết",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _healthColor,
                      ),
                    ),
                    const Icon(Icons.arrow_right_alt, size: 16),
                  ],
                ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// --- Ranking List Widget ---

class RankingList extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final bool isCurrency;
  final VoidCallback? onTap;

  const RankingList({
    super.key,
    required this.title,
    required this.items,
    this.isCurrency = false,
    this.onTap,
  });

  @override
  State<RankingList> createState() => _RankingListState();
}

class _RankingListState extends State<RankingList> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap ?? () => context.go('/ai-logs'),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  if (_isHovered)
                    const Icon(
                      Icons.launch,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ...widget.items.asMap().entries.map((entry) {
                int idx = entry.key;
                var data = entry.value;
                String name = data['name'] ?? data['query'] ?? '--';
                dynamic val = data['quantitySold'] ?? data['hits'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: idx == 0
                              ? Colors.amber[100]
                              : Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${idx + 1}",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: idx == 0
                                    ? Colors.amber[900]
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.isCurrency ? "$val đ" : "$val",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (widget.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Chưa có đủ dữ liệu thống kê",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
