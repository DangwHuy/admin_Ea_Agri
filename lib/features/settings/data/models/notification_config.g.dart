// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationConfigImpl _$$NotificationConfigImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationConfigImpl(
  enableEmailNotifications: json['enableEmailNotifications'] as bool? ?? true,
  enableSMSNotifications: json['enableSMSNotifications'] as bool? ?? true,
  enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
  emailTemplates:
      (json['emailTemplates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  smsTemplates:
      (json['smsTemplates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  triggerRules: json['triggerRules'] == null
      ? const NotificationTriggerRules()
      : NotificationTriggerRules.fromJson(
          json['triggerRules'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$NotificationConfigImplToJson(
  _$NotificationConfigImpl instance,
) => <String, dynamic>{
  'enableEmailNotifications': instance.enableEmailNotifications,
  'enableSMSNotifications': instance.enableSMSNotifications,
  'enablePushNotifications': instance.enablePushNotifications,
  'emailTemplates': instance.emailTemplates,
  'smsTemplates': instance.smsTemplates,
  'triggerRules': instance.triggerRules,
};

_$NotificationTriggerRulesImpl _$$NotificationTriggerRulesImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationTriggerRulesImpl(
  notifyOnNewOrder: json['notifyOnNewOrder'] as bool? ?? true,
  notifyOnLowStock: json['notifyOnLowStock'] as bool? ?? true,
  notifyOnSystemError: json['notifyOnSystemError'] as bool? ?? true,
  notifyOnNewExpertAppointment:
      json['notifyOnNewExpertAppointment'] as bool? ?? true,
  notifyOnNewWithdrawal: json['notifyOnNewWithdrawal'] as bool? ?? true,
  notifyOnPriceSpike: json['notifyOnPriceSpike'] as bool? ?? true,
  notifyOnExpertVerification:
      json['notifyOnExpertVerification'] as bool? ?? true,
  notifyOnUserReport: json['notifyOnUserReport'] as bool? ?? true,
  notifyOnSystemMaintenance: json['notifyOnSystemMaintenance'] as bool? ?? true,
);

Map<String, dynamic> _$$NotificationTriggerRulesImplToJson(
  _$NotificationTriggerRulesImpl instance,
) => <String, dynamic>{
  'notifyOnNewOrder': instance.notifyOnNewOrder,
  'notifyOnLowStock': instance.notifyOnLowStock,
  'notifyOnSystemError': instance.notifyOnSystemError,
  'notifyOnNewExpertAppointment': instance.notifyOnNewExpertAppointment,
  'notifyOnNewWithdrawal': instance.notifyOnNewWithdrawal,
  'notifyOnPriceSpike': instance.notifyOnPriceSpike,
  'notifyOnExpertVerification': instance.notifyOnExpertVerification,
  'notifyOnUserReport': instance.notifyOnUserReport,
  'notifyOnSystemMaintenance': instance.notifyOnSystemMaintenance,
};
