import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditActionType {
  create,
  update,
  delete,
  login,
  export,
  security;

  String get label {
    switch (this) {
      case AuditActionType.create: return 'THÊM MỚI';
      case AuditActionType.update: return 'CẬP NHẬT';
      case AuditActionType.delete: return 'XÓA';
      case AuditActionType.login: return 'ĐĂNG NHẬP';
      case AuditActionType.export: return 'XUẤT FILE';
      case AuditActionType.security: return 'BẢO MẬT';
    }
  }
}

enum AuditModule {
  orders,
  products,
  aichat,
  finance,
  users,
  settings,
  dashboard;

  String get label {
    switch (this) {
      case AuditModule.orders: return 'Đơn hàng';
      case AuditModule.products: return 'Sản phẩm';
      case AuditModule.aichat: return 'AI Chat';
      case AuditModule.finance: return 'Tài chính';
      case AuditModule.users: return 'Tài khoản';
      case AuditModule.settings: return 'Cài đặt';
      case AuditModule.dashboard: return 'Hệ thống';
    }
  }
}

class AuditLogModel {
  final String id;
  final String adminId;
  final String adminEmail;
  final AuditActionType actionType;
  final AuditModule module;
  final String description;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
  final String ipAddress;

  AuditLogModel({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.actionType,
    required this.module,
    required this.description,
    this.details,
    required this.timestamp,
    required this.ipAddress,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      actionType: AuditActionType.values.byName(data['actionType'] ?? 'security'),
      module: AuditModule.values.byName(data['module'] ?? 'dashboard'),
      description: data['description'] ?? '',
      details: data['details'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      ipAddress: data['ipAddress'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminEmail': adminEmail,
      'actionType': actionType.name,
      'module': module.name,
      'description': description,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': ipAddress,
    };
  }
}
