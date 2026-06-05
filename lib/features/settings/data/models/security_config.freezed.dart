// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SecurityConfig _$SecurityConfigFromJson(Map<String, dynamic> json) {
  return _SecurityConfig.fromJson(json);
}

/// @nodoc
mixin _$SecurityConfig {
  List<String> get ipWhitelist => throw _privateConstructorUsedError;
  int get sessionTimeoutSeconds => throw _privateConstructorUsedError;
  PasswordPolicy get passwordPolicy => throw _privateConstructorUsedError;
  int get maxLoginAttempts => throw _privateConstructorUsedError;
  int get lockoutDurationMinutes => throw _privateConstructorUsedError;
  bool get forceTwoFactorAuth => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get globalForceLogoutTimestamp =>
      throw _privateConstructorUsedError;

  /// Serializes this SecurityConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityConfigCopyWith<SecurityConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityConfigCopyWith<$Res> {
  factory $SecurityConfigCopyWith(
    SecurityConfig value,
    $Res Function(SecurityConfig) then,
  ) = _$SecurityConfigCopyWithImpl<$Res, SecurityConfig>;
  @useResult
  $Res call({
    List<String> ipWhitelist,
    int sessionTimeoutSeconds,
    PasswordPolicy passwordPolicy,
    int maxLoginAttempts,
    int lockoutDurationMinutes,
    bool forceTwoFactorAuth,
    @TimestampConverter() DateTime? globalForceLogoutTimestamp,
  });

  $PasswordPolicyCopyWith<$Res> get passwordPolicy;
}

