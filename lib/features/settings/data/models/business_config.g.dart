// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessConfigImpl _$$BusinessConfigImplFromJson(Map<String, dynamic> json) =>
    _$BusinessConfigImpl(
      orders: json['orders'] == null
          ? const OrderConfig()
          : OrderConfig.fromJson(json['orders'] as Map<String, dynamic>),
      products: json['products'] == null
          ? const ProductConfig()
          : ProductConfig.fromJson(json['products'] as Map<String, dynamic>),
      experts: json['experts'] == null
          ? const ExpertConfig()
          : ExpertConfig.fromJson(json['experts'] as Map<String, dynamic>),
      promotions: json['promotions'] == null
          ? const PromotionConfig()
          : PromotionConfig.fromJson(
              json['promotions'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$BusinessConfigImplToJson(
  _$BusinessConfigImpl instance,
) => <String, dynamic>{
  'orders': instance.orders,
  'products': instance.products,
  'experts': instance.experts,
  'promotions': instance.promotions,
};

_$OrderConfigImpl _$$OrderConfigImplFromJson(Map<String, dynamic> json) =>
    _$OrderConfigImpl(
      vatPercent: (json['vatPercent'] as num?)?.toDouble() ?? 10.0,
      shippingFeeFlat: (json['shippingFeeFlat'] as num?)?.toDouble() ?? 30000.0,
      autoCancelHours: (json['autoCancelHours'] as num?)?.toInt() ?? 24,
      enabledPaymentMethods:
          (json['enabledPaymentMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['COD', 'Bank Transfer', 'E-Wallet'],
    );

Map<String, dynamic> _$$OrderConfigImplToJson(_$OrderConfigImpl instance) =>
    <String, dynamic>{
      'vatPercent': instance.vatPercent,
      'shippingFeeFlat': instance.shippingFeeFlat,
      'autoCancelHours': instance.autoCancelHours,
      'enabledPaymentMethods': instance.enabledPaymentMethods,
    };

_$ProductConfigImpl _$$ProductConfigImplFromJson(Map<String, dynamic> json) =>
    _$ProductConfigImpl(
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      priceUpdateFrequencyHours:
          (json['priceUpdateFrequencyHours'] as num?)?.toInt() ?? 24,
    );

Map<String, dynamic> _$$ProductConfigImplToJson(_$ProductConfigImpl instance) =>
    <String, dynamic>{
      'lowStockThreshold': instance.lowStockThreshold,
      'priceUpdateFrequencyHours': instance.priceUpdateFrequencyHours,
    };

_$ExpertConfigImpl _$$ExpertConfigImplFromJson(Map<String, dynamic> json) =>
    _$ExpertConfigImpl(
      defaultStartWorkTime: json['defaultStartWorkTime'] as String? ?? '08:00',
      defaultEndWorkTime: json['defaultEndWorkTime'] as String? ?? '17:00',
      sessionDurationMinutes:
          (json['sessionDurationMinutes'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$$ExpertConfigImplToJson(_$ExpertConfigImpl instance) =>
    <String, dynamic>{
      'defaultStartWorkTime': instance.defaultStartWorkTime,
      'defaultEndWorkTime': instance.defaultEndWorkTime,
      'sessionDurationMinutes': instance.sessionDurationMinutes,
    };

_$PromotionConfigImpl _$$PromotionConfigImplFromJson(
  Map<String, dynamic> json,
) => _$PromotionConfigImpl(
  maxVouchersPerUser: (json['maxVouchersPerUser'] as num?)?.toInt() ?? 5,
  allowStackingVouchers: json['allowStackingVouchers'] as bool? ?? true,
);

Map<String, dynamic> _$$PromotionConfigImplToJson(
  _$PromotionConfigImpl instance,
) => <String, dynamic>{
  'maxVouchersPerUser': instance.maxVouchersPerUser,
  'allowStackingVouchers': instance.allowStackingVouchers,
};
