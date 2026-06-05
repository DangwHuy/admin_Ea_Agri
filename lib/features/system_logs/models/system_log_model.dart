import 'package:cloud_firestore/cloud_firestore.dart';

class SystemLogModel {
  final String id;
  final DateTime createdAt;
  final String actorName;
  final String action;
  final String details;
  final String? ipAddress;
  final String status;

  SystemLogModel({
    required this.id,
    required this.createdAt,
    required this.actorName,
    required this.action,
    required this.details,
    this.ipAddress,
    required this.status,
  });

  factory SystemLogModel.fromFirestore(Map<String, dynamic> json, String id) {
    // Robust parsing with legacy fallbacks
    DateTime parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = (json['createdAt'] as Timestamp).toDate();
    } else if (json['timestamp'] != null) {
      parsedDate = (json['timestamp'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    // Mapping legacy actionType enum names to readable labels
    String actionLabel = json['action'] ?? json['actionType'] ?? 'Không xác định';
    if (actionLabel == 'create') actionLabel = 'Thêm';
    if (actionLabel == 'update') actionLabel = 'Sửa';
    if (actionLabel == 'delete') actionLabel = 'Xóa';
    if (actionLabel == 'login') actionLabel = 'Đăng nhập';
    if (actionLabel == 'export') actionLabel = 'Xuất file';
    if (actionLabel == 'security') actionLabel = 'Bảo mật';

    // Robust details parsing (handles Map from legacy AuditLogModel)
    String detailsText = '';
    final rawDetails = json['details'];
    final rawDescription = json['description'];

    if (rawDetails is String) {
      detailsText = rawDetails;
    } else if (rawDescription is String) {
      // Prefer string description if details is a Map or missing
      detailsText = rawDescription;
    } else if (rawDetails is Map) {
      detailsText = rawDetails.toString();
    }

    return SystemLogModel(
      id: id,
      createdAt: parsedDate,
      actorName: json['actorName'] ?? json['adminEmail'] ?? 'Hệ thống',
      action: actionLabel,
      details: detailsText,
      ipAddress: json['ipAddress']?.toString(),
      status: json['status']?.toString() ?? 'Thành công',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(createdAt), // Keep both for safety/legacy
      'createdAt': Timestamp.fromDate(createdAt),
      'actorName': actorName,
      'action': action,
      'details': details,
      'ipAddress': ipAddress,
      'status': status,
    };
  }
}
