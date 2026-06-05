// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature_flags.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeatureFlags _$FeatureFlagsFromJson(Map<String, dynamic> json) {
  return _FeatureFlags.fromJson(json);
}

/// @nodoc
mixin _$FeatureFlags {
  bool get enableOrderManagement => throw _privateConstructorUsedError;
  bool get enableAIAnalytics => throw _privateConstructorUsedError;
  bool get enableExpertManagement => throw _privateConstructorUsedError;
  bool get enablePromotions => throw _privateConstructorUsedError;
  bool get enableBetaFeatures => throw _privateConstructorUsedError;
  int get betaRolloutPercentage => throw _privateConstructorUsedError;
  bool get isMaintenanceMode => throw _privateConstructorUsedError;
  String get maintenanceMessage => throw _privateConstructorUsedError;
  Map<String, bool> get customFlags => throw _privateConstructorUsedError;

  /// Serializes this FeatureFlags to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeatureFlagsCopyWith<FeatureFlags> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureFlagsCopyWith<$Res> {
  factory $FeatureFlagsCopyWith(
    FeatureFlags value,
    $Res Function(FeatureFlags) then,
  ) = _$FeatureFlagsCopyWithImpl<$Res, FeatureFlags>;
  @useResult
  $Res call({
    bool enableOrderManagement,
    bool enableAIAnalytics,
    bool enableExpertManagement,
    bool enablePromotions,
    bool enableBetaFeatures,
    int betaRolloutPercentage,
    bool isMaintenanceMode,
    String maintenanceMessage,
    Map<String, bool> customFlags,
  });
}

