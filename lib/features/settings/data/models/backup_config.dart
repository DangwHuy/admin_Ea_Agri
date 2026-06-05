import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_config.freezed.dart';
part 'backup_config.g.dart';

@freezed
class BackupConfig with _$BackupConfig {
  const factory BackupConfig({
    @Default(true) bool enableAutoBackup,
    @Default('daily') String backupFrequency, // daily, weekly, monthly
    @Default('02:00') String backupTime,
    @Default(30) int retentionDays,
    @Default(true) bool backupToCloudStorage,
    @Default(false) bool backupToExternalServer,
    @Default('') String externalServerUrl,
  }) = _BackupConfig;

  factory BackupConfig.fromJson(Map<String, dynamic> json) =>
      _$BackupConfigFromJson(json);
}
