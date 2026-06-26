import 'package:cloud_firestore/cloud_firestore.dart';

class UpgradeRequestModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userDisplayName;
  final String requestedTier;
  final double amount;
  final String status;
  final String? transferCode;
  final String? adminMessage;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  UpgradeRequestModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userDisplayName,
    required this.requestedTier,
    required this.amount,
    required this.status,
    this.transferCode,
    this.adminMessage,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
  });

  factory UpgradeRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UpgradeRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userDisplayName: data['userDisplayName'] ?? '',
      requestedTier: data['requestedTier'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      transferCode: data['transferCode'],
      adminMessage: data['adminMessage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
    );
  }
}
