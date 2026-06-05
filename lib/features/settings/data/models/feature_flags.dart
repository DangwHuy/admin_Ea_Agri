import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_flags.freezed.dart';
part 'feature_flags.g.dart';

@freezed
class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    @Default(true) bool enableOrderManagement,
    @Default(true) bool enableAIAnalytics,
    @Default(true) bool enableExpertManagement,
    @Default(true) bool enablePromotions,
    @Default(false) bool enableBetaFeatures,
    @Default(10) int betaRolloutPercentage,
    @Default(false) bool isMaintenanceMode,
    @Default('Hệ thống đang bảo trì, vui lòng quay lại sau.') String maintenanceMessage,
    @Default({}) Map<String, bool> customFlags,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}
