// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monitoring_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonitoringConfig _$MonitoringConfigFromJson(Map<String, dynamic> json) {
  return _MonitoringConfig.fromJson(json);
}

/// @nodoc
mixin _$MonitoringConfig {
  int get apiLatencyThresholdMs => throw _privateConstructorUsedError;
  double get errorRateAlertThreshold => throw _privateConstructorUsedError;
  bool get enableFirestoreUsageTracking => throw _privateConstructorUsedError;
  bool get enableAIUsageStats => throw _privateConstructorUsedError;
  int get logRetentionDays => throw _privateConstructorUsedError;

  /// Serializes this MonitoringConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonitoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonitoringConfigCopyWith<MonitoringConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonitoringConfigCopyWith<$Res> {
  factory $MonitoringConfigCopyWith(
    MonitoringConfig value,
    $Res Function(MonitoringConfig) then,
  ) = _$MonitoringConfigCopyWithImpl<$Res, MonitoringConfig>;
  @useResult
  $Res call({
    int apiLatencyThresholdMs,
    double errorRateAlertThreshold,
    bool enableFirestoreUsageTracking,
    bool enableAIUsageStats,
    int logRetentionDays,
  });
}

/// @nodoc
class _$MonitoringConfigCopyWithImpl<$Res, $Val extends MonitoringConfig>
    implements $MonitoringConfigCopyWith<$Res> {
  _$MonitoringConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonitoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiLatencyThresholdMs = null,
    Object? errorRateAlertThreshold = null,
    Object? enableFirestoreUsageTracking = null,
    Object? enableAIUsageStats = null,
    Object? logRetentionDays = null,
  }) {
    return _then(
      _value.copyWith(
            apiLatencyThresholdMs: null == apiLatencyThresholdMs
                ? _value.apiLatencyThresholdMs
                : apiLatencyThresholdMs // ignore: cast_nullable_to_non_nullable
                      as int,
            errorRateAlertThreshold: null == errorRateAlertThreshold
                ? _value.errorRateAlertThreshold
                : errorRateAlertThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            enableFirestoreUsageTracking: null == enableFirestoreUsageTracking
                ? _value.enableFirestoreUsageTracking
                : enableFirestoreUsageTracking // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableAIUsageStats: null == enableAIUsageStats
                ? _value.enableAIUsageStats
                : enableAIUsageStats // ignore: cast_nullable_to_non_nullable
                      as bool,
            logRetentionDays: null == logRetentionDays
                ? _value.logRetentionDays
                : logRetentionDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonitoringConfigImplCopyWith<$Res>
    implements $MonitoringConfigCopyWith<$Res> {
  factory _$$MonitoringConfigImplCopyWith(
    _$MonitoringConfigImpl value,
    $Res Function(_$MonitoringConfigImpl) then,
  ) = __$$MonitoringConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int apiLatencyThresholdMs,
    double errorRateAlertThreshold,
    bool enableFirestoreUsageTracking,
    bool enableAIUsageStats,
    int logRetentionDays,
  });
}

/// @nodoc
class __$$MonitoringConfigImplCopyWithImpl<$Res>
    extends _$MonitoringConfigCopyWithImpl<$Res, _$MonitoringConfigImpl>
    implements _$$MonitoringConfigImplCopyWith<$Res> {
  __$$MonitoringConfigImplCopyWithImpl(
    _$MonitoringConfigImpl _value,
    $Res Function(_$MonitoringConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonitoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiLatencyThresholdMs = null,
    Object? errorRateAlertThreshold = null,
    Object? enableFirestoreUsageTracking = null,
    Object? enableAIUsageStats = null,
    Object? logRetentionDays = null,
  }) {
    return _then(
      _$MonitoringConfigImpl(
        apiLatencyThresholdMs: null == apiLatencyThresholdMs
            ? _value.apiLatencyThresholdMs
            : apiLatencyThresholdMs // ignore: cast_nullable_to_non_nullable
                  as int,
        errorRateAlertThreshold: null == errorRateAlertThreshold
            ? _value.errorRateAlertThreshold
            : errorRateAlertThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        enableFirestoreUsageTracking: null == enableFirestoreUsageTracking
            ? _value.enableFirestoreUsageTracking
            : enableFirestoreUsageTracking // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableAIUsageStats: null == enableAIUsageStats
            ? _value.enableAIUsageStats
            : enableAIUsageStats // ignore: cast_nullable_to_non_nullable
                  as bool,
        logRetentionDays: null == logRetentionDays
            ? _value.logRetentionDays
            : logRetentionDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonitoringConfigImpl implements _MonitoringConfig {
  const _$MonitoringConfigImpl({
    this.apiLatencyThresholdMs = 1000,
    this.errorRateAlertThreshold = 5.0,
    this.enableFirestoreUsageTracking = true,
    this.enableAIUsageStats = true,
    this.logRetentionDays = 7,
  });

  factory _$MonitoringConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonitoringConfigImplFromJson(json);

  @override
  @JsonKey()
  final int apiLatencyThresholdMs;
  @override
  @JsonKey()
  final double errorRateAlertThreshold;
  @override
  @JsonKey()
  final bool enableFirestoreUsageTracking;
  @override
  @JsonKey()
  final bool enableAIUsageStats;
  @override
  @JsonKey()
  final int logRetentionDays;

  @override
  String toString() {
    return 'MonitoringConfig(apiLatencyThresholdMs: $apiLatencyThresholdMs, errorRateAlertThreshold: $errorRateAlertThreshold, enableFirestoreUsageTracking: $enableFirestoreUsageTracking, enableAIUsageStats: $enableAIUsageStats, logRetentionDays: $logRetentionDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonitoringConfigImpl &&
            (identical(other.apiLatencyThresholdMs, apiLatencyThresholdMs) ||
                other.apiLatencyThresholdMs == apiLatencyThresholdMs) &&
            (identical(
                  other.errorRateAlertThreshold,
                  errorRateAlertThreshold,
                ) ||
                other.errorRateAlertThreshold == errorRateAlertThreshold) &&
            (identical(
                  other.enableFirestoreUsageTracking,
                  enableFirestoreUsageTracking,
                ) ||
                other.enableFirestoreUsageTracking ==
                    enableFirestoreUsageTracking) &&
            (identical(other.enableAIUsageStats, enableAIUsageStats) ||
                other.enableAIUsageStats == enableAIUsageStats) &&
            (identical(other.logRetentionDays, logRetentionDays) ||
                other.logRetentionDays == logRetentionDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    apiLatencyThresholdMs,
    errorRateAlertThreshold,
    enableFirestoreUsageTracking,
    enableAIUsageStats,
    logRetentionDays,
  );

  /// Create a copy of MonitoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonitoringConfigImplCopyWith<_$MonitoringConfigImpl> get copyWith =>
      __$$MonitoringConfigImplCopyWithImpl<_$MonitoringConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonitoringConfigImplToJson(this);
  }
}

abstract class _MonitoringConfig implements MonitoringConfig {
  const factory _MonitoringConfig({
    final int apiLatencyThresholdMs,
    final double errorRateAlertThreshold,
    final bool enableFirestoreUsageTracking,
    final bool enableAIUsageStats,
    final int logRetentionDays,
  }) = _$MonitoringConfigImpl;

  factory _MonitoringConfig.fromJson(Map<String, dynamic> json) =
      _$MonitoringConfigImpl.fromJson;

  @override
  int get apiLatencyThresholdMs;
  @override
  double get errorRateAlertThreshold;
  @override
  bool get enableFirestoreUsageTracking;
  @override
  bool get enableAIUsageStats;
  @override
  int get logRetentionDays;

  /// Create a copy of MonitoringConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonitoringConfigImplCopyWith<_$MonitoringConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
