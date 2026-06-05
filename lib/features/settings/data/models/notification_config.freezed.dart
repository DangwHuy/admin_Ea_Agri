// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) {
  return _NotificationConfig.fromJson(json);
}

/// @nodoc
mixin _$NotificationConfig {
  bool get enableEmailNotifications => throw _privateConstructorUsedError;
  bool get enableSMSNotifications => throw _privateConstructorUsedError;
  bool get enablePushNotifications => throw _privateConstructorUsedError;
  Map<String, String> get emailTemplates => throw _privateConstructorUsedError;
  Map<String, String> get smsTemplates => throw _privateConstructorUsedError;
  NotificationTriggerRules get triggerRules =>
      throw _privateConstructorUsedError;

  /// Serializes this NotificationConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationConfigCopyWith<NotificationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationConfigCopyWith<$Res> {
  factory $NotificationConfigCopyWith(
    NotificationConfig value,
    $Res Function(NotificationConfig) then,
  ) = _$NotificationConfigCopyWithImpl<$Res, NotificationConfig>;
  @useResult
  $Res call({
    bool enableEmailNotifications,
    bool enableSMSNotifications,
    bool enablePushNotifications,
    Map<String, String> emailTemplates,
    Map<String, String> smsTemplates,
    NotificationTriggerRules triggerRules,
  });

  $NotificationTriggerRulesCopyWith<$Res> get triggerRules;
}

