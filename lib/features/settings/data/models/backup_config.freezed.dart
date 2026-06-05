// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupConfig _$BackupConfigFromJson(Map<String, dynamic> json) {
  return _BackupConfig.fromJson(json);
}

/// @nodoc
mixin _$BackupConfig {
  bool get enableAutoBackup => throw _privateConstructorUsedError;
  String get backupFrequency =>
      throw _privateConstructorUsedError; // daily, weekly, monthly
  String get backupTime => throw _privateConstructorUsedError;
  int get retentionDays => throw _privateConstructorUsedError;
  bool get backupToCloudStorage => throw _privateConstructorUsedError;
  bool get backupToExternalServer => throw _privateConstructorUsedError;
  String get externalServerUrl => throw _privateConstructorUsedError;

  /// Serializes this BackupConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupConfigCopyWith<BackupConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupConfigCopyWith<$Res> {
  factory $BackupConfigCopyWith(
    BackupConfig value,
    $Res Function(BackupConfig) then,
  ) = _$BackupConfigCopyWithImpl<$Res, BackupConfig>;
  @useResult
  $Res call({
    bool enableAutoBackup,
    String backupFrequency,
    String backupTime,
    int retentionDays,
    bool backupToCloudStorage,
    bool backupToExternalServer,
    String externalServerUrl,
  });
}

