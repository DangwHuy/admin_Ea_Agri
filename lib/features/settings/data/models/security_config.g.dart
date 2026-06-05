// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SecurityConfigImpl _$$SecurityConfigImplFromJson(Map<String, dynamic> json) =>
    _$SecurityConfigImpl(
      ipWhitelist:
          (json['ipWhitelist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sessionTimeoutSeconds:
          (json['sessionTimeoutSeconds'] as num?)?.toInt() ?? 3600,
      passwordPolicy: json['passwordPolicy'] == null
          ? const PasswordPolicy()
          : PasswordPolicy.fromJson(
              json['passwordPolicy'] as Map<String, dynamic>,
            ),
      maxLoginAttempts: (json['maxLoginAttempts'] as num?)?.toInt() ?? 5,
      lockoutDurationMinutes:
          (json['lockoutDurationMinutes'] as num?)?.toInt() ?? 15,
      forceTwoFactorAuth: json['forceTwoFactorAuth'] as bool? ?? true,
      globalForceLogoutTimestamp: const TimestampConverter().fromJson(
        json['globalForceLogoutTimestamp'],
      ),
    );

Map<String, dynamic> _$$SecurityConfigImplToJson(
  _$SecurityConfigImpl instance,
) => <String, dynamic>{
  'ipWhitelist': instance.ipWhitelist,
  'sessionTimeoutSeconds': instance.sessionTimeoutSeconds,
  'passwordPolicy': instance.passwordPolicy,
  'maxLoginAttempts': instance.maxLoginAttempts,
  'lockoutDurationMinutes': instance.lockoutDurationMinutes,
  'forceTwoFactorAuth': instance.forceTwoFactorAuth,
  'globalForceLogoutTimestamp': const TimestampConverter().toJson(
    instance.globalForceLogoutTimestamp,
  ),
};

_$PasswordPolicyImpl _$$PasswordPolicyImplFromJson(Map<String, dynamic> json) =>
    _$PasswordPolicyImpl(
      minLength: (json['minLength'] as num?)?.toInt() ?? 8,
      requireSpecialChar: json['requireSpecialChar'] as bool? ?? true,
      requireNumber: json['requireNumber'] as bool? ?? true,
      requireUppercase: json['requireUppercase'] as bool? ?? true,
      passwordExpiryDays: (json['passwordExpiryDays'] as num?)?.toInt() ?? 90,
    );

Map<String, dynamic> _$$PasswordPolicyImplToJson(
  _$PasswordPolicyImpl instance,
) => <String, dynamic>{
  'minLength': instance.minLength,
  'requireSpecialChar': instance.requireSpecialChar,
  'requireNumber': instance.requireNumber,
  'requireUppercase': instance.requireUppercase,
  'passwordExpiryDays': instance.passwordExpiryDays,
};