/// @nodoc
class _$NotificationConfigCopyWithImpl<$Res, $Val extends NotificationConfig>
    implements $NotificationConfigCopyWith<$Res> {
  _$NotificationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableEmailNotifications = null,
    Object? enableSMSNotifications = null,
    Object? enablePushNotifications = null,
    Object? emailTemplates = null,
    Object? smsTemplates = null,
    Object? triggerRules = null,
  }) {
    return _then(
      _value.copyWith(
            enableEmailNotifications: null == enableEmailNotifications
                ? _value.enableEmailNotifications
                : enableEmailNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSMSNotifications: null == enableSMSNotifications
                ? _value.enableSMSNotifications
                : enableSMSNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            enablePushNotifications: null == enablePushNotifications
                ? _value.enablePushNotifications
                : enablePushNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailTemplates: null == emailTemplates
                ? _value.emailTemplates
                : emailTemplates // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            smsTemplates: null == smsTemplates
                ? _value.smsTemplates
                : smsTemplates // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            triggerRules: null == triggerRules
                ? _value.triggerRules
                : triggerRules // ignore: cast_nullable_to_non_nullable
                      as NotificationTriggerRules,
          )
          as $Val,
    );
  }

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationTriggerRulesCopyWith<$Res> get triggerRules {
    return $NotificationTriggerRulesCopyWith<$Res>(_value.triggerRules, (
      value,
    ) {
      return _then(_value.copyWith(triggerRules: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationConfigImplCopyWith<$Res>
    implements $NotificationConfigCopyWith<$Res> {
  factory _$$NotificationConfigImplCopyWith(
    _$NotificationConfigImpl value,
    $Res Function(_$NotificationConfigImpl) then,
  ) = __$$NotificationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enableEmailNotifications,
    bool enableSMSNotifications,
    bool enablePushNotifications,
    Map<String, String> emailTemplates,
    Map<String, String> smsTemplates,
    NotificationTriggerRules triggerRules,
  });

  @override
  $NotificationTriggerRulesCopyWith<$Res> get triggerRules;
}

/// @nodoc
class __$$NotificationConfigImplCopyWithImpl<$Res>
    extends _$NotificationConfigCopyWithImpl<$Res, _$NotificationConfigImpl>
    implements _$$NotificationConfigImplCopyWith<$Res> {
  __$$NotificationConfigImplCopyWithImpl(
    _$NotificationConfigImpl _value,
    $Res Function(_$NotificationConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableEmailNotifications = null,
    Object? enableSMSNotifications = null,
    Object? enablePushNotifications = null,
    Object? emailTemplates = null,
    Object? smsTemplates = null,
    Object? triggerRules = null,
  }) {
    return _then(
      _$NotificationConfigImpl(
        enableEmailNotifications: null == enableEmailNotifications
            ? _value.enableEmailNotifications
            : enableEmailNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSMSNotifications: null == enableSMSNotifications
            ? _value.enableSMSNotifications
            : enableSMSNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        enablePushNotifications: null == enablePushNotifications
            ? _value.enablePushNotifications
            : enablePushNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailTemplates: null == emailTemplates
            ? _value._emailTemplates
            : emailTemplates // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        smsTemplates: null == smsTemplates
            ? _value._smsTemplates
            : smsTemplates // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        triggerRules: null == triggerRules
            ? _value.triggerRules
            : triggerRules // ignore: cast_nullable_to_non_nullable
                  as NotificationTriggerRules,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationConfigImpl implements _NotificationConfig {
  const _$NotificationConfigImpl({
    this.enableEmailNotifications = true,
    this.enableSMSNotifications = true,
    this.enablePushNotifications = true,
    final Map<String, String> emailTemplates = const {},
    final Map<String, String> smsTemplates = const {},
    this.triggerRules = const NotificationTriggerRules(),
  }) : _emailTemplates = emailTemplates,
       _smsTemplates = smsTemplates;

  factory _$NotificationConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool enableEmailNotifications;
  @override
  @JsonKey()
  final bool enableSMSNotifications;
  @override
  @JsonKey()
  final bool enablePushNotifications;
  final Map<String, String> _emailTemplates;
  @override
  @JsonKey()
  Map<String, String> get emailTemplates {
    if (_emailTemplates is EqualUnmodifiableMapView) return _emailTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_emailTemplates);
  }

  final Map<String, String> _smsTemplates;
  @override
  @JsonKey()
  Map<String, String> get smsTemplates {
    if (_smsTemplates is EqualUnmodifiableMapView) return _smsTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_smsTemplates);
  }

  @override
  @JsonKey()
  final NotificationTriggerRules triggerRules;

  @override
  String toString() {
    return 'NotificationConfig(enableEmailNotifications: $enableEmailNotifications, enableSMSNotifications: $enableSMSNotifications, enablePushNotifications: $enablePushNotifications, emailTemplates: $emailTemplates, smsTemplates: $smsTemplates, triggerRules: $triggerRules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationConfigImpl &&
            (identical(
                  other.enableEmailNotifications,
                  enableEmailNotifications,
                ) ||
                other.enableEmailNotifications == enableEmailNotifications) &&
            (identical(other.enableSMSNotifications, enableSMSNotifications) ||
                other.enableSMSNotifications == enableSMSNotifications) &&
            (identical(
                  other.enablePushNotifications,
                  enablePushNotifications,
                ) ||
                other.enablePushNotifications == enablePushNotifications) &&
            const DeepCollectionEquality().equals(
              other._emailTemplates,
              _emailTemplates,
            ) &&
            const DeepCollectionEquality().equals(
              other._smsTemplates,
              _smsTemplates,
            ) &&
            (identical(other.triggerRules, triggerRules) ||
                other.triggerRules == triggerRules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enableEmailNotifications,
    enableSMSNotifications,
    enablePushNotifications,
    const DeepCollectionEquality().hash(_emailTemplates),
    const DeepCollectionEquality().hash(_smsTemplates),
    triggerRules,
  );

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      __$$NotificationConfigImplCopyWithImpl<_$NotificationConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationConfigImplToJson(this);
  }
}

abstract class _NotificationConfig implements NotificationConfig {
  const factory _NotificationConfig({
    final bool enableEmailNotifications,
    final bool enableSMSNotifications,
    final bool enablePushNotifications,
    final Map<String, String> emailTemplates,
    final Map<String, String> smsTemplates,
    final NotificationTriggerRules triggerRules,
  }) = _$NotificationConfigImpl;

  factory _NotificationConfig.fromJson(Map<String, dynamic> json) =
      _$NotificationConfigImpl.fromJson;

  @override
  bool get enableEmailNotifications;
  @override
  bool get enableSMSNotifications;
  @override
  bool get enablePushNotifications;
  @override
  Map<String, String> get emailTemplates;
  @override
  Map<String, String> get smsTemplates;
  @override
  NotificationTriggerRules get triggerRules;

  /// Create a copy of NotificationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationConfigImplCopyWith<_$NotificationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationTriggerRules _$NotificationTriggerRulesFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationTriggerRules.fromJson(json);
}

/// @nodoc
mixin _$NotificationTriggerRules {
  bool get notifyOnNewOrder => throw _privateConstructorUsedError;
  bool get notifyOnLowStock => throw _privateConstructorUsedError;
  bool get notifyOnSystemError => throw _privateConstructorUsedError;
  bool get notifyOnNewExpertAppointment => throw _privateConstructorUsedError;
  bool get notifyOnNewWithdrawal => throw _privateConstructorUsedError;
  bool get notifyOnPriceSpike => throw _privateConstructorUsedError;
  bool get notifyOnExpertVerification => throw _privateConstructorUsedError;
  bool get notifyOnUserReport => throw _privateConstructorUsedError;
  bool get notifyOnSystemMaintenance => throw _privateConstructorUsedError;

  /// Serializes this NotificationTriggerRules to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTriggerRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTriggerRulesCopyWith<NotificationTriggerRules> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTriggerRulesCopyWith<$Res> {
  factory $NotificationTriggerRulesCopyWith(
    NotificationTriggerRules value,
    $Res Function(NotificationTriggerRules) then,
  ) = _$NotificationTriggerRulesCopyWithImpl<$Res, NotificationTriggerRules>;
  @useResult
  $Res call({
    bool notifyOnNewOrder,
    bool notifyOnLowStock,
    bool notifyOnSystemError,
    bool notifyOnNewExpertAppointment,
    bool notifyOnNewWithdrawal,
    bool notifyOnPriceSpike,
    bool notifyOnExpertVerification,
    bool notifyOnUserReport,
    bool notifyOnSystemMaintenance,
  });
}

/// @nodoc
class _$NotificationTriggerRulesCopyWithImpl<
  $Res,
  $Val extends NotificationTriggerRules
>
    implements $NotificationTriggerRulesCopyWith<$Res> {
  _$NotificationTriggerRulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTriggerRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifyOnNewOrder = null,
    Object? notifyOnLowStock = null,
    Object? notifyOnSystemError = null,
    Object? notifyOnNewExpertAppointment = null,
    Object? notifyOnNewWithdrawal = null,
    Object? notifyOnPriceSpike = null,
    Object? notifyOnExpertVerification = null,
    Object? notifyOnUserReport = null,
    Object? notifyOnSystemMaintenance = null,
  }) {
    return _then(
      _value.copyWith(
            notifyOnNewOrder: null == notifyOnNewOrder
                ? _value.notifyOnNewOrder
                : notifyOnNewOrder // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnLowStock: null == notifyOnLowStock
                ? _value.notifyOnLowStock
                : notifyOnLowStock // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnSystemError: null == notifyOnSystemError
                ? _value.notifyOnSystemError
                : notifyOnSystemError // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnNewExpertAppointment: null == notifyOnNewExpertAppointment
                ? _value.notifyOnNewExpertAppointment
                : notifyOnNewExpertAppointment // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnNewWithdrawal: null == notifyOnNewWithdrawal
                ? _value.notifyOnNewWithdrawal
                : notifyOnNewWithdrawal // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnPriceSpike: null == notifyOnPriceSpike
                ? _value.notifyOnPriceSpike
                : notifyOnPriceSpike // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnExpertVerification: null == notifyOnExpertVerification
                ? _value.notifyOnExpertVerification
                : notifyOnExpertVerification // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnUserReport: null == notifyOnUserReport
                ? _value.notifyOnUserReport
                : notifyOnUserReport // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyOnSystemMaintenance: null == notifyOnSystemMaintenance
                ? _value.notifyOnSystemMaintenance
                : notifyOnSystemMaintenance // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationTriggerRulesImplCopyWith<$Res>
    implements $NotificationTriggerRulesCopyWith<$Res> {
  factory _$$NotificationTriggerRulesImplCopyWith(
    _$NotificationTriggerRulesImpl value,
    $Res Function(_$NotificationTriggerRulesImpl) then,
  ) = __$$NotificationTriggerRulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool notifyOnNewOrder,
    bool notifyOnLowStock,
    bool notifyOnSystemError,
    bool notifyOnNewExpertAppointment,
    bool notifyOnNewWithdrawal,
    bool notifyOnPriceSpike,
    bool notifyOnExpertVerification,
    bool notifyOnUserReport,
    bool notifyOnSystemMaintenance,
  });
}

/// @nodoc
class __$$NotificationTriggerRulesImplCopyWithImpl<$Res>
    extends
        _$NotificationTriggerRulesCopyWithImpl<
          $Res,
          _$NotificationTriggerRulesImpl
        >
    implements _$$NotificationTriggerRulesImplCopyWith<$Res> {
  __$$NotificationTriggerRulesImplCopyWithImpl(
    _$NotificationTriggerRulesImpl _value,
    $Res Function(_$NotificationTriggerRulesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationTriggerRules
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifyOnNewOrder = null,
    Object? notifyOnLowStock = null,
    Object? notifyOnSystemError = null,
    Object? notifyOnNewExpertAppointment = null,
    Object? notifyOnNewWithdrawal = null,
    Object? notifyOnPriceSpike = null,
    Object? notifyOnExpertVerification = null,
    Object? notifyOnUserReport = null,
    Object? notifyOnSystemMaintenance = null,
  }) {
    return _then(
      _$NotificationTriggerRulesImpl(
        notifyOnNewOrder: null == notifyOnNewOrder
            ? _value.notifyOnNewOrder
            : notifyOnNewOrder // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnLowStock: null == notifyOnLowStock
            ? _value.notifyOnLowStock
            : notifyOnLowStock // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnSystemError: null == notifyOnSystemError
            ? _value.notifyOnSystemError
            : notifyOnSystemError // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnNewExpertAppointment: null == notifyOnNewExpertAppointment
            ? _value.notifyOnNewExpertAppointment
            : notifyOnNewExpertAppointment // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnNewWithdrawal: null == notifyOnNewWithdrawal
            ? _value.notifyOnNewWithdrawal
            : notifyOnNewWithdrawal // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnPriceSpike: null == notifyOnPriceSpike
            ? _value.notifyOnPriceSpike
            : notifyOnPriceSpike // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnExpertVerification: null == notifyOnExpertVerification
            ? _value.notifyOnExpertVerification
            : notifyOnExpertVerification // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnUserReport: null == notifyOnUserReport
            ? _value.notifyOnUserReport
            : notifyOnUserReport // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyOnSystemMaintenance: null == notifyOnSystemMaintenance
            ? _value.notifyOnSystemMaintenance
            : notifyOnSystemMaintenance // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationTriggerRulesImpl implements _NotificationTriggerRules {
  const _$NotificationTriggerRulesImpl({
    this.notifyOnNewOrder = true,
    this.notifyOnLowStock = true,
    this.notifyOnSystemError = true,
    this.notifyOnNewExpertAppointment = true,
    this.notifyOnNewWithdrawal = true,
    this.notifyOnPriceSpike = true,
    this.notifyOnExpertVerification = true,
    this.notifyOnUserReport = true,
    this.notifyOnSystemMaintenance = true,
  });

  factory _$NotificationTriggerRulesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTriggerRulesImplFromJson(json);

  @override
  @JsonKey()
  final bool notifyOnNewOrder;
  @override
  @JsonKey()
  final bool notifyOnLowStock;
  @override
  @JsonKey()
  final bool notifyOnSystemError;
  @override
  @JsonKey()
  final bool notifyOnNewExpertAppointment;
  @override
  @JsonKey()
  final bool notifyOnNewWithdrawal;
  @override
  @JsonKey()
  final bool notifyOnPriceSpike;
  @override
  @JsonKey()
  final bool notifyOnExpertVerification;
  @override
  @JsonKey()
  final bool notifyOnUserReport;
  @override
  @JsonKey()
  final bool notifyOnSystemMaintenance;

  @override
  String toString() {
    return 'NotificationTriggerRules(notifyOnNewOrder: $notifyOnNewOrder, notifyOnLowStock: $notifyOnLowStock, notifyOnSystemError: $notifyOnSystemError, notifyOnNewExpertAppointment: $notifyOnNewExpertAppointment, notifyOnNewWithdrawal: $notifyOnNewWithdrawal, notifyOnPriceSpike: $notifyOnPriceSpike, notifyOnExpertVerification: $notifyOnExpertVerification, notifyOnUserReport: $notifyOnUserReport, notifyOnSystemMaintenance: $notifyOnSystemMaintenance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTriggerRulesImpl &&
            (identical(other.notifyOnNewOrder, notifyOnNewOrder) ||
                other.notifyOnNewOrder == notifyOnNewOrder) &&
            (identical(other.notifyOnLowStock, notifyOnLowStock) ||
                other.notifyOnLowStock == notifyOnLowStock) &&
            (identical(other.notifyOnSystemError, notifyOnSystemError) ||
                other.notifyOnSystemError == notifyOnSystemError) &&
            (identical(
                  other.notifyOnNewExpertAppointment,
                  notifyOnNewExpertAppointment,
                ) ||
                other.notifyOnNewExpertAppointment ==
                    notifyOnNewExpertAppointment) &&
            (identical(other.notifyOnNewWithdrawal, notifyOnNewWithdrawal) ||
                other.notifyOnNewWithdrawal == notifyOnNewWithdrawal) &&
            (identical(other.notifyOnPriceSpike, notifyOnPriceSpike) ||
                other.notifyOnPriceSpike == notifyOnPriceSpike) &&
            (identical(
                  other.notifyOnExpertVerification,
                  notifyOnExpertVerification,
                ) ||
                other.notifyOnExpertVerification ==
                    notifyOnExpertVerification) &&
            (identical(other.notifyOnUserReport, notifyOnUserReport) ||
                other.notifyOnUserReport == notifyOnUserReport) &&
            (identical(
                  other.notifyOnSystemMaintenance,
                  notifyOnSystemMaintenance,
                ) ||
                other.notifyOnSystemMaintenance == notifyOnSystemMaintenance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    notifyOnNewOrder,
    notifyOnLowStock,
    notifyOnSystemError,
    notifyOnNewExpertAppointment,
    notifyOnNewWithdrawal,
    notifyOnPriceSpike,
    notifyOnExpertVerification,
    notifyOnUserReport,
    notifyOnSystemMaintenance,
  );

  /// Create a copy of NotificationTriggerRules
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTriggerRulesImplCopyWith<_$NotificationTriggerRulesImpl>
  get copyWith =>
      __$$NotificationTriggerRulesImplCopyWithImpl<
        _$NotificationTriggerRulesImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTriggerRulesImplToJson(this);
  }
}

abstract class _NotificationTriggerRules implements NotificationTriggerRules {
  const factory _NotificationTriggerRules({
    final bool notifyOnNewOrder,
    final bool notifyOnLowStock,
    final bool notifyOnSystemError,
    final bool notifyOnNewExpertAppointment,
    final bool notifyOnNewWithdrawal,
    final bool notifyOnPriceSpike,
    final bool notifyOnExpertVerification,
    final bool notifyOnUserReport,
    final bool notifyOnSystemMaintenance,
  }) = _$NotificationTriggerRulesImpl;

  factory _NotificationTriggerRules.fromJson(Map<String, dynamic> json) =
      _$NotificationTriggerRulesImpl.fromJson;

  @override
  bool get notifyOnNewOrder;
  @override
  bool get notifyOnLowStock;
  @override
  bool get notifyOnSystemError;
  @override
  bool get notifyOnNewExpertAppointment;
  @override
  bool get notifyOnNewWithdrawal;
  @override
  bool get notifyOnPriceSpike;
  @override
  bool get notifyOnExpertVerification;
  @override
  bool get notifyOnUserReport;
  @override
  bool get notifyOnSystemMaintenance;

  /// Create a copy of NotificationTriggerRules
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTriggerRulesImplCopyWith<_$NotificationTriggerRulesImpl>
  get copyWith => throw _privateConstructorUsedError;
}