/// @nodoc
class _$BackupConfigCopyWithImpl<$Res, $Val extends BackupConfig>
    implements $BackupConfigCopyWith<$Res> {
  _$BackupConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableAutoBackup = null,
    Object? backupFrequency = null,
    Object? backupTime = null,
    Object? retentionDays = null,
    Object? backupToCloudStorage = null,
    Object? backupToExternalServer = null,
    Object? externalServerUrl = null,
  }) {
    return _then(
      _value.copyWith(
            enableAutoBackup: null == enableAutoBackup
                ? _value.enableAutoBackup
                : enableAutoBackup // ignore: cast_nullable_to_non_nullable
                      as bool,
            backupFrequency: null == backupFrequency
                ? _value.backupFrequency
                : backupFrequency // ignore: cast_nullable_to_non_nullable
                      as String,
            backupTime: null == backupTime
                ? _value.backupTime
                : backupTime // ignore: cast_nullable_to_non_nullable
                      as String,
            retentionDays: null == retentionDays
                ? _value.retentionDays
                : retentionDays // ignore: cast_nullable_to_non_nullable
                      as int,
            backupToCloudStorage: null == backupToCloudStorage
                ? _value.backupToCloudStorage
                : backupToCloudStorage // ignore: cast_nullable_to_non_nullable
                      as bool,
            backupToExternalServer: null == backupToExternalServer
                ? _value.backupToExternalServer
                : backupToExternalServer // ignore: cast_nullable_to_non_nullable
                      as bool,
            externalServerUrl: null == externalServerUrl
                ? _value.externalServerUrl
                : externalServerUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupConfigImplCopyWith<$Res>
    implements $BackupConfigCopyWith<$Res> {
  factory _$$BackupConfigImplCopyWith(
    _$BackupConfigImpl value,
    $Res Function(_$BackupConfigImpl) then,
  ) = __$$BackupConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enableAutoBackup,
    String backupFrequency,
    String backupTime,
    int retentionDays,
    bool backupToCloudStorage,
    bool backupToExternalServer,
    String externalServerUrl,
  });
}

/// @nodoc
class __$$BackupConfigImplCopyWithImpl<$Res>
    extends _$BackupConfigCopyWithImpl<$Res, _$BackupConfigImpl>
    implements _$$BackupConfigImplCopyWith<$Res> {
  __$$BackupConfigImplCopyWithImpl(
    _$BackupConfigImpl _value,
    $Res Function(_$BackupConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableAutoBackup = null,
    Object? backupFrequency = null,
    Object? backupTime = null,
    Object? retentionDays = null,
    Object? backupToCloudStorage = null,
    Object? backupToExternalServer = null,
    Object? externalServerUrl = null,
  }) {
    return _then(
      _$BackupConfigImpl(
        enableAutoBackup: null == enableAutoBackup
            ? _value.enableAutoBackup
            : enableAutoBackup // ignore: cast_nullable_to_non_nullable
                  as bool,
        backupFrequency: null == backupFrequency
            ? _value.backupFrequency
            : backupFrequency // ignore: cast_nullable_to_non_nullable
                  as String,
        backupTime: null == backupTime
            ? _value.backupTime
            : backupTime // ignore: cast_nullable_to_non_nullable
                  as String,
        retentionDays: null == retentionDays
            ? _value.retentionDays
            : retentionDays // ignore: cast_nullable_to_non_nullable
                  as int,
        backupToCloudStorage: null == backupToCloudStorage
            ? _value.backupToCloudStorage
            : backupToCloudStorage // ignore: cast_nullable_to_non_nullable
                  as bool,
        backupToExternalServer: null == backupToExternalServer
            ? _value.backupToExternalServer
            : backupToExternalServer // ignore: cast_nullable_to_non_nullable
                  as bool,
        externalServerUrl: null == externalServerUrl
            ? _value.externalServerUrl
            : externalServerUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupConfigImpl implements _BackupConfig {
  const _$BackupConfigImpl({
    this.enableAutoBackup = true,
    this.backupFrequency = 'daily',
    this.backupTime = '02:00',
    this.retentionDays = 30,
    this.backupToCloudStorage = true,
    this.backupToExternalServer = false,
    this.externalServerUrl = '',
  });

  factory _$BackupConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool enableAutoBackup;
  @override
  @JsonKey()
  final String backupFrequency;
  // daily, weekly, monthly
  @override
  @JsonKey()
  final String backupTime;
  @override
  @JsonKey()
  final int retentionDays;
  @override
  @JsonKey()
  final bool backupToCloudStorage;
  @override
  @JsonKey()
  final bool backupToExternalServer;
  @override
  @JsonKey()
  final String externalServerUrl;

  @override
  String toString() {
    return 'BackupConfig(enableAutoBackup: $enableAutoBackup, backupFrequency: $backupFrequency, backupTime: $backupTime, retentionDays: $retentionDays, backupToCloudStorage: $backupToCloudStorage, backupToExternalServer: $backupToExternalServer, externalServerUrl: $externalServerUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupConfigImpl &&
            (identical(other.enableAutoBackup, enableAutoBackup) ||
                other.enableAutoBackup == enableAutoBackup) &&
            (identical(other.backupFrequency, backupFrequency) ||
                other.backupFrequency == backupFrequency) &&
            (identical(other.backupTime, backupTime) ||
                other.backupTime == backupTime) &&
            (identical(other.retentionDays, retentionDays) ||
                other.retentionDays == retentionDays) &&
            (identical(other.backupToCloudStorage, backupToCloudStorage) ||
                other.backupToCloudStorage == backupToCloudStorage) &&
            (identical(other.backupToExternalServer, backupToExternalServer) ||
                other.backupToExternalServer == backupToExternalServer) &&
            (identical(other.externalServerUrl, externalServerUrl) ||
                other.externalServerUrl == externalServerUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enableAutoBackup,
    backupFrequency,
    backupTime,
    retentionDays,
    backupToCloudStorage,
    backupToExternalServer,
    externalServerUrl,
  );

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      __$$BackupConfigImplCopyWithImpl<_$BackupConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupConfigImplToJson(this);
  }
}

abstract class _BackupConfig implements BackupConfig {
  const factory _BackupConfig({
    final bool enableAutoBackup,
    final String backupFrequency,
    final String backupTime,
    final int retentionDays,
    final bool backupToCloudStorage,
    final bool backupToExternalServer,
    final String externalServerUrl,
  }) = _$BackupConfigImpl;

  factory _BackupConfig.fromJson(Map<String, dynamic> json) =
      _$BackupConfigImpl.fromJson;

  @override
  bool get enableAutoBackup;
  @override
  String get backupFrequency; // daily, weekly, monthly
  @override
  String get backupTime;
  @override
  int get retentionDays;
  @override
  bool get backupToCloudStorage;
  @override
  bool get backupToExternalServer;
  @override
  String get externalServerUrl;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
