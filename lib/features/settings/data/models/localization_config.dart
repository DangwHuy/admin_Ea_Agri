import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_config.freezed.dart';
part 'localization_config.g.dart';

@freezed
class LocalizationConfig with _$LocalizationConfig {
  const factory LocalizationConfig({
    @Default('Asia/Ho_Chi_Minh') String defaultTimezone,
    @Default('VND') String defaultCurrency,
    @Default('dd/MM/yyyy') String dateFormat,
    @Default('metric') String unitSystem, // metric or imperial
    @Default('vi') String defaultLanguage,
  }) = _LocalizationConfig;

  factory LocalizationConfig.fromJson(Map<String, dynamic> json) =>
      _$LocalizationConfigFromJson(json);
}
