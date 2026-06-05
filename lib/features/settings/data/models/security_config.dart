import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'security_config.freezed.dart';
part 'security_config.g.dart';

@freezed
class SecurityConfig with _$SecurityConfig {
  const factory SecurityConfig({
    @Default([]) List<String> ipWhitelist,
    @Default(3600) int sessionTimeoutSeconds,
    @Default(PasswordPolicy()) PasswordPolicy passwordPolicy,
    @Default(5) int maxLoginAttempts,
    @Default(15) int lockoutDurationMinutes,
    @Default(true) bool forceTwoFactorAuth,
    @TimestampConverter() DateTime? globalForceLogoutTimestamp,
  }) = _SecurityConfig;

  factory SecurityConfig.fromJson(Map<String, dynamic> json) =>
      _$SecurityConfigFromJson(json);
}

@freezed
class PasswordPolicy with _$PasswordPolicy {
  const factory PasswordPolicy({
    @Default(8) int minLength,
    @Default(true) bool requireSpecialChar,
    @Default(true) bool requireNumber,
    @Default(true) bool requireUppercase,
    @Default(90) int passwordExpiryDays,
  }) = _PasswordPolicy;

  factory PasswordPolicy.fromJson(Map<String, dynamic> json) =>
      _$PasswordPolicyFromJson(json);
}
