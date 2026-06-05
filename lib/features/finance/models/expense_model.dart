import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Khác',
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
    );
  }
}
