import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/features/reports/services/report_service.dart';
import 'package:admin_daklak_web/features/reports/services/export_service.dart';
import 'package:admin_daklak_web/features/reports/widgets/report_skeleton.dart';
import 'package:admin_daklak_web/features/reports/widgets/report_widgets.dart';
import 'package:admin_daklak_web/features/reports/widgets/report_charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  final ExportService _exportService = ExportService();

  bool _isExporting = false;
  late Future<Map<String, dynamic>> _businessFuture;
  late Future<Map<String, dynamic>> _agriFuture;
  late Stream<Map<String, dynamic>> _aiStream;
  late Future<List<Map<String, dynamic>>> _alertsFuture;
  late Future<List<Map<String, dynamic>>> _insightsFuture;
  int _selectedTabIndex = 0;
  bool _isNavCollapsed = false;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _businessFuture = _reportService.getBusinessOverview();
      _agriFuture = _reportService.getAgriExpertStats();
      _aiStream = _reportService.getAISystemStatsStream();
      _alertsFuture = _reportService.getLatestAlerts();
      _insightsFuture = _reportService.getLatestInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Section ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Báo cáo & Thống kê',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phân tích và theo dõi hiệu suất hoạt động toàn diện của hệ thống',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              _buildFilterCluster(),
              const SizedBox(width: 12),
              _buildExportButton(),
            ],
          ),
          const SizedBox(height: 32),

          // ── Integrated Navigation & Content ──────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Rail (Master)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isNavCollapsed ? 80 : 260,
                  child: _buildIntegratedNav(),
                ),

                const SizedBox(
                  width: 32,
                ), // Precise 32px gap from Rail to Content
                // Content Area (Detail)
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedNav() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.analytics_rounded, 'label': 'Tổng quan kinh doanh'},
      {'icon': Icons.agriculture_rounded, 'label': 'Nông nghiệp & Chuyên gia'},
      {'icon': Icons.psychology_rounded, 'label': 'Người dùng & Hệ thống AI'},
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTabIndex == index;
              return _NavChip(
                icon: items[index]['icon'],
                label: items[index]['label'],
                isSelected: isSelected,
                isCollapsed: _isNavCollapsed,
                onTap: () => setState(() => _selectedTabIndex = index),
              );
            },
          ),
        ),

        // Collapse Toggle Button
        _buildCollapseToggle(),
      ],
    );
  }

  Widget _buildCollapseToggle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () => setState(() => _isNavCollapsed = !_isNavCollapsed),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _isNavCollapsed
                ? Icons.keyboard_double_arrow_right_rounded
                : Icons.keyboard_double_arrow_left_rounded,
            size: 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _BusinessOverviewTab(
          future: _businessFuture,
          alertsFuture: _alertsFuture,
          insightsFuture: _insightsFuture,
          onRefresh: _refreshData,
        );
      case 1:
        return _AgriExpertTab(future: _agriFuture);
      case 2:
        return _AISystemTab(stream: _aiStream);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      onSelected: _handleExport,
      enabled: !_isExporting,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'orders', child: Text("Xuất Đơn Hàng")),
        const PopupMenuItem(value: 'expenses', child: Text("Xuất Chi Phí")),
        const PopupMenuItem(value: 'all', child: Text("Xuất Tất Cả")),
      ],
      child: ElevatedButton.icon(
        onPressed: null,
        icon: _isExporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.download_rounded, size: 18),
        label: Text(_isExporting ? "Đang xuất..." : "Xuất File"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _handleExport(String type) async {
    setState(() => _isExporting = true);
    try {
      if (type == 'orders' || type == 'all') {
        final orders = await _reportService.fetchAllOrders();
        _exportService.exportOrdersToCsv(orders);
      }
      if (type == 'expenses' || type == 'all') {
        final expenses = await _reportService.fetchAllExpenses();
        _exportService.exportExpensesToCsv(expenses);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Xuất dữ liệu thành công!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi xuất dữ liệu: $e")));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Chọn',
      cancelText: 'Hủy',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Widget _buildFilterCluster() {
    final hasRange = _selectedDateRange != null;
    final String dateLabel = hasRange
        ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
        : 'Lọc theo ngày';

    return Container(
      decoration: BoxDecoration(
        color: hasRange
            ? AppColors.primary.withValues(alpha: 0.08)
            : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : Colors.white.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: hasRange
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: _pickDateRange,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: hasRange
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: hasRange
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: hasRange ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (hasRange) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _selectedDateRange = null),
                  child: Icon(Icons.close, size: 14, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Tab Widgets ──────────────────────────────────────────

class _BusinessOverviewTab extends StatelessWidget {
  final Future<Map<String, dynamic>> future;
  final Future<List<Map<String, dynamic>>> alertsFuture;
  final Future<List<Map<String, dynamic>>> insightsFuture;
  final VoidCallback onRefresh;

  const _BusinessOverviewTab({
    required this.future,
    required this.alertsFuture,
    required this.insightsFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const _ReportLoadingView();
        final data = snapshot.data ?? {};
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _buildAlertsSection(),
              _buildKPIGrid(data),
              const SizedBox(height: 24),
              _buildChartsSection(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: alertsFuture,
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            ...alerts.map((alert) {
              String content = alert['content'] ?? "Đã phát hiện bất thường.";
              content = content
                  .replaceAll('Anomalies:', 'Bất thường:')
                  .replaceAll(
                    'unusual cancellations detected for',
                    'lượt hủy bất thường phát hiện tại',
                  );

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 24,
                ), // Gap between alerts OR gap to content below
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.orange[100]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: isDark ? Colors.orange[300] : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.orange[200]
                              : Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildKPIGrid(Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.6,
          children: [
            ReportKPICard(
              title: "Tổng doanh thu",
              value: "${(data['totalRevenue'] ?? 0).toInt()} đ",
              subtitle: "Giá trị tích lũy toàn thời gian",
              trend: "↑ 12.5%",
              isPositive: true,
              icon: Icons.payments_outlined,
              iconColor: AppColors.primary,
              onTap: () => context.push('/finance'),
            ),
            ReportKPICard(
              title: "Đơn hàng hôm nay",
              value: "${data['todayOrders'] ?? 0}",
              subtitle: "Số đơn hàng mới từ 0h sáng",
              trend: "↑ 4.2%",
              isPositive: true,
              icon: Icons.shopping_basket_outlined,
              iconColor: Colors.blue,
              onTap: () => context.push('/orders'),
            ),
            ReportKPICard(
              title: "Sản lượng",
              value: "${data['totalOrders'] ?? 0}",
              subtitle: "Tổng số lượng đơn hàng tích lũy",
              trend: "Ổn định",
              isPositive: true,
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.orange,
              onTap: () => context.push('/products'),
            ),
            ReportKPICard(
              title: "Doanh thu hôm nay",
              value: "${(data['todayRevenue'] ?? 0).toInt()} đ",
              subtitle: "Thu nhập thực tế trong ngày",
              trend: "Trực tiếp",
              isPositive: true,
              icon: Icons.trending_up,
              iconColor: Colors.teal,
              onTap: () => context.push('/finance'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: TrendLineChart(
                  spots: [
                    FlSpot(0, 1200000),
                    FlSpot(1, 1500000),
                    FlSpot(2, 1100000),
                    FlSpot(3, 1800000),
                    FlSpot(4, 2100000),
                    FlSpot(5, 1900000),
                    FlSpot(6, 2500000),
                  ],
                  maxY: 2500000,
                  labels: [
                    "Th 2",
                    "Th 3",
                    "Th 4",
                    "Th 5",
                    "Th 6",
                    "Th 7",
                    "CN",
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: RankingList(
                  title: "Top sản phẩm (Số lượt đặt)",
                  items: data['topProducts'] ?? [],
                  onTap: () => context.push('/products'),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Builder(
              builder: (context) {
                final trend = (data['revenueTrend'] as List?)?.cast<double>() ?? [0, 0, 0, 0, 0, 0, 0];
                double mY = 0;
                for (var v in trend) { if (v > mY) mY = v; }
                if (mY == 0) mY = 1000000;
                
                final now = DateTime.now();
                List<String> labels = [];
                for (int i = 6; i >= 0; i--) {
                  final day = now.subtract(Duration(days: i));
                  labels.add(DateFormat('dd/MM').format(day));
                }

                return TrendLineChart(
                  spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  maxY: mY,
                  labels: labels,
                );
              }
            ),
            const SizedBox(height: 24),
            RankingList(
              title: "Top sản phẩm (Số lượt đặt)",
              items: data['topProducts'] ?? [],
              onTap: () => context.push('/products'),
            ),
          ],
        );
      },
    );
  }
}

class _AgriExpertTab extends StatelessWidget {
  final Future<Map<String, dynamic>> future;
  const _AgriExpertTab({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const _ReportLoadingView();
        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ReportKPICard(
                      title: "Lịch hẹn tư vấn",
                      value: "${data['totalAppointments']}",
                      subtitle: "Buổi làm việc với chuyên gia",
                      trend: "↑ 8%",
                      isPositive: true,
                      icon: Icons.event,
                      iconColor: Colors.blue,
                      onTap: () => context.push('/appointments'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ReportKPICard(
                      title: "Chuyên gia hoạt động",
                      value: "${data['activeExperts']}",
                      subtitle: "Chuyên gia nông nghiệp đã xác minh",
                      trend: "Ổn định",
                      isPositive: true,
                      icon: Icons.verified,
                      iconColor: AppColors.primary,
                      onTap: () => context.push('/users'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const AgriPriceChart(),
            ],
          ),
        );
      },
    );
  }
}

class _AISystemTab extends StatelessWidget {
  final Stream<Map<String, dynamic>> stream;
  const _AISystemTab({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const _ReportLoadingView();
        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AIHealthCard(
                      fallbackPercent:
                          (data['fallbackPercent'] as num?)?.toDouble() ?? 0.0,
                      totalQuestions: data['totalQuestions'] ?? 0,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ReportKPICard(
                      title: "Tỷ lệ thành công",
                      value: "${(data['successRate'] ?? 0.0).toString()}%",
                      subtitle: "Câu hỏi AI được xử lý đúng",
                      trend: "Mục tiêu > 90%",
                      isPositive: (data['successRate'] ?? 0.0) >= 90,
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.teal,
                      onTap: () => context.push('/ai-logs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RankingList(
                      title: "Chủ đề truy vấn phổ biến",
                      items: data['popularQuestions'] ?? [],
                      onTap: () => context.push('/ai-logs'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Components ──────────────────────────────────────────

class _NavChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_NavChip> createState() => _NavChipState();
}

class _NavChipState extends State<_NavChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.isCollapsed ? widget.label : "",
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                  : _isHovered
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? activeColor.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isSelected
                      ? activeColor
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: widget.isSelected
                            ? activeColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
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

class _ReportLoadingView extends StatelessWidget {
  const _ReportLoadingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: ReportSkeletonCard()),
              SizedBox(width: 24),
              Expanded(child: ReportSkeletonCard()),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonContainer(width: double.infinity, height: 400),
        ],
      ),
    );
  }
}