/// @nodoc
class _$FeatureFlagsCopyWithImpl<$Res, $Val extends FeatureFlags>
    implements $FeatureFlagsCopyWith<$Res> {
  _$FeatureFlagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableOrderManagement = null,
    Object? enableAIAnalytics = null,
    Object? enableExpertManagement = null,
    Object? enablePromotions = null,
    Object? enableBetaFeatures = null,
    Object? betaRolloutPercentage = null,
    Object? isMaintenanceMode = null,
    Object? maintenanceMessage = null,
    Object? customFlags = null,
  }) {
    return _then(
      _value.copyWith(
            enableOrderManagement: null == enableOrderManagement
                ? _value.enableOrderManagement
                : enableOrderManagement // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableAIAnalytics: null == enableAIAnalytics
                ? _value.enableAIAnalytics
                : enableAIAnalytics // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableExpertManagement: null == enableExpertManagement
                ? _value.enableExpertManagement
                : enableExpertManagement // ignore: cast_nullable_to_non_nullable
                      as bool,
            enablePromotions: null == enablePromotions
                ? _value.enablePromotions
                : enablePromotions // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableBetaFeatures: null == enableBetaFeatures
                ? _value.enableBetaFeatures
                : enableBetaFeatures // ignore: cast_nullable_to_non_nullable
                      as bool,
            betaRolloutPercentage: null == betaRolloutPercentage
                ? _value.betaRolloutPercentage
                : betaRolloutPercentage // ignore: cast_nullable_to_non_nullable
                      as int,
            isMaintenanceMode: null == isMaintenanceMode
                ? _value.isMaintenanceMode
                : isMaintenanceMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            maintenanceMessage: null == maintenanceMessage
                ? _value.maintenanceMessage
                : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            customFlags: null == customFlags
                ? _value.customFlags
                : customFlags // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeatureFlagsImplCopyWith<$Res>
    implements $FeatureFlagsCopyWith<$Res> {
  factory _$$FeatureFlagsImplCopyWith(
    _$FeatureFlagsImpl value,
    $Res Function(_$FeatureFlagsImpl) then,
  ) = __$$FeatureFlagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enableOrderManagement,
    bool enableAIAnalytics,
    bool enableExpertManagement,
    bool enablePromotions,
    bool enableBetaFeatures,
    int betaRolloutPercentage,
    bool isMaintenanceMode,
    String maintenanceMessage,
    Map<String, bool> customFlags,
  });
}

/// @nodoc
class __$$FeatureFlagsImplCopyWithImpl<$Res>
    extends _$FeatureFlagsCopyWithImpl<$Res, _$FeatureFlagsImpl>
    implements _$$FeatureFlagsImplCopyWith<$Res> {
  __$$FeatureFlagsImplCopyWithImpl(
    _$FeatureFlagsImpl _value,
    $Res Function(_$FeatureFlagsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableOrderManagement = null,
    Object? enableAIAnalytics = null,
    Object? enableExpertManagement = null,
    Object? enablePromotions = null,
    Object? enableBetaFeatures = null,
    Object? betaRolloutPercentage = null,
    Object? isMaintenanceMode = null,
    Object? maintenanceMessage = null,
    Object? customFlags = null,
  }) {
    return _then(
      _$FeatureFlagsImpl(
        enableOrderManagement: null == enableOrderManagement
            ? _value.enableOrderManagement
            : enableOrderManagement // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableAIAnalytics: null == enableAIAnalytics
            ? _value.enableAIAnalytics
            : enableAIAnalytics // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableExpertManagement: null == enableExpertManagement
            ? _value.enableExpertManagement
            : enableExpertManagement // ignore: cast_nullable_to_non_nullable
                  as bool,
        enablePromotions: null == enablePromotions
            ? _value.enablePromotions
            : enablePromotions // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableBetaFeatures: null == enableBetaFeatures
            ? _value.enableBetaFeatures
            : enableBetaFeatures // ignore: cast_nullable_to_non_nullable
                  as bool,
        betaRolloutPercentage: null == betaRolloutPercentage
            ? _value.betaRolloutPercentage
            : betaRolloutPercentage // ignore: cast_nullable_to_non_nullable
                  as int,
        isMaintenanceMode: null == isMaintenanceMode
            ? _value.isMaintenanceMode
            : isMaintenanceMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        maintenanceMessage: null == maintenanceMessage
            ? _value.maintenanceMessage
            : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        customFlags: null == customFlags
            ? _value._customFlags
            : customFlags // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureFlagsImpl implements _FeatureFlags {
  const _$FeatureFlagsImpl({
    this.enableOrderManagement = true,
    this.enableAIAnalytics = true,
    this.enableExpertManagement = true,
    this.enablePromotions = true,
    this.enableBetaFeatures = false,
    this.betaRolloutPercentage = 10,
    this.isMaintenanceMode = false,
    this.maintenanceMessage = 'Hệ thống đang bảo trì, vui lòng quay lại sau.',
    final Map<String, bool> customFlags = const {},
  }) : _customFlags = customFlags;

  factory _$FeatureFlagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureFlagsImplFromJson(json);

  @override
  @JsonKey()
  final bool enableOrderManagement;
  @override
  @JsonKey()
  final bool enableAIAnalytics;
  @override
  @JsonKey()
  final bool enableExpertManagement;
  @override
  @JsonKey()
  final bool enablePromotions;
  @override
  @JsonKey()
  final bool enableBetaFeatures;
  @override
  @JsonKey()
  final int betaRolloutPercentage;
  @override
  @JsonKey()
  final bool isMaintenanceMode;
  @override
  @JsonKey()
  final String maintenanceMessage;
  final Map<String, bool> _customFlags;
  @override
  @JsonKey()
  Map<String, bool> get customFlags {
    if (_customFlags is EqualUnmodifiableMapView) return _customFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customFlags);
  }

  @override
  String toString() {
    return 'FeatureFlags(enableOrderManagement: $enableOrderManagement, enableAIAnalytics: $enableAIAnalytics, enableExpertManagement: $enableExpertManagement, enablePromotions: $enablePromotions, enableBetaFeatures: $enableBetaFeatures, betaRolloutPercentage: $betaRolloutPercentage, isMaintenanceMode: $isMaintenanceMode, maintenanceMessage: $maintenanceMessage, customFlags: $customFlags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureFlagsImpl &&
            (identical(other.enableOrderManagement, enableOrderManagement) ||
                other.enableOrderManagement == enableOrderManagement) &&
            (identical(other.enableAIAnalytics, enableAIAnalytics) ||
                other.enableAIAnalytics == enableAIAnalytics) &&
            (identical(other.enableExpertManagement, enableExpertManagement) ||
                other.enableExpertManagement == enableExpertManagement) &&
            (identical(other.enablePromotions, enablePromotions) ||
                other.enablePromotions == enablePromotions) &&
            (identical(other.enableBetaFeatures, enableBetaFeatures) ||
                other.enableBetaFeatures == enableBetaFeatures) &&
            (identical(other.betaRolloutPercentage, betaRolloutPercentage) ||
                other.betaRolloutPercentage == betaRolloutPercentage) &&
            (identical(other.isMaintenanceMode, isMaintenanceMode) ||
                other.isMaintenanceMode == isMaintenanceMode) &&
            (identical(other.maintenanceMessage, maintenanceMessage) ||
                other.maintenanceMessage == maintenanceMessage) &&
            const DeepCollectionEquality().equals(
              other._customFlags,
              _customFlags,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enableOrderManagement,
    enableAIAnalytics,
    enableExpertManagement,
    enablePromotions,
    enableBetaFeatures,
    betaRolloutPercentage,
    isMaintenanceMode,
    maintenanceMessage,
    const DeepCollectionEquality().hash(_customFlags),
  );

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureFlagsImplCopyWith<_$FeatureFlagsImpl> get copyWith =>
      __$$FeatureFlagsImplCopyWithImpl<_$FeatureFlagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureFlagsImplToJson(this);
  }
}

abstract class _FeatureFlags implements FeatureFlags {
  const factory _FeatureFlags({
    final bool enableOrderManagement,
    final bool enableAIAnalytics,
    final bool enableExpertManagement,
    final bool enablePromotions,
    final bool enableBetaFeatures,
    final int betaRolloutPercentage,
    final bool isMaintenanceMode,
    final String maintenanceMessage,
    final Map<String, bool> customFlags,
  }) = _$FeatureFlagsImpl;

  factory _FeatureFlags.fromJson(Map<String, dynamic> json) =
      _$FeatureFlagsImpl.fromJson;

  @override
  bool get enableOrderManagement;
  @override
  bool get enableAIAnalytics;
  @override
  bool get enableExpertManagement;
  @override
  bool get enablePromotions;
  @override
  bool get enableBetaFeatures;
  @override
  int get betaRolloutPercentage;
  @override
  bool get isMaintenanceMode;
  @override
  String get maintenanceMessage;
  @override
  Map<String, bool> get customFlags;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeatureFlagsImplCopyWith<_$FeatureFlagsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
