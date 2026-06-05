import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common/glass_container.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/dashboard_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<int> _totalFarmersFuture;
  late Future<int> _newFarmersTodayFuture;
  late Future<List<FlSpot>> _chartData7DaysFuture;
  late Future<int> _totalExpertsFuture;
  late Future<int> _onlineExpertsFuture;
  late Future<int> _pendingAppointmentsFuture;
  late Future<int> _confirmedAppointmentsFuture;
  late Future<int> _cancelledAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAllStats();
  }

  void _refreshAllStats() {
    setState(() {
      _totalFarmersFuture = _getTotalFarmers();
      _newFarmersTodayFuture = _getNewFarmersToday();
      _chartData7DaysFuture = _getChartData7Days();
      _totalExpertsFuture = _getTotalExperts();
      _onlineExpertsFuture = _getOnlineExperts();
      _pendingAppointmentsFuture = _getAppointmentsCount('pending');
      _confirmedAppointmentsFuture = _getAppointmentsCount('confirmed');
      _cancelledAppointmentsFuture = _getAppointmentsCount('cancelled');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth <= 768;
    bool isTablet = screenWidth > 768 && screenWidth <= 1200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        key: const ValueKey('dashboard_main_column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildTopRow(isMobile, isTablet),
          const SizedBox(height: 24),
          _buildMiddleRow(isMobile, isTablet),
          const SizedBox(height: 24),
          _buildBottomRow(isMobile),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng!';
    if (hour < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bảng điều khiển',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getGreeting() + ' Theo dõi và tối ưu hoạt động nông nghiệp với dữ liệu thời gian thực',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        key: const ValueKey('top_row_mobile'),
        children: [
          _WeatherCard(),
          const SizedBox(height: 16),
          _buildFarmerStatCard(),
          const SizedBox(height: 16),
          const ExpertOverviewCard(),
          const SizedBox(height: 16),
          _buildAppointmentStatCard(),
        ],
      );
    }

    return SizedBox(
      height: 300,
      child: Row(
        key: const ValueKey('top_row_desktop'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _WeatherCard()),
          const SizedBox(width: 20),
          Expanded(flex: 3, child: _buildFarmerStatCard()),
          const SizedBox(width: 20),
          const Expanded(flex: 3, child: ExpertOverviewCard()),
          const SizedBox(width: 20),
          Expanded(flex: 3, child: _buildAppointmentStatCard()),
        ],
      ),
    );
  }

  Widget _buildMiddleRow(bool isMobile, bool isTablet) {
    if (isMobile || isTablet) {
      return Column(
        key: const ValueKey('middle_row_mobile'),
        children: [
          _SalesPriceTrendCard(),
          const SizedBox(height: 24),
          _PopularDiseaseMentionCard(),
        ],
      );
    }
    return SizedBox(
      height: 450,
      child: Row(
        key: const ValueKey('middle_row_desktop'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 8, child: _SalesPriceTrendCard()),
          const SizedBox(width: 24),
          Expanded(flex: 4, child: _PopularDiseaseMentionCard()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(bool isMobile) {
    if (isMobile) {
      return Column(
        key: const ValueKey('bottom_row_mobile'),
        children: [
          _ProductionOverviewCard(),
          const SizedBox(height: 24),
          _FieldImageCard(),
        ],
      );
    }
    return SizedBox(
      height: 450,
      child: Row(
        key: const ValueKey('bottom_row_desktop'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: _ProductionOverviewCard()),
          const SizedBox(width: 24),
          Expanded(flex: 6, child: _FieldImageCard()),
        ],
      ),
    );
  }

  Widget _buildFarmerStatCard() {
    return DashboardStatCard(
      key: const ValueKey('farmer_stat_card'),
      titleTotal: 'Nông dân',
      titleNew: 'Hôm nay',
      iconTotal: Icons.people_alt_rounded,
      iconNew: Icons.person_add_alt_1_rounded,
      colorTotal: Colors.green,
      colorNew: Colors.green,
      chartColor: Colors.green,
      futureTotal: _totalFarmersFuture,
      futureNew: _newFarmersTodayFuture,
      futureChart: _chartData7DaysFuture,
    );
  }

  Widget _buildAppointmentStatCard() {
    return DashboardStatCard(
      key: const ValueKey('appointment_stat_card'),
      titleTotal: 'Chờ',
      iconTotal: Icons.hourglass_empty_rounded,
      colorTotal: Colors.orange,
      futureTotal: _pendingAppointmentsFuture,
      titleNew: 'Đã nhận',
      iconNew: Icons.check_circle_outline_rounded,
      colorNew: Colors.green,
      futureNew: _confirmedAppointmentsFuture,
      titleThird: 'Đã hủy',
      iconThird: Icons.cancel_outlined,
      colorThird: Colors.red,
      futureThird: _cancelledAppointmentsFuture,
      chartTitle: 'Phân bố trạng thái',
      chartColor: Colors.transparent,
      isHorizontalBar: true,
    );
  }

  Future<int> _getTotalFarmers() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users')
          .where('role', whereIn: ['farmer', 'Farmer', 'Nông dân']).count().get();
      return snap.count ?? 0;
    } catch (e) { return 0; }
  }

  Future<int> _getNewFarmersToday() async {
    try {
      final startOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final snap = await FirebaseFirestore.instance.collection('users')
          .where('role', whereIn: ['farmer', 'Farmer', 'Nông dân'])
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .count().get();
      return snap.count ?? 0;
    } catch (e) { return 0; }
  }

  Future<List<FlSpot>> _getChartData7Days() async {
    List<Future<AggregateQuerySnapshot>> futures = [];
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    for (int i = 6; i >= 0; i--) {
      DateTime targetDayStart = todayStart.subtract(Duration(days: i));
      DateTime targetDayEnd = targetDayStart.add(const Duration(days: 1));
      var query = FirebaseFirestore.instance.collection('users')
          .where('role', whereIn: ['farmer', 'Farmer', 'Nông dân'])
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(targetDayStart))
          .where('createdAt', isLessThan: Timestamp.fromDate(targetDayEnd))
          .count().get();
      futures.add(query);
    }
    try {
      final snapshots = await Future.wait(futures);
      List<FlSpot> spots = [];
      for (int i = 0; i < snapshots.length; i++) {
        spots.add(FlSpot(i.toDouble(), (snapshots[i].count ?? 0).toDouble()));
      }
      return spots;
    } catch (e) { return const [FlSpot(0, 0)]; }
  }

  Future<int> _getTotalExperts() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users')
          .where('role', whereIn: ['expert', 'Expert', 'Chuyên gia']).count().get();
      return snap.count ?? 0;
    } catch (e) { return 0; }
  }

  Future<int> _getOnlineExperts() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users')
          .where('role', whereIn: ['expert', 'Expert', 'Chuyên gia'])
          .where('isOnline', isEqualTo: true).count().get();
      return snap.count ?? 0;
    } catch (e) { return 0; }
  }

  Future<int> _getAppointmentsCount(String status) async {
    try {
      List<String> statusFilter;
      if (status == 'pending') statusFilter = ['pending', 'Pending', 'Chờ xác nhận'];
      else if (status == 'confirmed') statusFilter = ['confirmed', 'Confirmed', 'Đã xác nhận'];
      else statusFilter = ['cancelled', 'Cancelled', 'Đã hủy'];

      final snap = await FirebaseFirestore.instance.collection('appointments')
          .where('status', whereIn: statusFilter)
          .count().get();
      return snap.count ?? 0;
    } catch (e) { return 0; }
  }
}

