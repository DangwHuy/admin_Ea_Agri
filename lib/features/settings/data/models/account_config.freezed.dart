// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AccountConfig _$AccountConfigFromJson(Map<String, dynamic> json) {
  return _AccountConfig.fromJson(json);
}

/// @nodoc
mixin _$AccountConfig {
  String get name => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  bool get enableTwoFactorAuth => throw _privateConstructorUsedError;
  String get themeMode =>
      throw _privateConstructorUsedError; // light, dark, system
  String get language => throw _privateConstructorUsedError;
  NotificationPreferences get notificationPreferences =>
      throw _privateConstructorUsedError;

  /// Serializes this AccountConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountConfigCopyWith<AccountConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountConfigCopyWith<$Res> {
  factory $AccountConfigCopyWith(
    AccountConfig value,
    $Res Function(AccountConfig) then,
  ) = _$AccountConfigCopyWithImpl<$Res, AccountConfig>;
  @useResult
  $Res call({
    String name,
    String avatarUrl,
    String email,
    String phone,
    bool enableTwoFactorAuth,
    String themeMode,
    String language,
    NotificationPreferences notificationPreferences,
  });

  $NotificationPreferencesCopyWith<$Res> get notificationPreferences;
}

/// @nodoc
class _$AccountConfigCopyWithImpl<$Res, $Val extends AccountConfig>
    implements $AccountConfigCopyWith<$Res> {
  _$AccountConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatarUrl = null,
    Object? email = null,
    Object? phone = null,
    Object? enableTwoFactorAuth = null,
    Object? themeMode = null,
    Object? language = null,
    Object? notificationPreferences = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            enableTwoFactorAuth: null == enableTwoFactorAuth
                ? _value.enableTwoFactorAuth
                : enableTwoFactorAuth // ignore: cast_nullable_to_non_nullable
                      as bool,
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationPreferences: null == notificationPreferences
                ? _value.notificationPreferences
                : notificationPreferences // ignore: cast_nullable_to_non_nullable
                      as NotificationPreferences,
          )
          as $Val,
    );
  }

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationPreferencesCopyWith<$Res> get notificationPreferences {
    return $NotificationPreferencesCopyWith<$Res>(
      _value.notificationPreferences,
      (value) {
        return _then(_value.copyWith(notificationPreferences: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$AccountConfigImplCopyWith<$Res>
    implements $AccountConfigCopyWith<$Res> {
  factory _$$AccountConfigImplCopyWith(
    _$AccountConfigImpl value,
    $Res Function(_$AccountConfigImpl) then,
  ) = __$$AccountConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String avatarUrl,
    String email,
    String phone,
    bool enableTwoFactorAuth,
    String themeMode,
    String language,
    NotificationPreferences notificationPreferences,
  });

  @override
  $NotificationPreferencesCopyWith<$Res> get notificationPreferences;
}

/// @nodoc
class __$$AccountConfigImplCopyWithImpl<$Res>
    extends _$AccountConfigCopyWithImpl<$Res, _$AccountConfigImpl>
    implements _$$AccountConfigImplCopyWith<$Res> {
  __$$AccountConfigImplCopyWithImpl(
    _$AccountConfigImpl _value,
    $Res Function(_$AccountConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatarUrl = null,
    Object? email = null,
    Object? phone = null,
    Object? enableTwoFactorAuth = null,
    Object? themeMode = null,
    Object? language = null,
    Object? notificationPreferences = null,
  }) {
    return _then(
      _$AccountConfigImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        enableTwoFactorAuth: null == enableTwoFactorAuth
            ? _value.enableTwoFactorAuth
            : enableTwoFactorAuth // ignore: cast_nullable_to_non_nullable
                  as bool,
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationPreferences: null == notificationPreferences
            ? _value.notificationPreferences
            : notificationPreferences // ignore: cast_nullable_to_non_nullable
                  as NotificationPreferences,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountConfigImpl implements _AccountConfig {
  const _$AccountConfigImpl({
    this.name = '',
    this.avatarUrl = '',
    this.email = '',
    this.phone = '',
    this.enableTwoFactorAuth = false,
    this.themeMode = 'light',
    this.language = 'vi',
    this.notificationPreferences = const NotificationPreferences(),
  });

  factory _$AccountConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountConfigImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String avatarUrl;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final bool enableTwoFactorAuth;
  @override
  @JsonKey()
  final String themeMode;
  // light, dark, system
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final NotificationPreferences notificationPreferences;

  @override
  String toString() {
    return 'AccountConfig(name: $name, avatarUrl: $avatarUrl, email: $email, phone: $phone, enableTwoFactorAuth: $enableTwoFactorAuth, themeMode: $themeMode, language: $language, notificationPreferences: $notificationPreferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountConfigImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.enableTwoFactorAuth, enableTwoFactorAuth) ||
                other.enableTwoFactorAuth == enableTwoFactorAuth) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(
                  other.notificationPreferences,
                  notificationPreferences,
                ) ||
                other.notificationPreferences == notificationPreferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    avatarUrl,
    email,
    phone,
    enableTwoFactorAuth,
    themeMode,
    language,
    notificationPreferences,
  );

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountConfigImplCopyWith<_$AccountConfigImpl> get copyWith =>
      __$$AccountConfigImplCopyWithImpl<_$AccountConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountConfigImplToJson(this);
  }
}

abstract class _AccountConfig implements AccountConfig {
  const factory _AccountConfig({
    final String name,
    final String avatarUrl,
    final String email,
    final String phone,
    final bool enableTwoFactorAuth,
    final String themeMode,
    final String language,
    final NotificationPreferences notificationPreferences,
  }) = _$AccountConfigImpl;

  factory _AccountConfig.fromJson(Map<String, dynamic> json) =
      _$AccountConfigImpl.fromJson;

  @override
  String get name;
  @override
  String get avatarUrl;
  @override
  String get email;
  @override
  String get phone;
  @override
  bool get enableTwoFactorAuth;
  @override
  String get themeMode; // light, dark, system
  @override
  String get language;
  @override
  NotificationPreferences get notificationPreferences;

  /// Create a copy of AccountConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountConfigImplCopyWith<_$AccountConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationPreferences.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferences {
  bool get emailAlerts => throw _privateConstructorUsedError;
  bool get pushAlerts => throw _privateConstructorUsedError;
  bool get smsAlerts => throw _privateConstructorUsedError;
  bool get marketingEmails => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesCopyWith<NotificationPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesCopyWith<$Res> {
  factory $NotificationPreferencesCopyWith(
    NotificationPreferences value,
    $Res Function(NotificationPreferences) then,
  ) = _$NotificationPreferencesCopyWithImpl<$Res, NotificationPreferences>;
  @useResult
  $Res call({
    bool emailAlerts,
    bool pushAlerts,
    bool smsAlerts,
    bool marketingEmails,
  });
}

/// @nodoc
class _$NotificationPreferencesCopyWithImpl<
  $Res,
  $Val extends NotificationPreferences
>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailAlerts = null,
    Object? pushAlerts = null,
    Object? smsAlerts = null,
    Object? marketingEmails = null,
  }) {
    return _then(
      _value.copyWith(
            emailAlerts: null == emailAlerts
                ? _value.emailAlerts
                : emailAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            pushAlerts: null == pushAlerts
                ? _value.pushAlerts
                : pushAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            smsAlerts: null == smsAlerts
                ? _value.smsAlerts
                : smsAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            marketingEmails: null == marketingEmails
                ? _value.marketingEmails
                : marketingEmails // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesImplCopyWith<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  factory _$$NotificationPreferencesImplCopyWith(
    _$NotificationPreferencesImpl value,
    $Res Function(_$NotificationPreferencesImpl) then,
  ) = __$$NotificationPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool emailAlerts,
    bool pushAlerts,
    bool smsAlerts,
    bool marketingEmails,
  });
}

/// @nodoc
class __$$NotificationPreferencesImplCopyWithImpl<$Res>
    extends
        _$NotificationPreferencesCopyWithImpl<
          $Res,
          _$NotificationPreferencesImpl
        >
    implements _$$NotificationPreferencesImplCopyWith<$Res> {
  __$$NotificationPreferencesImplCopyWithImpl(
    _$NotificationPreferencesImpl _value,
    $Res Function(_$NotificationPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailAlerts = null,
    Object? pushAlerts = null,
    Object? smsAlerts = null,
    Object? marketingEmails = null,
  }) {
    return _then(
      _$NotificationPreferencesImpl(
        emailAlerts: null == emailAlerts
            ? _value.emailAlerts
            : emailAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        pushAlerts: null == pushAlerts
            ? _value.pushAlerts
            : pushAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        smsAlerts: null == smsAlerts
            ? _value.smsAlerts
            : smsAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        marketingEmails: null == marketingEmails
            ? _value.marketingEmails
            : marketingEmails // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesImpl implements _NotificationPreferences {
  const _$NotificationPreferencesImpl({
    this.emailAlerts = true,
    this.pushAlerts = true,
    this.smsAlerts = false,
    this.marketingEmails = true,
  });

  factory _$NotificationPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool emailAlerts;
  @override
  @JsonKey()
  final bool pushAlerts;
  @override
  @JsonKey()
  final bool smsAlerts;
  @override
  @JsonKey()
  final bool marketingEmails;

  @override
  String toString() {
    return 'NotificationPreferences(emailAlerts: $emailAlerts, pushAlerts: $pushAlerts, smsAlerts: $smsAlerts, marketingEmails: $marketingEmails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesImpl &&
            (identical(other.emailAlerts, emailAlerts) ||
                other.emailAlerts == emailAlerts) &&
            (identical(other.pushAlerts, pushAlerts) ||
                other.pushAlerts == pushAlerts) &&
            (identical(other.smsAlerts, smsAlerts) ||
                other.smsAlerts == smsAlerts) &&
            (identical(other.marketingEmails, marketingEmails) ||
                other.marketingEmails == marketingEmails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    emailAlerts,
    pushAlerts,
    smsAlerts,
    marketingEmails,
  );

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
  get copyWith =>
      __$$NotificationPreferencesImplCopyWithImpl<
        _$NotificationPreferencesImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesImplToJson(this);
  }
}

abstract class _NotificationPreferences implements NotificationPreferences {
  const factory _NotificationPreferences({
    final bool emailAlerts,
    final bool pushAlerts,
    final bool smsAlerts,
    final bool marketingEmails,
  }) = _$NotificationPreferencesImpl;

  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesImpl.fromJson;

  @override
  bool get emailAlerts;
  @override
  bool get pushAlerts;
  @override
  bool get smsAlerts;
  @override
  bool get marketingEmails;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
  get copyWith => throw _privateConstructorUsedError;
}
