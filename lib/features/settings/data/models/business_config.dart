import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_config.freezed.dart';
part 'business_config.g.dart';

@freezed
class BusinessConfig with _$BusinessConfig {
  const factory BusinessConfig({
    @Default(OrderConfig()) OrderConfig orders,
    @Default(ProductConfig()) ProductConfig products,
    @Default(ExpertConfig()) ExpertConfig experts,
    @Default(PromotionConfig()) PromotionConfig promotions,
  }) = _BusinessConfig;

  factory BusinessConfig.fromJson(Map<String, dynamic> json) =>
      _$BusinessConfigFromJson(json);
}

@freezed
class OrderConfig with _$OrderConfig {
  const factory OrderConfig({
    @Default(10.0) double vatPercent,
    @Default(30000.0) double shippingFeeFlat,
    @Default(24) int autoCancelHours,
    @Default(['COD', 'Bank Transfer', 'E-Wallet']) List<String> enabledPaymentMethods,
  }) = _OrderConfig;

  factory OrderConfig.fromJson(Map<String, dynamic> json) =>
      _$OrderConfigFromJson(json);
}

@freezed
class ProductConfig with _$ProductConfig {
  const factory ProductConfig({
    @Default(10) int lowStockThreshold,
    @Default(24) int priceUpdateFrequencyHours,
  }) = _ProductConfig;

  factory ProductConfig.fromJson(Map<String, dynamic> json) =>
      _$ProductConfigFromJson(json);
}

@freezed
class ExpertConfig with _$ExpertConfig {
  const factory ExpertConfig({
    @Default('08:00') String defaultStartWorkTime,
    @Default('17:00') String defaultEndWorkTime,
    @Default(60) int sessionDurationMinutes,
  }) = _ExpertConfig;

  factory ExpertConfig.fromJson(Map<String, dynamic> json) =>
      _$ExpertConfigFromJson(json);
}

@freezed
class PromotionConfig with _$PromotionConfig {
  const factory PromotionConfig({
    @Default(5) int maxVouchersPerUser,
    @Default(true) bool allowStackingVouchers,
  }) = _PromotionConfig;

  factory PromotionConfig.fromJson(Map<String, dynamic> json) =>
      _$PromotionConfigFromJson(json);
}
