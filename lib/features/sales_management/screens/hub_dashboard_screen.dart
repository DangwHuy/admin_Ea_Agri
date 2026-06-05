import 'dart:async';
import 'package:flutter/material.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/constants/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_daklak_web/features/sales_management/widgets/create_order_dialog.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

// --- Shared Theme Information ---
// Theme-aware color constants logic moved into build or resolved via helpers
const Color _infoBlue = Color(0xFF2196F3);
const Color _primaryGreen = Color(0xFF43A047);
const Color _warningOrange = Color(0xFFFF9800);

void _showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
    ),
  );
}

class HubDashboardScreen extends StatefulWidget {
  const HubDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HubDashboardScreen> createState() => _HubDashboardScreenState();
}

class _HubDashboardScreenState extends State<HubDashboardScreen> {
  void _openCreateOrderDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const CreateOrderDialog(),
    );
    // Refresh triggered automatically if needed or stream handles it.
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(
              onCreateOrder: _openCreateOrderDialog,
            ),
            const SizedBox(height: 24),
            const _KPISection(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: _ChartSection()),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: const [
                      _TopProductsSection(),
                      SizedBox(height: 24),
                      _ProblematicOrdersSection(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _NavigationGridSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- Independent Child Sections ---

class _HeaderSection extends StatelessWidget {
  final VoidCallback onCreateOrder;

  const _HeaderSection({
    Key? key,
    required this.onCreateOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý Đơn hàng',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tổng quan hoạt động bán hàng và đơn hàng nông sản.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onCreateOrder,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: Text('Tạo đơn hàng', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KPISection extends StatelessWidget {
  const _KPISection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        double todayRev = 0;
        int newOrders = 0;
        int inTransit = 0;
        int pendingCancelled = 0;

        if (snapshot.hasData) {
          final now = DateTime.now();

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            final status = data['status'] ?? '';

            // Today's metrics - using robust date comparison
            if (createdAt != null) {
              final bool isSameDay = createdAt.year == now.year && 
                                   createdAt.month == now.month && 
                                   createdAt.day == now.day;
              
              if (isSameDay) {
                // Defensive parsing handles both num and String types from Firestore
                final dynamic rawAmount = data['totalAmount'] ?? 0;
                double totalAmount = 0;
                if (rawAmount is num) {
                  totalAmount = rawAmount.toDouble();
                } else if (rawAmount is String) {
                  totalAmount = double.tryParse(rawAmount) ?? 0;
                }
                
                todayRev += totalAmount;
                newOrders += 1;
              }
            }

            // Global status metrics — match exact Firestore values
            if (status == 'In Transit') {
              inTransit += 1;
            } else if (status == 'Pending' || status == 'Cancelled') {
              pendingCancelled += 1;
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _KPICard(
                title: 'Doanh thu hôm nay',
                value: '${todayRev.toStringAsFixed(0)} đ',
                subtitle: 'Tổng giá trị đơn hàng trong ngày',
                trend: '● Trực tiếp',
                isPositiveChange: true,
                icon: Icons.account_balance_wallet_rounded,
                iconBgColor: Theme.of(context).primaryColor.withOpacity(0.1),
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KPICard(
                title: 'Đơn hàng mới',
                value: '$newOrders',
                subtitle: 'Số đơn hàng tạo mới từ nửa đêm',
                trend: '● Trực tiếp',
                isPositiveChange: true,
                icon: Icons.shopping_cart_rounded,
                iconBgColor: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KPICard(
                title: 'Đang vận chuyển',
                value: '$inTransit',
                subtitle: 'Đơn hàng đang giao cho khách',
                trend: inTransit > 0 ? '● Đang giao' : '○ Trống',
                isPositiveChange: true,
                icon: Icons.local_shipping_rounded,
                iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
                iconColor: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KPICard(
                title: 'Cần chú ý',
                value: '$pendingCancelled',
                subtitle: 'Đơn hàng chờ hoặc đã hủy',
                trend: pendingCancelled > 0 ? '⚠ Xem ngay' : '✓ Đã xử lý',
                isPositiveChange: pendingCancelled == 0,
                icon: Icons.notifications_active_rounded,
                iconBgColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
                iconColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartSection extends StatefulWidget {
  const _ChartSection({Key? key}) : super(key: key);

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  bool _isShowingRevenue = true;
  late Future<List<Map<String, dynamic>>> _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = _fetchDailyStats();
  }

  Future<List<Map<String, dynamic>>> _fetchDailyStats() async {
    List<Map<String, dynamic>> results = [];
    DateTime now = DateTime.now();
    
    // Fetch last 7 days.
    for (int i = 0; i < 7; i++) {
      DateTime d = now.subtract(Duration(days: i));
      String docId = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      var doc = await FirebaseFirestore.instance.collection('daily_stats').doc(docId).get();
      
      Map<String, dynamic> dayData = {'revenue': 0, 'orders': 0};
      
      if (doc.exists) {
        dayData = Map<String, dynamic>.from(doc.data()!);
      }

      // --- Live Fallback Integration ---
      // If it's "Today" (i=0) and the aggregation is missing or zero, 
      // we query the raw 'orders' collection to ensure the chart reflects real-time changes.
      if (i == 0 && (dayData['orders'] == 0 || dayData['revenue'] == 0)) {
        try {
          // Robust date range for "Today"
          final startOfToday = DateTime(now.year, now.month, now.day);
          final snapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
              .get();
          
          double liveRev = 0;
          int liveOrders = 0;
          
          for (var orderDoc in snapshot.docs) {
            final data = orderDoc.data();
            final dynamic rawAmount = data['totalAmount'] ?? 0;
            double amount = 0;
            if (rawAmount is num) {
              amount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              amount = double.tryParse(rawAmount) ?? 0;
            }
            
            liveRev += amount;
            liveOrders += 1;
          }
          
          // Only override if we actually found something in the raw stream
          if (liveOrders > 0) {
            dayData['revenue'] = liveRev;
            dayData['orders'] = liveOrders;
          }
        } catch (e) {
          debugPrint('Chart Live Fallback Error: $e');
        }
      }
      
      results.add({"id": docId, "data": dayData});
    }
    
    // We fetched from newest (today) to oldest (7 days ago).
    // The chart expects oldest first, so we reverse it.
    return results.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiệu suất kinh doanh 7 ngày qua',
                style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {
                      setState(() {
                        _chartFuture = _fetchDailyStats();
                      });
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: AppColors.darkBorder.withOpacity(0.5)) : null,
                    ),
                    child: Row(
                      children: [
                        _buildChartToggleButton('Doanh thu', true),
                        _buildChartToggleButton('Đơn hàng', false),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _chartFuture,
            builder: (context, snapshot) {
              final borderColor = Theme.of(context).dividerColor;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi Firebase: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData) {
                return const SizedBox(height: 300, child: Center(child: Text("Không có dữ liệu biểu đồ.")));
              }

              final stats = snapshot.data!;
              List<FlSpot> spots = [];
              double maxValue = 0;
              List<String> dates = [];

              for (int i = 0; i < stats.length; i++) {
                final data = stats[i]['data'];
                dates.add(stats[i]['id'].toString().substring(5));
                
                double val = 0;
                if (_isShowingRevenue) {
                  val = (data['revenue'] ?? 0) is num ? (data['revenue'] as num).toDouble() : double.tryParse(data['revenue'].toString()) ?? 0;
                } else {
                  val = (data['orders'] ?? 0) is num ? (data['orders'] as num).toDouble() : double.tryParse(data['orders'].toString()) ?? 0;
                }
                
                spots.add(FlSpot(i.toDouble(), val));
                if (val > maxValue) maxValue = val;
              }

              if (maxValue == 0) maxValue = 10;
              
              if (spots.length < 7) {
                 int missing = 7 - spots.length;
                 for(int i = 0; i < missing; i++) {
                     DateTime fakeDate = DateTime.now().subtract(Duration(days: 6 - i));
                     dates.insert(i, "${fakeDate.month.toString().padLeft(2, '0')}-${fakeDate.day.toString().padLeft(2, '0')}");
                     spots.insert(i, FlSpot(i.toDouble(), 0));
                 }
                 for(int i = missing; i < 7; i++){
                     spots[i] = FlSpot(i.toDouble(), spots[i].y);
                 }
              }

              return SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue / 4,
                      getDrawingHorizontalLine: (_) => FlLine(color: borderColor.withOpacity(0.5), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                           getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < dates.length) {
                               return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(dates[value.toInt()], style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (maxValue / 4) == 0 ? 1 : (maxValue / 4),
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                             if (value == 0) return const Text('');
                            return Text(
                               _formatValue(value),
                               style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxValue * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                         isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Theme.of(context).primaryColor, strokeWidth: 2, strokeColor: Colors.white)),
                        belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }

  Widget _buildChartToggleButton(String label, bool isRevenueBtn) {
    final isSelected = isRevenueBtn == _isShowingRevenue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => _isShowingRevenue = isRevenueBtn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCardBg : Theme.of(context).colorScheme.surface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Phân tích sản phẩm bán chạy', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('product_stats').orderBy('quantitySold', descending: true).limit(2).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              
              // Fallback logic: If product_stats is empty, try to show products from the main collection
              final bool hasStats = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
              
              if (!hasStats) {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('products').limit(2).get(),
                  builder: (context, prodSnapshot) {
                    if (prodSnapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                    if (!prodSnapshot.hasData || prodSnapshot.data!.docs.isEmpty) {
                      return Padding(padding: const EdgeInsets.all(8.0), child: Text("Không tìm thấy dữ liệu sản phẩm.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)));
                    }
                    
                    return _buildProductList(context, prodSnapshot.data!.docs, isStats: false);
                  },
                );
              }

              return _buildProductList(context, snapshot.data!.docs, isStats: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<QueryDocumentSnapshot> docs, {required bool isStats}) {
    return Column(
      children: docs.asMap().entries.map((entry) {
        int idx = entry.key;
        var data = entry.value.data() as Map<String, dynamic>;
        String name = data['name'] ?? entry.value.id;
        
        String detailText;
        if (isStats) {
          int sold = (data['quantitySold'] ?? 0) is num ? (data['quantitySold'] as num).toInt() : 0;
          detailText = '$sold đã bán';
        } else {
          // If no stats, display category or just a placeholder
          detailText = data['category'] ?? 'Sản phẩm';
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: idx == 0 ? Colors.amber.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceVariant, 
                  shape: BoxShape.circle
                ),
                child: Text('#${idx + 1}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: idx == 0 ? Colors.amber[800] : Theme.of(context).textTheme.bodySmall?.color)),
              ),
              const SizedBox(width: 12),
              Text(detailText, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProblematicOrdersSection extends StatelessWidget {
  const _ProblematicOrdersSection({Key? key}) : super(key: key);

  static const int _maxVisibleItems = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Text('Đơn hàng cần xử lý', style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').where('status', whereIn: ['Cancelled', 'Failed']).orderBy('createdAt', descending: true).limit(10).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              if (snapshot.hasError) return Text("Lỗi khi tải danh sách vấn đề.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(padding: const EdgeInsets.all(8.0), child: Text("Không có vấn đề gì. Hệ thống ổn định!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.w500)));
              }

              final allDocs = snapshot.data!.docs;
              final visibleDocs = allDocs.take(_maxVisibleItems).toList();
              final hasMore = allDocs.length > _maxVisibleItems;

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: visibleDocs.length,
                        itemBuilder: (context, index) {
                          final doc = visibleDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] as String? ?? 'Thất bại';
                          final color = (status == 'Cancelled' || status == 'Đã hủy') ? Colors.orange : Theme.of(context).colorScheme.error;
                          String displayStatus = status;
                          if (status == 'Cancelled') displayStatus = 'Đã hủy';
                          else if (status == 'Failed') displayStatus = 'Thất bại';
                          else if (status == 'Pending') displayStatus = 'Đang chờ';
                          else if (status == 'Processing') displayStatus = 'Đang xử lý';
                          else if (status == 'In Transit') displayStatus = 'Đang giao';
                          else if (status == 'Completed') displayStatus = 'Hoàn thành';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(isDark ? 0.1 : 0.05),
                              border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.2)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(displayStatus, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
                                      const SizedBox(height: 4),
                                      Text('#${doc.id.substring(0, 8).toUpperCase()}', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showToast(context, 'Đang kiểm tra đơn hàng: ${doc.id}'),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                  child: Text('Kiểm tra', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (hasMore) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showToast(context, 'Mở danh sách đầy đủ đơn hàng cần xử lý'),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: Text('Xem tất cả (${allDocs.length})'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



// --- Generic Helpers ---

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trend;
  final bool isPositiveChange;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _KPICard({
    required this.title,
    required this.value,
    this.subtitle = '',
    required this.trend,
    required this.isPositiveChange,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Row(
                children: [
                  Text(
                    trend,
                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositiveChange ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
          if (subtitle.isNotEmpty) ...[  
            const SizedBox(height: 2),
               Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;

  const _DashboardCard({required this.child, required this.padding});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        child: GlassContainer(
          padding: widget.padding,
          borderRadius: BorderRadius.circular(16),
          child: widget.child,
        ),
      ),
    );
  }
}

class _NavigationGridSection extends StatelessWidget {
  const _NavigationGridSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân hệ nhanh',
          style: AppTextStyles.heading3.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.0, // Wider
          children: [
            const _NavCard(
              title: 'Quản lý Đơn hàng',
              icon: Icons.inventory_2_rounded,
              color: _infoBlue,
              route: '/orders',
            ),
            const _NavCard(
              title: 'Sản phẩm Nông sản',
              icon: Icons.eco_rounded,
              color: _primaryGreen,
              route: '/products',
            ),
            const _NavCard(
              title: 'Khuyến mãi & Voucher',
              icon: Icons.card_giftcard_rounded,
              color: _warningOrange,
              route: '/promotions',
            ),
            const _NavCard(
              title: 'Tài chính & Phân quyền',
              icon: Icons.account_balance_wallet_rounded,
              color: Color(0xFF6366F1),
              route: '/finance',
            ),
          ],
        )
      ],
    );
  }
}

class _NavCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovering ? -2 : 0, 0),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering ? widget.color : Colors.white.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.6),
              width: _isHovering ? 2 : 0.5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 36, color: widget.color),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
