import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../finance/models/expense_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Business Overview Data ---

  Future<Map<String, dynamic>> getBusinessOverview() async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      final snapshot = await _db.collection('orders').get();

      double totalRevenue = 0;
      int totalOrders = snapshot.docs.length;
      int todayOrders = 0;
      double todayRevenue = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final dynamic rawAmount = data['totalAmount'] ?? 0;
        double amount = 0;
        if (rawAmount is num) {
          amount = rawAmount.toDouble();
        } else if (rawAmount is String) {
          amount = double.tryParse(rawAmount) ?? 0;
        }

        totalRevenue += amount;

        if (createdAt != null && createdAt.isAfter(startOfToday)) {
          todayOrders++;
          todayRevenue += amount;
        }
      }

      // Build a product name lookup map to resolve names from IDs
      final productSnap = await _db.collection('products').get();
      Map<String, String> productIdToName = {
        for (var d in productSnap.docs) d.id: d.data()['name'] ?? 'Sản phẩm không tên'
      };

      // Top products ranking: Aggregated from orders by 'number of distinct orders'
      Map<String, int> orderCounts = {}; // Count of orders the product appears in
      for (var doc in snapshot.docs) {
        final items = doc.data()['items'] as List?;
        if (items == null) continue;
        
        Set<String> distinctProductsInOrder = {};
        for (var item in items) {
          final id = item['productId'] as String?;
          final name = item['productName'] ?? (id != null ? productIdToName[id] : null) ?? 'Sản phẩm lỗi (#${doc.id.substring(0,4)})';
          distinctProductsInOrder.add(name);
        }
        
        for (var pName in distinctProductsInOrder) {
          orderCounts[pName] = (orderCounts[pName] ?? 0) + 1;
        }
      }

      final sortedProducts = orderCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topProducts = sortedProducts.take(3).map((e) => {
        'name': e.key,
        'quantitySold': e.value, // Hold order count for UI compatibility
      }).toList();

      // 7-day revenue trend calculation
      Map<int, double> dailyRevenue = {};
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final startOfSevenDaysAgo = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null || createdAt.isBefore(startOfSevenDaysAgo)) continue;

        final dynamic rawAmount = data['totalAmount'] ?? 0;
        double amount = (rawAmount is num) ? rawAmount.toDouble() : double.tryParse(rawAmount.toString()) ?? 0;
        
        int daysAgo = DateTime.now().difference(DateTime(createdAt.year, createdAt.month, createdAt.day)).inDays;
        if (daysAgo >= 0 && daysAgo < 7) {
          dailyRevenue[daysAgo] = (dailyRevenue[daysAgo] ?? 0) + amount;
        }
      }

      List<double> revenueTrend = List.generate(7, (index) => dailyRevenue[6 - index] ?? 0.0);

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'todayOrders': todayOrders,
        'todayRevenue': todayRevenue,
        'revenueTrend': revenueTrend,
        'topProducts': topProducts,
      };
    } catch (e) {
      debugPrint('ReportService Error (Business): $e');
      return {};
    }
  }

  // --- Agriculture & Experts Data ---

  Future<Map<String, dynamic>> getAgriExpertStats() async {
    try {
      final appointments = await _db.collection('appointments').get();
      final products = await _db.collection('products').get();

      int activeExperts = await _db
          .collection('users')
          .where('role', isEqualTo: 'expert')
          .where('isBanned', isEqualTo: false)
          .get()
          .then((s) => s.docs.length);

      return {
        'totalAppointments': appointments.docs.length,
        'activeExperts': activeExperts,
        'totalProducts': products.docs.length,
        'agriProducts': products.docs
            .where(
              (d) =>
                  d.data()['category']?.toString().toLowerCase().contains(
                    'nông sản',
                  ) ??
                  false,
            )
            .length,
      };
    } catch (e) {
      debugPrint('ReportService Error (Agri): $e');
      return {};
    }
  }

  // --- AI System & Health (Important) ---

  Future<List<Map<String, dynamic>>> getLatestAlerts() async {
    try {
      final snapshot = await _db
          .collection('ai_alerts')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('ReportService Error (Alerts): $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLatestInsights() async {
    try {
      final snapshot = await _db
          .collection('ai_insights')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('ReportService Error (Insights): $e');
      return [];
    }
  }

  Stream<Map<String, dynamic>> getAISystemStatsStream() {
    return _db
        .collection('ai_system_health')
        .doc('current_metrics')
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return {
              'successRate': 100,
              'fallbackPercent': 0.0,
              'avgResponseTime': 0.0,
              'popularQuestions': [],
              'totalQuestions': 0,
            };
          }

          final data = doc.data()!;
          final fallbackPercent = (data['fallbackPercent'] ?? 0.0).toDouble();
          final topQuestions = data['topQuestions'] as List? ?? [];

          return {
            'totalQuestions': data['totalQuestions'] ?? 0,
            'successRate': (100 - fallbackPercent).round(),
            'fallbackPercent': fallbackPercent.round(),
            'popularQuestions': topQuestions
                .map(
                  (e) => {
                    'query': _capitalize(e['query'] ?? ''),
                    'hits': e['hits'] ?? 0,
                  },
                )
                .toList(),
            'avgResponseTime': (data['avgResponseTime'] ?? 0.0).toDouble(),
          };
        });
  }

  Future<Map<String, dynamic>> getAISystemStats() async {
    try {
      // READ ONLY: Architecture-mandated single document fetch
      final doc = await _db
          .collection('ai_system_health')
          .doc('current_metrics')
          .get();

      if (!doc.exists) {
        return {
          'successRate': 100,
          'fallbackPercent': 0.0,
          'avgResponseTime': 0.0,
          'popularQuestions': [], // UI will show "Chưa có đủ dữ liệu thống kê"
          'totalQuestions': 0,
        };
      }

      final data = doc.data()!;
      final fallbackPercent = (data['fallbackPercent'] ?? 0.0).toDouble();
      final topQuestions = data['topQuestions'] as List? ?? [];

      return {
        'totalQuestions': data['totalQuestions'] ?? 0,
        'successRate': (100 - fallbackPercent).round(),
        'fallbackPercent': fallbackPercent.round(),
        'popularQuestions': topQuestions
            .map(
              (e) => {
                'query': _capitalize(e['query'] ?? ''),
                'hits': e['hits'] ?? 0,
              },
            )
            .toList(),
        'avgResponseTime': (data['avgResponseTime'] ?? 0.0).toDouble(),
      };
    } catch (e) {
      debugPrint('ReportService Error (Aggregation): $e');
      return {
        'successRate': 0,
        'fallbackPercent': 0.0,
        'totalQuestions': 0,
        'popularQuestions': [],
      };
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // --- Export Data Fetching ---

  /// Fetches all orders within a specific date range
  Future<List<Map<String, dynamic>>> fetchAllOrders({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      Query query = _db
          .collection('orders')
          .orderBy('createdAt', descending: true);

      if (start != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        );
      }
      if (end != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(end),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
              'createdAt': (doc.data() as Map<String, dynamic>)['createdAt']
                  ?.toDate(),
            },
          )
          .toList();
    } catch (e) {
      debugPrint('ReportService Error (FetchOrders): $e');
      return [];
    }
  }

  /// Fetches all expenses within a specific date range
  Future<List<ExpenseModel>> fetchAllExpenses({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      Query query = _db
          .collection('expenses')
          .orderBy('date', descending: true);

      if (start != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        );
      }
      if (end != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(end),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ExpenseModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('ReportService Error (FetchExpenses): $e');
      return [];
    }
  }
}
