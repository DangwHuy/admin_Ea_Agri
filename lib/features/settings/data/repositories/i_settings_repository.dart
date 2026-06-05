import '../models/global_config.dart';
import '../models/business_config.dart';
import '../models/ai_config.dart';
import '../models/security_config.dart';
import '../models/feature_flags.dart';
import '../models/notification_config.dart';
import '../models/monitoring_config.dart';
import '../models/localization_config.dart';
import '../models/backup_config.dart';

abstract class ISettingsRepository {
  Future<GlobalConfig?> getGlobalConfig();
  Future<void> saveGlobalConfig(GlobalConfig config);

  Future<BusinessConfig?> getBusinessConfig();
  Future<void> saveBusinessConfig(BusinessConfig config);

  Future<AIConfig?> getAIConfig();
  Future<void> saveAIConfig(AIConfig config);

  Future<SecurityConfig?> getSecurityConfig();
  Future<void> saveSecurityConfig(SecurityConfig config);

  Future<FeatureFlags?> getFeatureFlags();
  Future<void> saveFeatureFlags(FeatureFlags flags);

  Future<NotificationConfig?> getNotificationConfig();
  Future<void> saveNotificationConfig(NotificationConfig config);

  Future<MonitoringConfig?> getMonitoringConfig();
  Future<void> saveMonitoringConfig(MonitoringConfig config);

  Future<LocalizationConfig?> getLocalizationConfig();
  Future<void> saveLocalizationConfig(LocalizationConfig config);

  Future<BackupConfig?> getBackupConfig();
  Future<void> saveBackupConfig(BackupConfig config);
}
