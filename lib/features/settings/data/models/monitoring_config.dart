import 'package:freezed_annotation/freezed_annotation.dart';

part 'monitoring_config.freezed.dart';
part 'monitoring_config.g.dart';

@freezed
class MonitoringConfig with _$MonitoringConfig {
  const factory MonitoringConfig({
    @Default(1000) int apiLatencyThresholdMs,
    @Default(5.0) double errorRateAlertThreshold,
    @Default(true) bool enableFirestoreUsageTracking,
    @Default(true) bool enableAIUsageStats,
    @Default(7) int logRetentionDays,
  }) = _MonitoringConfig;

  factory MonitoringConfig.fromJson(Map<String, dynamic> json) =>
      _$MonitoringConfigFromJson(json);
}