/// @nodoc
class _$SecurityConfigCopyWithImpl<$Res, $Val extends SecurityConfig>
    implements $SecurityConfigCopyWith<$Res> {
  _$SecurityConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ipWhitelist = null,
    Object? sessionTimeoutSeconds = null,
    Object? passwordPolicy = null,
    Object? maxLoginAttempts = null,
    Object? lockoutDurationMinutes = null,
    Object? forceTwoFactorAuth = null,
    Object? globalForceLogoutTimestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            ipWhitelist: null == ipWhitelist
                ? _value.ipWhitelist
                : ipWhitelist // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sessionTimeoutSeconds: null == sessionTimeoutSeconds
                ? _value.sessionTimeoutSeconds
                : sessionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            passwordPolicy: null == passwordPolicy
                ? _value.passwordPolicy
                : passwordPolicy // ignore: cast_nullable_to_non_nullable
                      as PasswordPolicy,
            maxLoginAttempts: null == maxLoginAttempts
                ? _value.maxLoginAttempts
                : maxLoginAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            lockoutDurationMinutes: null == lockoutDurationMinutes
                ? _value.lockoutDurationMinutes
                : lockoutDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            forceTwoFactorAuth: null == forceTwoFactorAuth
                ? _value.forceTwoFactorAuth
                : forceTwoFactorAuth // ignore: cast_nullable_to_non_nullable
                      as bool,
            globalForceLogoutTimestamp: freezed == globalForceLogoutTimestamp
                ? _value.globalForceLogoutTimestamp
                : globalForceLogoutTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PasswordPolicyCopyWith<$Res> get passwordPolicy {
    return $PasswordPolicyCopyWith<$Res>(_value.passwordPolicy, (value) {
      return _then(_value.copyWith(passwordPolicy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SecurityConfigImplCopyWith<$Res>
    implements $SecurityConfigCopyWith<$Res> {
  factory _$$SecurityConfigImplCopyWith(
    _$SecurityConfigImpl value,
    $Res Function(_$SecurityConfigImpl) then,
  ) = __$$SecurityConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> ipWhitelist,
    int sessionTimeoutSeconds,
    PasswordPolicy passwordPolicy,
    int maxLoginAttempts,
    int lockoutDurationMinutes,
    bool forceTwoFactorAuth,
    @TimestampConverter() DateTime? globalForceLogoutTimestamp,
  });

  @override
  $PasswordPolicyCopyWith<$Res> get passwordPolicy;
}

/// @nodoc
class __$$SecurityConfigImplCopyWithImpl<$Res>
    extends _$SecurityConfigCopyWithImpl<$Res, _$SecurityConfigImpl>
    implements _$$SecurityConfigImplCopyWith<$Res> {
  __$$SecurityConfigImplCopyWithImpl(
    _$SecurityConfigImpl _value,
    $Res Function(_$SecurityConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ipWhitelist = null,
    Object? sessionTimeoutSeconds = null,
    Object? passwordPolicy = null,
    Object? maxLoginAttempts = null,
    Object? lockoutDurationMinutes = null,
    Object? forceTwoFactorAuth = null,
    Object? globalForceLogoutTimestamp = freezed,
  }) {
    return _then(
      _$SecurityConfigImpl(
        ipWhitelist: null == ipWhitelist
            ? _value._ipWhitelist
            : ipWhitelist // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sessionTimeoutSeconds: null == sessionTimeoutSeconds
            ? _value.sessionTimeoutSeconds
            : sessionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        passwordPolicy: null == passwordPolicy
            ? _value.passwordPolicy
            : passwordPolicy // ignore: cast_nullable_to_non_nullable
                  as PasswordPolicy,
        maxLoginAttempts: null == maxLoginAttempts
            ? _value.maxLoginAttempts
            : maxLoginAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        lockoutDurationMinutes: null == lockoutDurationMinutes
            ? _value.lockoutDurationMinutes
            : lockoutDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        forceTwoFactorAuth: null == forceTwoFactorAuth
            ? _value.forceTwoFactorAuth
            : forceTwoFactorAuth // ignore: cast_nullable_to_non_nullable
                  as bool,
        globalForceLogoutTimestamp: freezed == globalForceLogoutTimestamp
            ? _value.globalForceLogoutTimestamp
            : globalForceLogoutTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityConfigImpl implements _SecurityConfig {
  const _$SecurityConfigImpl({
    final List<String> ipWhitelist = const [],
    this.sessionTimeoutSeconds = 3600,
    this.passwordPolicy = const PasswordPolicy(),
    this.maxLoginAttempts = 5,
    this.lockoutDurationMinutes = 15,
    this.forceTwoFactorAuth = true,
    @TimestampConverter() this.globalForceLogoutTimestamp,
  }) : _ipWhitelist = ipWhitelist;

  factory _$SecurityConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityConfigImplFromJson(json);

  final List<String> _ipWhitelist;
  @override
  @JsonKey()
  List<String> get ipWhitelist {
    if (_ipWhitelist is EqualUnmodifiableListView) return _ipWhitelist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ipWhitelist);
  }

  @override
  @JsonKey()
  final int sessionTimeoutSeconds;
  @override
  @JsonKey()
  final PasswordPolicy passwordPolicy;
  @override
  @JsonKey()
  final int maxLoginAttempts;
  @override
  @JsonKey()
  final int lockoutDurationMinutes;
  @override
  @JsonKey()
  final bool forceTwoFactorAuth;
  @override
  @TimestampConverter()
  final DateTime? globalForceLogoutTimestamp;

  @override
  String toString() {
    return 'SecurityConfig(ipWhitelist: $ipWhitelist, sessionTimeoutSeconds: $sessionTimeoutSeconds, passwordPolicy: $passwordPolicy, maxLoginAttempts: $maxLoginAttempts, lockoutDurationMinutes: $lockoutDurationMinutes, forceTwoFactorAuth: $forceTwoFactorAuth, globalForceLogoutTimestamp: $globalForceLogoutTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityConfigImpl &&
            const DeepCollectionEquality().equals(
              other._ipWhitelist,
              _ipWhitelist,
            ) &&
            (identical(other.sessionTimeoutSeconds, sessionTimeoutSeconds) ||
                other.sessionTimeoutSeconds == sessionTimeoutSeconds) &&
            (identical(other.passwordPolicy, passwordPolicy) ||
                other.passwordPolicy == passwordPolicy) &&
            (identical(other.maxLoginAttempts, maxLoginAttempts) ||
                other.maxLoginAttempts == maxLoginAttempts) &&
            (identical(other.lockoutDurationMinutes, lockoutDurationMinutes) ||
                other.lockoutDurationMinutes == lockoutDurationMinutes) &&
            (identical(other.forceTwoFactorAuth, forceTwoFactorAuth) ||
                other.forceTwoFactorAuth == forceTwoFactorAuth) &&
            (identical(
                  other.globalForceLogoutTimestamp,
                  globalForceLogoutTimestamp,
                ) ||
                other.globalForceLogoutTimestamp ==
                    globalForceLogoutTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_ipWhitelist),
    sessionTimeoutSeconds,
    passwordPolicy,
    maxLoginAttempts,
    lockoutDurationMinutes,
    forceTwoFactorAuth,
    globalForceLogoutTimestamp,
  );

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityConfigImplCopyWith<_$SecurityConfigImpl> get copyWith =>
      __$$SecurityConfigImplCopyWithImpl<_$SecurityConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityConfigImplToJson(this);
  }
}

abstract class _SecurityConfig implements SecurityConfig {
  const factory _SecurityConfig({
    final List<String> ipWhitelist,
    final int sessionTimeoutSeconds,
    final PasswordPolicy passwordPolicy,
    final int maxLoginAttempts,
    final int lockoutDurationMinutes,
    final bool forceTwoFactorAuth,
    @TimestampConverter() final DateTime? globalForceLogoutTimestamp,
  }) = _$SecurityConfigImpl;

  factory _SecurityConfig.fromJson(Map<String, dynamic> json) =
      _$SecurityConfigImpl.fromJson;

  @override
  List<String> get ipWhitelist;
  @override
  int get sessionTimeoutSeconds;
  @override
  PasswordPolicy get passwordPolicy;
  @override
  int get maxLoginAttempts;
  @override
  int get lockoutDurationMinutes;
  @override
  bool get forceTwoFactorAuth;
  @override
  @TimestampConverter()
  DateTime? get globalForceLogoutTimestamp;

  /// Create a copy of SecurityConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityConfigImplCopyWith<_$SecurityConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PasswordPolicy _$PasswordPolicyFromJson(Map<String, dynamic> json) {
  return _PasswordPolicy.fromJson(json);
}

/// @nodoc
mixin _$PasswordPolicy {
  int get minLength => throw _privateConstructorUsedError;
  bool get requireSpecialChar => throw _privateConstructorUsedError;
  bool get requireNumber => throw _privateConstructorUsedError;
  bool get requireUppercase => throw _privateConstructorUsedError;
  int get passwordExpiryDays => throw _privateConstructorUsedError;

  /// Serializes this PasswordPolicy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasswordPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordPolicyCopyWith<PasswordPolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordPolicyCopyWith<$Res> {
  factory $PasswordPolicyCopyWith(
    PasswordPolicy value,
    $Res Function(PasswordPolicy) then,
  ) = _$PasswordPolicyCopyWithImpl<$Res, PasswordPolicy>;
  @useResult
  $Res call({
    int minLength,
    bool requireSpecialChar,
    bool requireNumber,
    bool requireUppercase,
    int passwordExpiryDays,
  });
}

/// @nodoc
class _$PasswordPolicyCopyWithImpl<$Res, $Val extends PasswordPolicy>
    implements $PasswordPolicyCopyWith<$Res> {
  _$PasswordPolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minLength = null,
    Object? requireSpecialChar = null,
    Object? requireNumber = null,
    Object? requireUppercase = null,
    Object? passwordExpiryDays = null,
  }) {
    return _then(
      _value.copyWith(
            minLength: null == minLength
                ? _value.minLength
                : minLength // ignore: cast_nullable_to_non_nullable
                      as int,
            requireSpecialChar: null == requireSpecialChar
                ? _value.requireSpecialChar
                : requireSpecialChar // ignore: cast_nullable_to_non_nullable
                      as bool,
            requireNumber: null == requireNumber
                ? _value.requireNumber
                : requireNumber // ignore: cast_nullable_to_non_nullable
                      as bool,
            requireUppercase: null == requireUppercase
                ? _value.requireUppercase
                : requireUppercase // ignore: cast_nullable_to_non_nullable
                      as bool,
            passwordExpiryDays: null == passwordExpiryDays
                ? _value.passwordExpiryDays
                : passwordExpiryDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordPolicyImplCopyWith<$Res>
    implements $PasswordPolicyCopyWith<$Res> {
  factory _$$PasswordPolicyImplCopyWith(
    _$PasswordPolicyImpl value,
    $Res Function(_$PasswordPolicyImpl) then,
  ) = __$$PasswordPolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int minLength,
    bool requireSpecialChar,
    bool requireNumber,
    bool requireUppercase,
    int passwordExpiryDays,
  });
}

/// @nodoc
class __$$PasswordPolicyImplCopyWithImpl<$Res>
    extends _$PasswordPolicyCopyWithImpl<$Res, _$PasswordPolicyImpl>
    implements _$$PasswordPolicyImplCopyWith<$Res> {
  __$$PasswordPolicyImplCopyWithImpl(
    _$PasswordPolicyImpl _value,
    $Res Function(_$PasswordPolicyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordPolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minLength = null,
    Object? requireSpecialChar = null,
    Object? requireNumber = null,
    Object? requireUppercase = null,
    Object? passwordExpiryDays = null,
  }) {
    return _then(
      _$PasswordPolicyImpl(
        minLength: null == minLength
            ? _value.minLength
            : minLength // ignore: cast_nullable_to_non_nullable
                  as int,
        requireSpecialChar: null == requireSpecialChar
            ? _value.requireSpecialChar
            : requireSpecialChar // ignore: cast_nullable_to_non_nullable
                  as bool,
        requireNumber: null == requireNumber
            ? _value.requireNumber
            : requireNumber // ignore: cast_nullable_to_non_nullable
                  as bool,
        requireUppercase: null == requireUppercase
            ? _value.requireUppercase
            : requireUppercase // ignore: cast_nullable_to_non_nullable
                  as bool,
        passwordExpiryDays: null == passwordExpiryDays
            ? _value.passwordExpiryDays
            : passwordExpiryDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PasswordPolicyImpl implements _PasswordPolicy {
  const _$PasswordPolicyImpl({
    this.minLength = 8,
    this.requireSpecialChar = true,
    this.requireNumber = true,
    this.requireUppercase = true,
    this.passwordExpiryDays = 90,
  });

  factory _$PasswordPolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PasswordPolicyImplFromJson(json);

  @override
  @JsonKey()
  final int minLength;
  @override
  @JsonKey()
  final bool requireSpecialChar;
  @override
  @JsonKey()
  final bool requireNumber;
  @override
  @JsonKey()
  final bool requireUppercase;
  @override
  @JsonKey()
  final int passwordExpiryDays;

  @override
  String toString() {
    return 'PasswordPolicy(minLength: $minLength, requireSpecialChar: $requireSpecialChar, requireNumber: $requireNumber, requireUppercase: $requireUppercase, passwordExpiryDays: $passwordExpiryDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordPolicyImpl &&
            (identical(other.minLength, minLength) ||
                other.minLength == minLength) &&
            (identical(other.requireSpecialChar, requireSpecialChar) ||
                other.requireSpecialChar == requireSpecialChar) &&
            (identical(other.requireNumber, requireNumber) ||
                other.requireNumber == requireNumber) &&
            (identical(other.requireUppercase, requireUppercase) ||
                other.requireUppercase == requireUppercase) &&
            (identical(other.passwordExpiryDays, passwordExpiryDays) ||
                other.passwordExpiryDays == passwordExpiryDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minLength,
    requireSpecialChar,
    requireNumber,
    requireUppercase,
    passwordExpiryDays,
  );

  /// Create a copy of PasswordPolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordPolicyImplCopyWith<_$PasswordPolicyImpl> get copyWith =>
      __$$PasswordPolicyImplCopyWithImpl<_$PasswordPolicyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PasswordPolicyImplToJson(this);
  }
}

abstract class _PasswordPolicy implements PasswordPolicy {
  const factory _PasswordPolicy({
    final int minLength,
    final bool requireSpecialChar,
    final bool requireNumber,
    final bool requireUppercase,
    final int passwordExpiryDays,
  }) = _$PasswordPolicyImpl;

  factory _PasswordPolicy.fromJson(Map<String, dynamic> json) =
      _$PasswordPolicyImpl.fromJson;

  @override
  int get minLength;
  @override
  bool get requireSpecialChar;
  @override
  bool get requireNumber;
  @override
  bool get requireUppercase;
  @override
  int get passwordExpiryDays;

  /// Create a copy of PasswordPolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordPolicyImplCopyWith<_$PasswordPolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
