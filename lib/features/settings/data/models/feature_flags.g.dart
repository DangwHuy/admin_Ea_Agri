// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeatureFlagsImpl _$$FeatureFlagsImplFromJson(Map<String, dynamic> json) =>
    _$FeatureFlagsImpl(
      enableOrderManagement: json['enableOrderManagement'] as bool? ?? true,
      enableAIAnalytics: json['enableAIAnalytics'] as bool? ?? true,
      enableExpertManagement: json['enableExpertManagement'] as bool? ?? true,
      enablePromotions: json['enablePromotions'] as bool? ?? true,
      enableBetaFeatures: json['enableBetaFeatures'] as bool? ?? false,
      betaRolloutPercentage:
          (json['betaRolloutPercentage'] as num?)?.toInt() ?? 10,
      isMaintenanceMode: json['isMaintenanceMode'] as bool? ?? false,
      maintenanceMessage:
          json['maintenanceMessage'] as String? ??
          'Hệ thống đang bảo trì, vui lòng quay lại sau.',
      customFlags:
          (json['customFlags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$$FeatureFlagsImplToJson(_$FeatureFlagsImpl instance) =>
    <String, dynamic>{
      'enableOrderManagement': instance.enableOrderManagement,
      'enableAIAnalytics': instance.enableAIAnalytics,
      'enableExpertManagement': instance.enableExpertManagement,
      'enablePromotions': instance.enablePromotions,
      'enableBetaFeatures': instance.enableBetaFeatures,
      'betaRolloutPercentage': instance.betaRolloutPercentage,
      'isMaintenanceMode': instance.isMaintenanceMode,
      'maintenanceMessage': instance.maintenanceMessage,
      'customFlags': instance.customFlags,
    };