class DashboardStatCard extends StatefulWidget {
  final String titleTotal;
  final String titleNew;
  final String chartTitle;
  final IconData iconTotal;
  final IconData iconNew;
  final Color colorTotal;
  final Color colorNew;
  final Color chartColor;
  final bool isPieChart;
  final String? titleThird;
  final IconData? iconThird;
  final Color? colorThird;
  final Future<int>? futureThird;
  final bool isHorizontalBar;
  final Future<int> futureTotal;
  final Future<int> futureNew;
  final Future<List<FlSpot>>? futureChart;

  const DashboardStatCard({
    Key? key,
    required this.titleTotal,
    required this.titleNew,
    this.chartTitle = 'Biểu đồ 7 ngày qua',
    required this.iconTotal,
    required this.iconNew,
    required this.colorTotal,
    required this.colorNew,
    required this.chartColor,
    this.isPieChart = false,
    this.isHorizontalBar = false,
    this.titleThird,
    this.iconThird,
    this.colorThird,
    this.futureThird,
    required this.futureTotal,
    required this.futureNew,
    this.futureChart,
  }) : super(key: key);

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard> {
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _combinedFuture = _initFutures();
  }

  @override
  void didUpdateWidget(covariant DashboardStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureTotal != widget.futureTotal || 
        oldWidget.futureNew != widget.futureNew || 
        oldWidget.futureThird != widget.futureThird || 
        oldWidget.futureChart != widget.futureChart) {
      setState(() {
        _combinedFuture = _initFutures();
      });
    }
  }

  Future<List<dynamic>> _initFutures() {
    final List<Future<dynamic>> futures = [widget.futureTotal, widget.futureNew];
    if (widget.futureThird != null) futures.add(widget.futureThird!);
    if (widget.futureChart != null) futures.add(widget.futureChart!);
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingOrErrorContainer(const CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildLoadingOrErrorContainer(const Text('Lỗi tải dữ liệu', style: TextStyle(color: Colors.red, fontSize: 12)));
        }

        final data1 = snapshot.data?[0] ?? 0;
        final data2 = snapshot.data?[1] ?? 0;
        final int data3 = widget.futureThird != null ? (snapshot.data?[2] ?? 0) : 0;
        final chartData = (widget.futureChart != null)
            ? (snapshot.data?.last as List<FlSpot>?) ?? const [FlSpot(0, 0)]
            : const [FlSpot(0, 0)];

        return AspectRatio(
          aspectRatio: 1,
          child: GlassContainer(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(child: _buildStatItem(widget.titleTotal, data1.toString(), widget.iconTotal, widget.colorTotal)),
                      Container(width: 1, color: Theme.of(context).dividerColor),
                      Expanded(child: _buildStatItem(widget.titleNew, data2.toString(), widget.iconNew, widget.colorNew)),
                      if (widget.titleThird != null && widget.iconThird != null && widget.colorThird != null) ...[
                        Container(width: 1, color: Theme.of(context).dividerColor),
                        Expanded(child: _buildStatItem(widget.titleThird!, data3.toString(), widget.iconThird!, widget.colorThird!)),
                      ]
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(height: 1, color: Theme.of(context).dividerColor),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.chartTitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: widget.isHorizontalBar
                            ? MiniHorizontalBarChart(pending: data1, confirmed: data2, cancelled: data3)
                            : widget.isPieChart
                            ? _buildPieChart(data1, data2, widget.colorNew)
                            : _buildLineChart(chartData, widget.chartColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 2),
        Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildPieChart(int total, int online, Color activeColor) {
    int offline = total - online;
    if (offline < 0) offline = 0;
    if (total == 0) return Center(child: Text('Chưa có dữ liệu', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)));
    double onlinePercent = (online / total) * 100;
    double offlinePercent = (offline / total) * 100;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: PieChart(
              key: const ValueKey('stat_pie_chart'),
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 18,
                sections: [
                  PieChartSectionData(
                    value: online.toDouble(),
                    color: activeColor,
                    radius: 35,
                    title: '${onlinePercent.toStringAsFixed(1)}%',
                    titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),
                    showTitle: true,
                  ),
                  PieChartSectionData(
                    value: offline.toDouble(),
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1),
                    radius: 28,
                    title: '${offlinePercent.toStringAsFixed(1)}%',
                    titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    showTitle: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Online', activeColor),
                const SizedBox(height: 8),
                _buildLegendItem('Offline', Theme.of(context).dividerColor),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Expanded(child: Text(title, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, Color color) {
    final validSpots = spots.isEmpty ? const [FlSpot(0, 0)] : spots;
    return AspectRatio(
      aspectRatio: 2.0,
      child: LineChart(
        key: const ValueKey('stat_line_chart'),
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white.withOpacity(0.8),
              tooltipPadding: const EdgeInsets.all(4),
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(s.y.toInt().toString(), TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))).toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor.withOpacity(0.5), strokeWidth: 1, dashArray: [4, 4]),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'T-${value.toInt()}', // To represent days ago or something
                      style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
              left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          minX: 0, maxX: 6, minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: validSpots,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrErrorContainer(Widget child) {
    return AspectRatio(
      aspectRatio: 1,
      child: GlassContainer(
  borderRadius: BorderRadius.circular(16),
  opacity: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.6,
  child: Center(child: child),
      ),
    );
  }
}

class MiniHorizontalBarChart extends StatelessWidget {
  final int pending;
  final int confirmed;
  final int cancelled;

  const MiniHorizontalBarChart({Key? key, required this.pending, required this.confirmed, required this.cancelled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = pending + confirmed + cancelled;
    if (total == 0) return Center(child: Text('Chưa có lịch hẹn', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)));
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBarRow(context, 'Chờ', pending, total, constraints.maxWidth, Colors.orange),
            _buildBarRow(context, 'Đã nhận', confirmed, total, constraints.maxWidth, Colors.green),
            _buildBarRow(context, 'Đã hủy', cancelled, total, constraints.maxWidth, Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildBarRow(BuildContext context, String label, int value, int total, double maxWidth, Color color) {
    double barMaxWidth = maxWidth - 50 - 30 - 16;
    double barWidth = total > 0 ? (value / total) * barMaxWidth : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Container(
            width: barMaxWidth,
            height: 12,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.centerLeft,
            child: Container(width: barWidth, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          ),
          const SizedBox(width: 8),
          Container(width: 30, alignment: Alignment.centerRight, child: Text(value.toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatefulWidget {
  @override
  State<_WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<_WeatherCard> {
  late Future<Map<String, dynamic>> weatherData;

  Future<Map<String, dynamic>> fetchWeather() async {
    final String cityName = dotenv.env['DEFAULT_CITY']?.trim() ?? "Buon Ma Thuot";
    final String apiKey = dotenv.env['WEATHER_API_KEY']?.trim() ?? "";
    
    // Kiểm tra API Key
    if (apiKey.isEmpty) {
      debugPrint('Weather Error: API Key is missing in .env');
      throw Exception('Thiếu API Key');
    }

    // Sử dụng Uri.https để tự động mã hóa (encode) các tham số, tránh lỗi khoảng trắng
    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': '$cityName,VN',
      'appid': apiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Unknown error';
        debugPrint('Weather API Error ${response.statusCode}: $message');
        throw Exception('Mã lỗi ${response.statusCode}: $message');
      }
    } catch (e) {
      debugPrint('Weather Connection Error: $e');
      if (e is Exception) rethrow;
      throw Exception('Không thể kết nối máy chủ thời tiết');
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeather();
  }

  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: FutureBuilder<Map<String, dynamic>>(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
          if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.white, fontSize: 12)));
          final data = snapshot.data!;
          final temp = data['main']['temp'].round();
          final description = (data['weather'][0]['description'] as String).replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['name'] ?? 'Weather', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const Icon(Icons.cloud_queue, color: Colors.white, size: 28)]),
              const SizedBox(height: 16),
              Text(DateFormat('EEEE, d MMM', 'vi_VN').format(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('$temp°C', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _weatherInfo('Cao/Thấp', '${data['main']['temp_max'].round()}°/${data['main']['temp_min'].round()}°'),
                  _weatherInfo('Cảm giác', '${data['main']['feels_like'].round()}°'),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _weatherInfo(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]);
  }
}

class ExpertOverviewCard extends StatefulWidget {
  const ExpertOverviewCard({Key? key}) : super(key: key);
  @override
  State<ExpertOverviewCard> createState() => _ExpertOverviewCardState();
}

class _ExpertOverviewCardState extends State<ExpertOverviewCard> {
  late Future<Map<String, int>> _expertStatsFuture;
  late Future<List<Map<String, dynamic>>> _topExpertsFuture;

  @override
  void initState() {
    super.initState();
    _expertStatsFuture = _getExpertStats();
    _topExpertsFuture = _getTopRatedExperts();
  }

  Future<Map<String, int>> _getExpertStats() async {
    try {
      final t = await FirebaseFirestore.instance.collection('users').where('role', whereIn: ['expert', 'Expert', 'Chuyên gia']).count().get();
      final o = await FirebaseFirestore.instance.collection('users').where('role', whereIn: ['expert', 'Expert', 'Chuyên gia']).where('isOnline', isEqualTo: true).count().get();
      return {'total': t.count ?? 0, 'online': o.count ?? 0};
    } catch (e) { return {'total': 0, 'online': 0}; }
  }

  Future<List<Map<String, dynamic>>> _getTopRatedExperts() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'expert').orderBy('rating', descending: true).limit(3).get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) { return []; }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: FutureBuilder<Map<String, int>>(
              future: _expertStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data ?? {'total': 0, 'online': 0};
                return Row(
                  children: [
                    Expanded(child: _buildTopStatItem('Chuyên gia', data['total'].toString(), Icons.engineering_rounded, Colors.blue)),
                    Container(width: 1, color: Theme.of(context).dividerColor),
                    Expanded(child: _buildTopStatItem('Đang online', data['online'].toString(), Icons.wifi_rounded, Colors.lightBlue)),
                  ],
                );
              },
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Container(height: 1, color: Theme.of(context).dividerColor)),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Đánh Giá', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _topExpertsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            final experts = snapshot.data ?? [];
                            if (experts.isEmpty) return Center(child: Text('Trống', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)));
                            return ListView.builder(
                              itemCount: experts.length,
                              itemBuilder: (context, index) {
                                final e = experts[index];
                                final r = (e['rating'] as num?)?.toDouble() ?? 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(radius: 12, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, size: 14, color: AppColors.primary)),
                                      const SizedBox(width: 6),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['displayName'] ?? 'Ẩn danh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), maxLines: 1), Text(e['specialty'] ?? 'Chuyên gia', style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodySmall?.color))])),
                                      const Icon(Icons.star, color: Colors.amber, size: 12),
                                      Text(r.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Container(width: 1, color: Theme.of(context).dividerColor)),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tỷ lệ trạng thái', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder<Map<String, int>>(
                          future: _expertStatsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            final stats = snapshot.data ?? {'total': 0, 'online': 0};
                            int total = stats['total'] ?? 0;
                            int online = stats['online'] ?? 0;
                            if (total == 0) return Center(child: Text('Trống', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)));
                            return AspectRatio(
                              aspectRatio: 1.0,
                              child: PieChart(
                                PieChartData(sectionsSpace: 2, centerSpaceRadius: 12, sections: [
                                  PieChartSectionData(value: online.toDouble(), color: Colors.lightBlue, radius: 20, title: '${((online/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface)),
                                  PieChartSectionData(value: (total - online).toDouble(), color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1), radius: 16, title: '${(((total-online)/total)*100).toStringAsFixed(0)}%', titleStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatItem(String title, String value, IconData icon, Color color) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)), Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color))]);
  }
}

class _ProductionOverviewCard extends StatefulWidget {
  const _ProductionOverviewCard({Key? key}) : super(key: key);
  @override
  State<_ProductionOverviewCard> createState() => _ProductionOverviewCardState();
}

class _ProductionOverviewCardState extends State<_ProductionOverviewCard> {
  late Future<Map<String, int>> _orderStatusFuture;

  @override
  void initState() {
    super.initState();
    _orderStatusFuture = _getOrderStatusDistribution();
  }

  Future<Map<String, int>> _getOrderStatusDistribution() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      Map<String, int> statusCounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] as String?) ?? 'Pending';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      return statusCounts;
    } catch (e) {
      return {};
    }
  }

  String _statusToVietnamese(String status) {
    switch (status) {
      case 'Pending': return 'Đang chờ';
      case 'Processing': return 'Đang xử lý';
      case 'In Transit': return 'Đang giao';
      case 'Completed': return 'Hoàn thành';
      case 'Cancelled': return 'Đã hủy';
      case 'Failed': return 'Thất bại';
      default: return status;
    }
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Pending': return Colors.orange;
      case 'Processing': return Colors.blue;
      case 'In Transit': return const Color(0xFF6366F1);
      case 'Cancelled': return Colors.red;
      case 'Failed': return Colors.red.shade900;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phân Bố Đơn Hàng', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: _orderStatusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data ?? {};
                if (data.isEmpty) return Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)));
                final total = data.values.fold(0, (sum, v) => sum + v);
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: data.entries.map((e) => PieChartSectionData(
                                color: _getColorForStatus(e.key),
                                value: e.value.toDouble(),
                                radius: 25,
                                showTitle: false,
                              )).toList(),
                            )),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Tổng', style: AppTextStyles.label.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                                Text(
                                  total.toString(),
                                  style: TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text('đơn', style: AppTextStyles.label.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: data.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: _getColorForStatus(e.key), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_statusToVietnamese(e.key), style: AppTextStyles.label)),
                              Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatefulWidget {
  final String title;
  final Future<String> valueFuture;
  final String subtitle;
  final String prefix;
  const _SmallStatCard({Key? key, required this.title, required this.valueFuture, required this.subtitle, this.prefix = ''}) : super(key: key);
  @override
  State<_SmallStatCard> createState() => _SmallStatCardState();
}

