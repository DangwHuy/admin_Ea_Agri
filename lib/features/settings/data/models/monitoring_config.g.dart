// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonitoringConfigImpl _$$MonitoringConfigImplFromJson(
  Map<String, dynamic> json,
) => _$MonitoringConfigImpl(
  apiLatencyThresholdMs:
      (json['apiLatencyThresholdMs'] as num?)?.toInt() ?? 1000,
  errorRateAlertThreshold:
      (json['errorRateAlertThreshold'] as num?)?.toDouble() ?? 5.0,
  enableFirestoreUsageTracking:
      json['enableFirestoreUsageTracking'] as bool? ?? true,
  enableAIUsageStats: json['enableAIUsageStats'] as bool? ?? true,
  logRetentionDays: (json['logRetentionDays'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$$MonitoringConfigImplToJson(
  _$MonitoringConfigImpl instance,
) => <String, dynamic>{
  'apiLatencyThresholdMs': instance.apiLatencyThresholdMs,
  'errorRateAlertThreshold': instance.errorRateAlertThreshold,
  'enableFirestoreUsageTracking': instance.enableFirestoreUsageTracking,
  'enableAIUsageStats': instance.enableAIUsageStats,
  'logRetentionDays': instance.logRetentionDays,
};
