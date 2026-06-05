// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AIConfig _$AIConfigFromJson(Map<String, dynamic> json) {
  return _AIConfig.fromJson(json);
}

/// @nodoc
mixin _$AIConfig {
  String get selectedModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  String get apiKey => throw _privateConstructorUsedError;
  String get weatherApiKey => throw _privateConstructorUsedError;
  String get emailApiKey => throw _privateConstructorUsedError;
  String get smsApiKey => throw _privateConstructorUsedError;
  AIGovernanceConfig get governance => throw _privateConstructorUsedError;

  /// Serializes this AIConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConfigCopyWith<AIConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConfigCopyWith<$Res> {
  factory $AIConfigCopyWith(AIConfig value, $Res Function(AIConfig) then) =
      _$AIConfigCopyWithImpl<$Res, AIConfig>;
  @useResult
  $Res call({
    String selectedModel,
    double temperature,
    String systemPrompt,
    String apiKey,
    String weatherApiKey,
    String emailApiKey,
    String smsApiKey,
    AIGovernanceConfig governance,
  });

  $AIGovernanceConfigCopyWith<$Res> get governance;
}

/// @nodoc
class _$AIConfigCopyWithImpl<$Res, $Val extends AIConfig>
    implements $AIConfigCopyWith<$Res> {
  _$AIConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedModel = null,
    Object? temperature = null,
    Object? systemPrompt = null,
    Object? apiKey = null,
    Object? weatherApiKey = null,
    Object? emailApiKey = null,
    Object? smsApiKey = null,
    Object? governance = null,
  }) {
    return _then(
      _value.copyWith(
            selectedModel: null == selectedModel
                ? _value.selectedModel
                : selectedModel // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            systemPrompt: null == systemPrompt
                ? _value.systemPrompt
                : systemPrompt // ignore: cast_nullable_to_non_nullable
                      as String,
            apiKey: null == apiKey
                ? _value.apiKey
                : apiKey // ignore: cast_nullable_to_non_nullable
                      as String,
            weatherApiKey: null == weatherApiKey
                ? _value.weatherApiKey
                : weatherApiKey // ignore: cast_nullable_to_non_nullable
                      as String,
            emailApiKey: null == emailApiKey
                ? _value.emailApiKey
                : emailApiKey // ignore: cast_nullable_to_non_nullable
                      as String,
            smsApiKey: null == smsApiKey
                ? _value.smsApiKey
                : smsApiKey // ignore: cast_nullable_to_non_nullable
                      as String,
            governance: null == governance
                ? _value.governance
                : governance // ignore: cast_nullable_to_non_nullable
                      as AIGovernanceConfig,
          )
          as $Val,
    );
  }

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIGovernanceConfigCopyWith<$Res> get governance {
    return $AIGovernanceConfigCopyWith<$Res>(_value.governance, (value) {
      return _then(_value.copyWith(governance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AIConfigImplCopyWith<$Res>
    implements $AIConfigCopyWith<$Res> {
  factory _$$AIConfigImplCopyWith(
    _$AIConfigImpl value,
    $Res Function(_$AIConfigImpl) then,
  ) = __$$AIConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String selectedModel,
    double temperature,
    String systemPrompt,
    String apiKey,
    String weatherApiKey,
    String emailApiKey,
    String smsApiKey,
    AIGovernanceConfig governance,
  });

  @override
  $AIGovernanceConfigCopyWith<$Res> get governance;
}

/// @nodoc
class __$$AIConfigImplCopyWithImpl<$Res>
    extends _$AIConfigCopyWithImpl<$Res, _$AIConfigImpl>
    implements _$$AIConfigImplCopyWith<$Res> {
  __$$AIConfigImplCopyWithImpl(
    _$AIConfigImpl _value,
    $Res Function(_$AIConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedModel = null,
    Object? temperature = null,
    Object? systemPrompt = null,
    Object? apiKey = null,
    Object? weatherApiKey = null,
    Object? emailApiKey = null,
    Object? smsApiKey = null,
    Object? governance = null,
  }) {
    return _then(
      _$AIConfigImpl(
        selectedModel: null == selectedModel
            ? _value.selectedModel
            : selectedModel // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        systemPrompt: null == systemPrompt
            ? _value.systemPrompt
            : systemPrompt // ignore: cast_nullable_to_non_nullable
                  as String,
        apiKey: null == apiKey
            ? _value.apiKey
            : apiKey // ignore: cast_nullable_to_non_nullable
                  as String,
        weatherApiKey: null == weatherApiKey
            ? _value.weatherApiKey
            : weatherApiKey // ignore: cast_nullable_to_non_nullable
                  as String,
        emailApiKey: null == emailApiKey
            ? _value.emailApiKey
            : emailApiKey // ignore: cast_nullable_to_non_nullable
                  as String,
        smsApiKey: null == smsApiKey
            ? _value.smsApiKey
            : smsApiKey // ignore: cast_nullable_to_non_nullable
                  as String,
        governance: null == governance
            ? _value.governance
            : governance // ignore: cast_nullable_to_non_nullable
                  as AIGovernanceConfig,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConfigImpl implements _AIConfig {
  const _$AIConfigImpl({
    this.selectedModel = 'gemini-1.5-flash',
    this.temperature = 0.7,
    this.systemPrompt = 'You are a helpful agriculture expert assistant...',
    this.apiKey = '',
    this.weatherApiKey = '',
    this.emailApiKey = '',
    this.smsApiKey = '',
    this.governance = const AIGovernanceConfig(),
  });

  factory _$AIConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConfigImplFromJson(json);

  @override
  @JsonKey()
  final String selectedModel;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final String systemPrompt;
  @override
  @JsonKey()
  final String apiKey;
  @override
  @JsonKey()
  final String weatherApiKey;
  @override
  @JsonKey()
  final String emailApiKey;
  @override
  @JsonKey()
  final String smsApiKey;
  @override
  @JsonKey()
  final AIGovernanceConfig governance;

  @override
  String toString() {
    return 'AIConfig(selectedModel: $selectedModel, temperature: $temperature, systemPrompt: $systemPrompt, apiKey: $apiKey, weatherApiKey: $weatherApiKey, emailApiKey: $emailApiKey, smsApiKey: $smsApiKey, governance: $governance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConfigImpl &&
            (identical(other.selectedModel, selectedModel) ||
                other.selectedModel == selectedModel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.weatherApiKey, weatherApiKey) ||
                other.weatherApiKey == weatherApiKey) &&
            (identical(other.emailApiKey, emailApiKey) ||
                other.emailApiKey == emailApiKey) &&
            (identical(other.smsApiKey, smsApiKey) ||
                other.smsApiKey == smsApiKey) &&
            (identical(other.governance, governance) ||
                other.governance == governance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedModel,
    temperature,
    systemPrompt,
    apiKey,
    weatherApiKey,
    emailApiKey,
    smsApiKey,
    governance,
  );

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConfigImplCopyWith<_$AIConfigImpl> get copyWith =>
      __$$AIConfigImplCopyWithImpl<_$AIConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConfigImplToJson(this);
  }
}

abstract class _AIConfig implements AIConfig {
  const factory _AIConfig({
    final String selectedModel,
    final double temperature,
    final String systemPrompt,
    final String apiKey,
    final String weatherApiKey,
    final String emailApiKey,
    final String smsApiKey,
    final AIGovernanceConfig governance,
  }) = _$AIConfigImpl;

  factory _AIConfig.fromJson(Map<String, dynamic> json) =
      _$AIConfigImpl.fromJson;

  @override
  String get selectedModel;
  @override
  double get temperature;
  @override
  String get systemPrompt;
  @override
  String get apiKey;
  @override
  String get weatherApiKey;
  @override
  String get emailApiKey;
  @override
  String get smsApiKey;
  @override
  AIGovernanceConfig get governance;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConfigImplCopyWith<_$AIConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIGovernanceConfig _$AIGovernanceConfigFromJson(Map<String, dynamic> json) {
  return _AIGovernanceConfig.fromJson(json);
}

/// @nodoc
mixin _$AIGovernanceConfig {
  int get dailyUsageLimit => throw _privateConstructorUsedError;
  String get fallbackModel => throw _privateConstructorUsedError;
  String get promptVersion => throw _privateConstructorUsedError;
  bool get enableSafetyFilters => throw _privateConstructorUsedError;

  /// Serializes this AIGovernanceConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIGovernanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIGovernanceConfigCopyWith<AIGovernanceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIGovernanceConfigCopyWith<$Res> {
  factory $AIGovernanceConfigCopyWith(
    AIGovernanceConfig value,
    $Res Function(AIGovernanceConfig) then,
  ) = _$AIGovernanceConfigCopyWithImpl<$Res, AIGovernanceConfig>;
  @useResult
  $Res call({
    int dailyUsageLimit,
    String fallbackModel,
    String promptVersion,
    bool enableSafetyFilters,
  });
}

/// @nodoc
class _$AIGovernanceConfigCopyWithImpl<$Res, $Val extends AIGovernanceConfig>
    implements $AIGovernanceConfigCopyWith<$Res> {
  _$AIGovernanceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIGovernanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyUsageLimit = null,
    Object? fallbackModel = null,
    Object? promptVersion = null,
    Object? enableSafetyFilters = null,
  }) {
    return _then(
      _value.copyWith(
            dailyUsageLimit: null == dailyUsageLimit
                ? _value.dailyUsageLimit
                : dailyUsageLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            fallbackModel: null == fallbackModel
                ? _value.fallbackModel
                : fallbackModel // ignore: cast_nullable_to_non_nullable
                      as String,
            promptVersion: null == promptVersion
                ? _value.promptVersion
                : promptVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            enableSafetyFilters: null == enableSafetyFilters
                ? _value.enableSafetyFilters
                : enableSafetyFilters // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIGovernanceConfigImplCopyWith<$Res>
    implements $AIGovernanceConfigCopyWith<$Res> {
  factory _$$AIGovernanceConfigImplCopyWith(
    _$AIGovernanceConfigImpl value,
    $Res Function(_$AIGovernanceConfigImpl) then,
  ) = __$$AIGovernanceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dailyUsageLimit,
    String fallbackModel,
    String promptVersion,
    bool enableSafetyFilters,
  });
}

/// @nodoc
class __$$AIGovernanceConfigImplCopyWithImpl<$Res>
    extends _$AIGovernanceConfigCopyWithImpl<$Res, _$AIGovernanceConfigImpl>
    implements _$$AIGovernanceConfigImplCopyWith<$Res> {
  __$$AIGovernanceConfigImplCopyWithImpl(
    _$AIGovernanceConfigImpl _value,
    $Res Function(_$AIGovernanceConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIGovernanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyUsageLimit = null,
    Object? fallbackModel = null,
    Object? promptVersion = null,
    Object? enableSafetyFilters = null,
  }) {
    return _then(
      _$AIGovernanceConfigImpl(
        dailyUsageLimit: null == dailyUsageLimit
            ? _value.dailyUsageLimit
            : dailyUsageLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        fallbackModel: null == fallbackModel
            ? _value.fallbackModel
            : fallbackModel // ignore: cast_nullable_to_non_nullable
                  as String,
        promptVersion: null == promptVersion
            ? _value.promptVersion
            : promptVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        enableSafetyFilters: null == enableSafetyFilters
            ? _value.enableSafetyFilters
            : enableSafetyFilters // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIGovernanceConfigImpl implements _AIGovernanceConfig {
  const _$AIGovernanceConfigImpl({
    this.dailyUsageLimit = 1000,
    this.fallbackModel = 'gpt-4o-mini',
    this.promptVersion = '1.0.0',
    this.enableSafetyFilters = true,
  });

  factory _$AIGovernanceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIGovernanceConfigImplFromJson(json);

  @override
  @JsonKey()
  final int dailyUsageLimit;
  @override
  @JsonKey()
  final String fallbackModel;
  @override
  @JsonKey()
  final String promptVersion;
  @override
  @JsonKey()
  final bool enableSafetyFilters;

  @override
  String toString() {
    return 'AIGovernanceConfig(dailyUsageLimit: $dailyUsageLimit, fallbackModel: $fallbackModel, promptVersion: $promptVersion, enableSafetyFilters: $enableSafetyFilters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIGovernanceConfigImpl &&
            (identical(other.dailyUsageLimit, dailyUsageLimit) ||
                other.dailyUsageLimit == dailyUsageLimit) &&
            (identical(other.fallbackModel, fallbackModel) ||
                other.fallbackModel == fallbackModel) &&
            (identical(other.promptVersion, promptVersion) ||
                other.promptVersion == promptVersion) &&
            (identical(other.enableSafetyFilters, enableSafetyFilters) ||
                other.enableSafetyFilters == enableSafetyFilters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dailyUsageLimit,
    fallbackModel,
    promptVersion,
    enableSafetyFilters,
  );

  /// Create a copy of AIGovernanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIGovernanceConfigImplCopyWith<_$AIGovernanceConfigImpl> get copyWith =>
      __$$AIGovernanceConfigImplCopyWithImpl<_$AIGovernanceConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AIGovernanceConfigImplToJson(this);
  }
}

abstract class _AIGovernanceConfig implements AIGovernanceConfig {
  const factory _AIGovernanceConfig({
    final int dailyUsageLimit,
    final String fallbackModel,
    final String promptVersion,
    final bool enableSafetyFilters,
  }) = _$AIGovernanceConfigImpl;

  factory _AIGovernanceConfig.fromJson(Map<String, dynamic> json) =
      _$AIGovernanceConfigImpl.fromJson;

  @override
  int get dailyUsageLimit;
  @override
  String get fallbackModel;
  @override
  String get promptVersion;
  @override
  bool get enableSafetyFilters;

  /// Create a copy of AIGovernanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIGovernanceConfigImplCopyWith<_$AIGovernanceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
