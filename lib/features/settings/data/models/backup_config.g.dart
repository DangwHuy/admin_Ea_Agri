// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupConfigImpl _$$BackupConfigImplFromJson(Map<String, dynamic> json) =>
    _$BackupConfigImpl(
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? true,
      backupFrequency: json['backupFrequency'] as String? ?? 'daily',
      backupTime: json['backupTime'] as String? ?? '02:00',
      retentionDays: (json['retentionDays'] as num?)?.toInt() ?? 30,
      backupToCloudStorage: json['backupToCloudStorage'] as bool? ?? true,
      backupToExternalServer: json['backupToExternalServer'] as bool? ?? false,
      externalServerUrl: json['externalServerUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$BackupConfigImplToJson(_$BackupConfigImpl instance) =>
    <String, dynamic>{
      'enableAutoBackup': instance.enableAutoBackup,
      'backupFrequency': instance.backupFrequency,
      'backupTime': instance.backupTime,
      'retentionDays': instance.retentionDays,
      'backupToCloudStorage': instance.backupToCloudStorage,
      'backupToExternalServer': instance.backupToExternalServer,
      'externalServerUrl': instance.externalServerUrl,
    };
