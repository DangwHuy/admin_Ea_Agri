import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/revenue_model.dart';

class FinanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream current expenses
  Stream<List<ExpenseModel>> streamExpenses() {
    return _db
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a new expense record
  Future<void> addExpense(ExpenseModel expense) async {
    await _db.collection('expenses').add(expense.toMap());
  }

  // Delete an expense record (utility for the UI)
  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
  }

  // Stream completed orders to calculate gross revenue
  Stream<double> streamGrossRevenue() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dynamic rawAmount = data['totalAmount'] ?? 0;
        if (rawAmount is num) {
          total += rawAmount.toDouble();
        } else if (rawAmount is String) {
          total += double.tryParse(rawAmount) ?? 0;
        }
      }
      return total;
    });
  }

  // Stream approved upgrades to add to gross revenue
  Stream<double> streamUpgradesRevenue() {
    return _db
        .collection('upgrade_requests')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dynamic rawAmount = data['amount'] ?? 0;
        if (rawAmount is num) {
          total += rawAmount.toDouble();
        } else if (rawAmount is String) {
          total += double.tryParse(rawAmount) ?? 0;
        }
      }
      return total;
    });
  }

  // Stream list of revenues from orders
  Stream<List<RevenueModel>> streamOrdersRevenues() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dynamic rawAmount = data['totalAmount'] ?? 0;
        double amount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse(rawAmount.toString()) ?? 0);
        final Timestamp? ts = data['createdAt'] as Timestamp?;
        final date = ts?.toDate() ?? DateTime.now();
        return RevenueModel(
          id: doc.id,
          amount: amount,
          source: 'Bán Nông Sản',
          date: date,
          description: 'Đơn hàng ${data['customerName'] ?? doc.id}',
        );
      }).toList();
    });
  }

  // Stream list of revenues from upgrades
  Stream<List<RevenueModel>> streamUpgradesRevenuesList() {
    return _db
        .collection('upgrade_requests')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dynamic rawAmount = data['amount'] ?? 0;
        double amount = rawAmount is num ? rawAmount.toDouble() : (double.tryParse(rawAmount.toString()) ?? 0);
        final Timestamp? ts = data['approvedAt'] as Timestamp?;
        final date = ts?.toDate() ?? DateTime.now();
        return RevenueModel(
          id: doc.id,
          amount: amount,
          source: 'Gói Hội Viên',
          date: date,
          description: 'Nâng cấp gói ${data['requestedTier'] ?? ''} - ID: ${data['userId']}',
        );
      }).toList();
    });
  }
}
