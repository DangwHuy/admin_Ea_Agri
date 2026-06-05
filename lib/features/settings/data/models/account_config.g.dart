// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountConfigImpl _$$AccountConfigImplFromJson(Map<String, dynamic> json) =>
    _$AccountConfigImpl(
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      enableTwoFactorAuth: json['enableTwoFactorAuth'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'light',
      language: json['language'] as String? ?? 'vi',
      notificationPreferences: json['notificationPreferences'] == null
          ? const NotificationPreferences()
          : NotificationPreferences.fromJson(
              json['notificationPreferences'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$AccountConfigImplToJson(_$AccountConfigImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'email': instance.email,
      'phone': instance.phone,
      'enableTwoFactorAuth': instance.enableTwoFactorAuth,
      'themeMode': instance.themeMode,
      'language': instance.language,
      'notificationPreferences': instance.notificationPreferences,
    };

_$NotificationPreferencesImpl _$$NotificationPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPreferencesImpl(
  emailAlerts: json['emailAlerts'] as bool? ?? true,
  pushAlerts: json['pushAlerts'] as bool? ?? true,
  smsAlerts: json['smsAlerts'] as bool? ?? false,
  marketingEmails: json['marketingEmails'] as bool? ?? true,
);

Map<String, dynamic> _$$NotificationPreferencesImplToJson(
  _$NotificationPreferencesImpl instance,
) => <String, dynamic>{
  'emailAlerts': instance.emailAlerts,
  'pushAlerts': instance.pushAlerts,
  'smsAlerts': instance.smsAlerts,
  'marketingEmails': instance.marketingEmails,
};
