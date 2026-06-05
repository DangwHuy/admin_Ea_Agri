import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String sellerId;
  final String sellerName;
  final String type;
  final String discountType;
  final double value;
  final int usageCount;
  final int usageLimit;
  final DateTime expiryDate;
  final bool isActive;
  final DateTime? createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.sellerId,
    required this.sellerName,
    required this.type,
    required this.discountType,
    required this.value,
    required this.usageCount,
    required this.usageLimit,
    required this.expiryDate,
    required this.isActive,
    this.createdAt,
  });

  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VoucherModel(
      id: doc.id,
      code: data['code'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      type: data['type'] ?? '',
      discountType: data['discountType'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      usageCount: data['usageCount'] ?? 0,
      usageLimit: data['usageLimit'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? sellerId,
    String? sellerName,
    String? type,
    String? discountType,
    double? value,
    int? usageCount,
    int? usageLimit,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      type: type ?? this.type,
      discountType: discountType ?? this.discountType,
      value: value ?? this.value,
      usageCount: usageCount ?? this.usageCount,
      usageLimit: usageLimit ?? this.usageLimit,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