class _SmallStatCardState extends State<_SmallStatCard> {
  late Future<String> _cachedValueFuture;
  @override
  void initState() { super.initState(); _cachedValueFuture = widget.valueFuture; }
  @override
  void didUpdateWidget(covariant _SmallStatCard oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.valueFuture != widget.valueFuture) _cachedValueFuture = widget.valueFuture; }
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.title, style: AppTextStyles.subtitle), const Icon(Icons.show_chart, color: AppColors.primaryLight, size: 20)]),
          const Spacer(),
          FutureBuilder<String>(
            future: _cachedValueFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 30, child: CircularProgressIndicator(strokeWidth: 2));
              return Text('${widget.prefix}${snapshot.data ?? "0"}', style: AppTextStyles.statValue);
            },
          ),
          const SizedBox(height: 8),
          Text(widget.subtitle, style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SalesPriceTrendCard extends StatefulWidget {
  const _SalesPriceTrendCard({Key? key}) : super(key: key);
  @override
  State<_SalesPriceTrendCard> createState() => _SalesPriceTrendCardState();
}

class _SalesPriceTrendCardState extends State<_SalesPriceTrendCard> {
  late Future<Map<String, dynamic>> _priceDataFuture;
  String? _lastCrop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = context.watch<DashboardProvider>().selectedCrop;
    if (_lastCrop != c) { _lastCrop = c; _priceDataFuture = _getPriceData(c); }
  }

  Future<Map<String, dynamic>> _getPriceData(String id) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Price')
          .doc(id)
          .collection('History')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(30)
          .get();

      if (snap.docs.isEmpty) return {'spots': <FlSpot>[], 'labels': <String>[]};

      final docs = snap.docs.toList();
      docs.sort((a, b) => a.id.compareTo(b.id));

      List<FlSpot> spots = [];
      List<String> labels = [];

      for (int i = 0; i < docs.length; i++) {
        final doc = docs[i];
        final dataList = doc.data()['data'] as List<dynamic>? ?? [];
        if (dataList.isEmpty) continue;

        double price = _parsePrice(dataList[0]['price']);
        if (price > 0) {
          spots.add(FlSpot(i.toDouble(), price));
          try {
            final date = DateTime.parse(doc.id);
            labels.add(DateFormat('dd/MM').format(date));
          } catch (_) {
            labels.add(doc.id);
          }
        }
      }
      return {'spots': spots, 'labels': labels};
    } catch (e) {
      return {'spots': <FlSpot>[], 'labels': <String>[]};
    }
  }

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0.0;
    String str = raw.toString().replaceAll(RegExp(r'[^0-9\-]'), '');
    if (str.isEmpty) return 0.0;
    if (str.contains('-')) {
      final parts = str.split('-');
      final p1 = double.tryParse(parts[0]) ?? 0.0;
      final p2 = double.tryParse(parts[1]) ?? 0.0;
      return (p1 + p2) / 2;
    }
    return double.tryParse(str) ?? 0.0;
  }

  Widget build(BuildContext context) {
    final crop = context.read<DashboardProvider>().selectedCrop;
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Expanded(child: Text('Biến động Giá Nông Sản', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
              DropdownButton<String>(
                value: crop,
                underline: const SizedBox(),
                items: const [DropdownMenuItem(value: 'Coffee', child: Text('Cà phê')), DropdownMenuItem(value: 'Pepper', child: Text('Hồ tiêu')), DropdownMenuItem(value: 'Durian', child: Text('Sầu riêng'))],
                onChanged: (v) { if (v != null) context.read<DashboardProvider>().setSelectedCrop(v); },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _priceDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final d = snapshot.data ?? {'spots': <FlSpot>[], 'labels': <String>[]};
                final spots = d['spots'] as List<FlSpot>;
                final labels = d['labels'] as List<String>;
                if (spots.isEmpty) return const Center(child: Text('Chưa có dữ liệu lịch sử'));
                return RepaintBoundary(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10),
                    child: LineChart(
                      key: ValueKey('price_chart_${crop}_${spots.length}'),
                      LineChartData(
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.white.withOpacity(0.9),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((s) {
                                if (s.x.toInt() < 0 || s.x.toInt() >= labels.length) return null;
                                final date = labels[s.x.toInt()];
                                return LineTooltipItem(
                                  '$date: ${NumberFormat('#,###').format(s.y)}đ',
                                  const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5000,
                          getDrawingHorizontalLine: (v) => FlLine(color: Theme.of(context).dividerColor.withOpacity(0.5), strokeWidth: 1, dashArray: [5, 5]),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              getTitlesWidget: (v, m) {
                                int index = v.toInt();
                                if (index < 0 || index >= labels.length) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(labels[index], style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: 5000,
                              getTitlesWidget: (v, m) {
                                double valInK = v / 1000;
                                return Text('${valInK.toStringAsFixed(1)}k', style: AppTextStyles.label);
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularDiseaseMentionCard extends StatefulWidget {
  const _PopularDiseaseMentionCard({Key? key}) : super(key: key);
  @override
  State<_PopularDiseaseMentionCard> createState() => _PopularDiseaseMentionCardState();
}

class _PopularDiseaseMentionCardState extends State<_PopularDiseaseMentionCard> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  @override
  void initState() { super.initState(); _categoriesFuture = _fetchTopCategories(); }

  Future<List<Map<String, dynamic>>> _fetchTopCategories() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('ai_chat_logs')
          .get();
      
      // Aggregate by category_tag
      Map<String, int> categoryCounts = {};
      for (var doc in snap.docs) {
        final data = doc.data();
        final tag = (data['category_tag'] as String?) ?? 'Khác';
        categoryCounts[tag] = (categoryCounts[tag] ?? 0) + 1;
      }
      
      // Sort by count descending, take top 5
      final sorted = categoryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sorted.take(5).map((e) => {
        'name': e.key,
        'count': e.value,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chủ Đề AI Phổ Biến', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data ?? [];
                if (items.isEmpty) return Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)));
                final maxV = items.first['count'] as int;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: Text(item['name'], 
                              style: AppTextStyles.bodyText.copyWith(color: Theme.of(context).colorScheme.onSurface), 
                              overflow: TextOverflow.ellipsis)),
                            Text(item['count'].toString(), 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                          ]),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: item['count'] / maxV, backgroundColor: Theme.of(context).dividerColor, color: Theme.of(context).colorScheme.primary, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldImageCard extends StatefulWidget {
  const _FieldImageCard({Key? key}) : super(key: key);
  @override
  State<_FieldImageCard> createState() => _FieldImageCardState();
}

class _FieldImageCardState extends State<_FieldImageCard> {
  late Future<List<Map<String, dynamic>>> _recentOrdersFuture;

  @override
  void initState() {
    super.initState();
    _recentOrdersFuture = _fetchRecentOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchRecentOrders() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        // Fallback sequence for name: customerName -> userName -> displayName -> Order ID
        final String name = data['customerName'] ?? 
                           data['userName'] ?? 
                           data['displayName'] ?? 
                           'Đơn #${doc.id.substring(0, 5).toUpperCase()}';
                           
        return {
          'id': doc.id,
          'customerName': name,
          'totalAmount': data['totalAmount'] ?? 0,
          'status': data['status'] ?? 'Pending',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _statusToVietnamese(String status) {
    switch (status) {
      case 'Pending': return 'Đang chờ';
      case 'Processing': return 'Đang xử lý';
      case 'In Transit': return 'Đang giao';
      case 'Completed': return 'Hoàn thành';
      case 'Cancelled': return 'Đã hủy';
      case 'Failed': return 'Thất bại';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Pending': return Colors.orange;
      case 'Processing': return Colors.blue;
      case 'In Transit': return const Color(0xFF6366F1);
      case 'Cancelled': case 'Failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _recentOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }
            final orders = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đơn Hàng Gần Đây', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text('${orders.length} đơn mới nhất', 
                        style: AppTextStyles.label.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                if (orders.isEmpty)
                  SizedBox(height: 200, child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))))
                else
                  ...orders.map((order) {
                    final amount = (order['totalAmount'] is num)
                        ? (order['totalAmount'] as num).toDouble()
                        : double.tryParse(order['totalAmount'].toString()) ?? 0;
                    final date = order['createdAt'] as DateTime?;
                    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';
                    final status = order['status'] as String;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.shopping_bag_outlined, color: _getStatusColor(status), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order['customerName'], 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface
                                  ), 
                                  overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(dateStr, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${amount.toStringAsFixed(0)} đ', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface
                                )),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(_statusToVietnamese(status), style: TextStyle(fontSize: 11, color: _getStatusColor(status), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlatformStatCard extends StatefulWidget {
  final String title;
  final Future<int> valueFuture;
  final IconData icon;
  final Color color;
  const _PlatformStatCard({Key? key, required this.title, required this.valueFuture, required this.icon, required this.color}) : super(key: key);
  @override
  State<_PlatformStatCard> createState() => _PlatformStatCardState();
}

class _PlatformStatCardState extends State<_PlatformStatCard> {
  late Future<int> _cachedValueFuture;
  @override
  void initState() { super.initState(); _cachedValueFuture = widget.valueFuture; }
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.title, style: AppTextStyles.subtitle), Icon(widget.icon, color: widget.color, size: 24)]),
          const Spacer(),
          FutureBuilder<int>(
            future: _cachedValueFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 30, child: CircularProgressIndicator(strokeWidth: 2));
              return Text(snapshot.data?.toString() ?? '0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface));
            },
          ),
          const SizedBox(height: 8),
          Text('Cập nhật realtime', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
        ],
      ),
    );
  }
}