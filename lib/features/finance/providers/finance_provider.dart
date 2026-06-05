import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/revenue_model.dart';
import '../services/finance_service.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceService _service = FinanceService();

  List<ExpenseModel> _expenses = [];
  List<RevenueModel> _revenues = [];
  List<RevenueModel> _ordersRevenuesList = [];
  List<RevenueModel> _upgradesRevenuesList = [];
  
  double _ordersRevenue = 0;
  double _upgradesRevenue = 0;
  double _totalGrossRevenue = 0;
  
  bool _isLoading = true;

  StreamSubscription? _expenseSub;
  StreamSubscription? _revenueSub;
  StreamSubscription? _upgradesSub;
  
  StreamSubscription? _ordersRevListSub;
  StreamSubscription? _upgradesRevListSub;

  FinanceProvider() {
    _init();
  }

  void _init() {
    _expenseSub = _service.streamExpenses().listen((expenses) {
      _expenses = expenses;
      _isLoading = false;
      notifyListeners();
    });

    _revenueSub = _service.streamGrossRevenue().listen((revenue) {
      _ordersRevenue = revenue;
      _updateTotal();
    });

    _upgradesSub = _service.streamUpgradesRevenue().listen((revenue) {
      _upgradesRevenue = revenue;
      _updateTotal();
    });
    
    _ordersRevListSub = _service.streamOrdersRevenues().listen((list) {
      _ordersRevenuesList = list;
      _updateRevenuesList();
    });
    
    _upgradesRevListSub = _service.streamUpgradesRevenuesList().listen((list) {
      _upgradesRevenuesList = list;
      _updateRevenuesList();
    });
  }

  void _updateTotal() {
    _totalGrossRevenue = _ordersRevenue + _upgradesRevenue;
    notifyListeners();
  }
  
  void _updateRevenuesList() {
    _revenues = [..._ordersRevenuesList, ..._upgradesRevenuesList];
    _revenues.sort((a, b) => b.date.compareTo(a.date)); // Mới nhất lên đầu
    notifyListeners();
  }

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  List<RevenueModel> get revenues => _revenues;
  double get totalGrossRevenue => _totalGrossRevenue;
  bool get isLoading => _isLoading;

  double get totalExpenses {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  double get netProfit {
    return _totalGrossRevenue - totalExpenses;
  }

  // Actions
  Future<void> addExpense(ExpenseModel expense) async {
    await _service.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _service.deleteExpense(id);
  }

  @override
  void dispose() {
    _expenseSub?.cancel();
    _revenueSub?.cancel();
    _upgradesSub?.cancel();
    _ordersRevListSub?.cancel();
    _upgradesRevListSub?.cancel();
    super.dispose();
  }
}
