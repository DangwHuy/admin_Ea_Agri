// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIConfigImpl _$$AIConfigImplFromJson(Map<String, dynamic> json) =>
    _$AIConfigImpl(
      selectedModel: json['selectedModel'] as String? ?? 'gemini-1.5-flash',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      systemPrompt:
          json['systemPrompt'] as String? ??
          'You are a helpful agriculture expert assistant...',
      apiKey: json['apiKey'] as String? ?? '',
      weatherApiKey: json['weatherApiKey'] as String? ?? '',
      emailApiKey: json['emailApiKey'] as String? ?? '',
      smsApiKey: json['smsApiKey'] as String? ?? '',
      governance: json['governance'] == null
          ? const AIGovernanceConfig()
          : AIGovernanceConfig.fromJson(
              json['governance'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$AIConfigImplToJson(_$AIConfigImpl instance) =>
    <String, dynamic>{
      'selectedModel': instance.selectedModel,
      'temperature': instance.temperature,
      'systemPrompt': instance.systemPrompt,
      'apiKey': instance.apiKey,
      'weatherApiKey': instance.weatherApiKey,
      'emailApiKey': instance.emailApiKey,
      'smsApiKey': instance.smsApiKey,
      'governance': instance.governance,
    };

_$AIGovernanceConfigImpl _$$AIGovernanceConfigImplFromJson(
  Map<String, dynamic> json,
) => _$AIGovernanceConfigImpl(
  dailyUsageLimit: (json['dailyUsageLimit'] as num?)?.toInt() ?? 1000,
  fallbackModel: json['fallbackModel'] as String? ?? 'gpt-4o-mini',
  promptVersion: json['promptVersion'] as String? ?? '1.0.0',
  enableSafetyFilters: json['enableSafetyFilters'] as bool? ?? true,
);

Map<String, dynamic> _$$AIGovernanceConfigImplToJson(
  _$AIGovernanceConfigImpl instance,
) => <String, dynamic>{
  'dailyUsageLimit': instance.dailyUsageLimit,
  'fallbackModel': instance.fallbackModel,
  'promptVersion': instance.promptVersion,
  'enableSafetyFilters': instance.enableSafetyFilters,
};
