// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localization_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocalizationConfig _$LocalizationConfigFromJson(Map<String, dynamic> json) {
  return _LocalizationConfig.fromJson(json);
}

/// @nodoc
mixin _$LocalizationConfig {
  String get defaultTimezone => throw _privateConstructorUsedError;
  String get defaultCurrency => throw _privateConstructorUsedError;
  String get dateFormat => throw _privateConstructorUsedError;
  String get unitSystem =>
      throw _privateConstructorUsedError; // metric or imperial
  String get defaultLanguage => throw _privateConstructorUsedError;

  /// Serializes this LocalizationConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalizationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalizationConfigCopyWith<LocalizationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizationConfigCopyWith<$Res> {
  factory $LocalizationConfigCopyWith(
    LocalizationConfig value,
    $Res Function(LocalizationConfig) then,
  ) = _$LocalizationConfigCopyWithImpl<$Res, LocalizationConfig>;
  @useResult
  $Res call({
    String defaultTimezone,
    String defaultCurrency,
    String dateFormat,
    String unitSystem,
    String defaultLanguage,
  });
}

/// @nodoc
class _$LocalizationConfigCopyWithImpl<$Res, $Val extends LocalizationConfig>
    implements $LocalizationConfigCopyWith<$Res> {
  _$LocalizationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalizationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultTimezone = null,
    Object? defaultCurrency = null,
    Object? dateFormat = null,
    Object? unitSystem = null,
    Object? defaultLanguage = null,
  }) {
    return _then(
      _value.copyWith(
            defaultTimezone: null == defaultTimezone
                ? _value.defaultTimezone
                : defaultTimezone // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultCurrency: null == defaultCurrency
                ? _value.defaultCurrency
                : defaultCurrency // ignore: cast_nullable_to_non_nullable
                      as String,
            dateFormat: null == dateFormat
                ? _value.dateFormat
                : dateFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            unitSystem: null == unitSystem
                ? _value.unitSystem
                : unitSystem // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultLanguage: null == defaultLanguage
                ? _value.defaultLanguage
                : defaultLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalizationConfigImplCopyWith<$Res>
    implements $LocalizationConfigCopyWith<$Res> {
  factory _$$LocalizationConfigImplCopyWith(
    _$LocalizationConfigImpl value,
    $Res Function(_$LocalizationConfigImpl) then,
  ) = __$$LocalizationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String defaultTimezone,
    String defaultCurrency,
    String dateFormat,
    String unitSystem,
    String defaultLanguage,
  });
}

/// @nodoc
class __$$LocalizationConfigImplCopyWithImpl<$Res>
    extends _$LocalizationConfigCopyWithImpl<$Res, _$LocalizationConfigImpl>
    implements _$$LocalizationConfigImplCopyWith<$Res> {
  __$$LocalizationConfigImplCopyWithImpl(
    _$LocalizationConfigImpl _value,
    $Res Function(_$LocalizationConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalizationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultTimezone = null,
    Object? defaultCurrency = null,
    Object? dateFormat = null,
    Object? unitSystem = null,
    Object? defaultLanguage = null,
  }) {
    return _then(
      _$LocalizationConfigImpl(
        defaultTimezone: null == defaultTimezone
            ? _value.defaultTimezone
            : defaultTimezone // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultCurrency: null == defaultCurrency
            ? _value.defaultCurrency
            : defaultCurrency // ignore: cast_nullable_to_non_nullable
                  as String,
        dateFormat: null == dateFormat
            ? _value.dateFormat
            : dateFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        unitSystem: null == unitSystem
            ? _value.unitSystem
            : unitSystem // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultLanguage: null == defaultLanguage
            ? _value.defaultLanguage
            : defaultLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizationConfigImpl implements _LocalizationConfig {
  const _$LocalizationConfigImpl({
    this.defaultTimezone = 'Asia/Ho_Chi_Minh',
    this.defaultCurrency = 'VND',
    this.dateFormat = 'dd/MM/yyyy',
    this.unitSystem = 'metric',
    this.defaultLanguage = 'vi',
  });

  factory _$LocalizationConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizationConfigImplFromJson(json);

  @override
  @JsonKey()
  final String defaultTimezone;
  @override
  @JsonKey()
  final String defaultCurrency;
  @override
  @JsonKey()
  final String dateFormat;
  @override
  @JsonKey()
  final String unitSystem;
  // metric or imperial
  @override
  @JsonKey()
  final String defaultLanguage;

  @override
  String toString() {
    return 'LocalizationConfig(defaultTimezone: $defaultTimezone, defaultCurrency: $defaultCurrency, dateFormat: $dateFormat, unitSystem: $unitSystem, defaultLanguage: $defaultLanguage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizationConfigImpl &&
            (identical(other.defaultTimezone, defaultTimezone) ||
                other.defaultTimezone == defaultTimezone) &&
            (identical(other.defaultCurrency, defaultCurrency) ||
                other.defaultCurrency == defaultCurrency) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.unitSystem, unitSystem) ||
                other.unitSystem == unitSystem) &&
            (identical(other.defaultLanguage, defaultLanguage) ||
                other.defaultLanguage == defaultLanguage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    defaultTimezone,
    defaultCurrency,
    dateFormat,
    unitSystem,
    defaultLanguage,
  );

  /// Create a copy of LocalizationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizationConfigImplCopyWith<_$LocalizationConfigImpl> get copyWith =>
      __$$LocalizationConfigImplCopyWithImpl<_$LocalizationConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizationConfigImplToJson(this);
  }
}

abstract class _LocalizationConfig implements LocalizationConfig {
  const factory _LocalizationConfig({
    final String defaultTimezone,
    final String defaultCurrency,
    final String dateFormat,
    final String unitSystem,
    final String defaultLanguage,
  }) = _$LocalizationConfigImpl;

  factory _LocalizationConfig.fromJson(Map<String, dynamic> json) =
      _$LocalizationConfigImpl.fromJson;

  @override
  String get defaultTimezone;
  @override
  String get defaultCurrency;
  @override
  String get dateFormat;
  @override
  String get unitSystem; // metric or imperial
  @override
  String get defaultLanguage;

  /// Create a copy of LocalizationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalizationConfigImplCopyWith<_$LocalizationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
