import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  system,
  order,
  alert,
  aiError,
  lowStock,
  verification,
  finance,
  market,
  moderation;

  String get label {
    switch (this) {
      case NotificationType.system:
        return 'Hệ thống';
      case NotificationType.order:
        return 'Đơn hàng';
      case NotificationType.alert:
        return 'Cảnh báo';
      case NotificationType.aiError:
        return 'Lỗi AI';
      case NotificationType.lowStock:
        return 'Sắp hết hàng';
      case NotificationType.verification:
        return 'Xác thực chuyên gia';
      case NotificationType.finance:
        return 'Tài chính';
      case NotificationType.market:
        return 'Thị trường';
      case NotificationType.moderation:
        return 'Báo cáo người dùng';
    }
  }
}

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;
  final String? targetRoute;
  final Map<String, dynamic>? metadata;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.targetRoute,
    this.metadata,
  });

  factory AdminNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'];
    
    // Safety check for NotificationType (Enum robustness)
    NotificationType safeType;
    try {
      safeType = NotificationType.values.byName(data['type'] ?? 'system');
    } catch (_) {
      safeType = NotificationType.system;
    }
    
    return AdminNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: safeType,
      isRead: data['isRead'] ?? false,
      // Handle null timestamp during internal Firestore latency (pending writes)
      timestamp: timestamp != null 
          ? (timestamp as Timestamp).toDate() 
          : DateTime.now(), 
      targetRoute: data['targetRoute'],
      metadata: data['metadata'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'timestamp': FieldValue.serverTimestamp(),
      'targetRoute': targetRoute,
      'metadata': metadata,
    };
  }
}
