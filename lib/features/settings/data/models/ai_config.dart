import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_config.freezed.dart';
part 'ai_config.g.dart';

@freezed
class AIConfig with _$AIConfig {
  const factory AIConfig({
    @Default('gemini-1.5-flash') String selectedModel,
    @Default(0.7) double temperature,
    @Default('You are a helpful agriculture expert assistant...') String systemPrompt,
    @Default('') String apiKey,
    @Default('') String weatherApiKey,
    @Default('') String emailApiKey,
    @Default('') String smsApiKey,
    @Default(AIGovernanceConfig()) AIGovernanceConfig governance,
  }) = _AIConfig;

  factory AIConfig.fromJson(Map<String, dynamic> json) =>
      _$AIConfigFromJson(json);
}

@freezed
class AIGovernanceConfig with _$AIGovernanceConfig {
  const factory AIGovernanceConfig({
    @Default(1000) int dailyUsageLimit,
    @Default('gpt-4o-mini') String fallbackModel,
    @Default('1.0.0') String promptVersion,
    @Default(true) bool enableSafetyFilters,
  }) = _AIGovernanceConfig;

  factory AIGovernanceConfig.fromJson(Map<String, dynamic> json) =>
      _$AIGovernanceConfigFromJson(json);
}
