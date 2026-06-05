import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueModel {
  final String id;
  final double amount;
  final String source;
  final DateTime date;
  final String description;

  RevenueModel({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.description,
  });
}
