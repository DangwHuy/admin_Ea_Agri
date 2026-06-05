import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_config.freezed.dart';
part 'account_config.g.dart';

@freezed
class AccountConfig with _$AccountConfig {
  const factory AccountConfig({
    @Default('') String name,
    @Default('') String avatarUrl,
    @Default('') String email,
    @Default('') String phone,
    @Default(false) bool enableTwoFactorAuth,
    @Default('light') String themeMode, // light, dark, system
    @Default('vi') String language,
    @Default(NotificationPreferences()) NotificationPreferences notificationPreferences,
  }) = _AccountConfig;

  factory AccountConfig.fromJson(Map<String, dynamic> json) =>
      _$AccountConfigFromJson(json);
}

@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool emailAlerts,
    @Default(true) bool pushAlerts,
    @Default(false) bool smsAlerts,
    @Default(true) bool marketingEmails,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}
