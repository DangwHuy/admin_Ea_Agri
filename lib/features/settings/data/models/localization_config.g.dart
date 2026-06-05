// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalizationConfigImpl _$$LocalizationConfigImplFromJson(
  Map<String, dynamic> json,
) => _$LocalizationConfigImpl(
  defaultTimezone: json['defaultTimezone'] as String? ?? 'Asia/Ho_Chi_Minh',
  defaultCurrency: json['defaultCurrency'] as String? ?? 'VND',
  dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
  unitSystem: json['unitSystem'] as String? ?? 'metric',
  defaultLanguage: json['defaultLanguage'] as String? ?? 'vi',
);

Map<String, dynamic> _$$LocalizationConfigImplToJson(
  _$LocalizationConfigImpl instance,
) => <String, dynamic>{
  'defaultTimezone': instance.defaultTimezone,
  'defaultCurrency': instance.defaultCurrency,
  'dateFormat': instance.dateFormat,
  'unitSystem': instance.unitSystem,
  'defaultLanguage': instance.defaultLanguage,
};
