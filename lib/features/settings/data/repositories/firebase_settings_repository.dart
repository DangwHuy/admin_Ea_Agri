import 'package:cloud_firestore/cloud_firestore.dart';
import 'i_settings_repository.dart';
import '../models/global_config.dart';
import '../models/business_config.dart';
import '../models/ai_config.dart';
import '../models/security_config.dart';
import '../models/feature_flags.dart';
import '../models/notification_config.dart';
import '../models/monitoring_config.dart';
import '../models/localization_config.dart';
import '../models/backup_config.dart';

class FirebaseSettingsRepository implements ISettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'system_settings';

  DocumentReference _doc(String id) => _firestore.collection(_collectionName).doc(id);

  @override
  Future<GlobalConfig?> getGlobalConfig() async {
    final snapshot = await _doc('global_config').get();
    if (!snapshot.exists) return null;
    return GlobalConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveGlobalConfig(GlobalConfig config) async {
    await _doc('global_config').set(config.toJson());
  }

  @override
  Future<BusinessConfig?> getBusinessConfig() async {
    final snapshot = await _doc('business_config').get();
    if (!snapshot.exists) return null;
    return BusinessConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveBusinessConfig(BusinessConfig config) async {
    await _doc('business_config').set(config.toJson());
  }

  @override
  Future<AIConfig?> getAIConfig() async {
    final snapshot = await _doc('ai_config').get();
    if (!snapshot.exists) return null;
    return AIConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveAIConfig(AIConfig config) async {
    await _doc('ai_config').set(config.toJson());
  }

  @override
  Future<SecurityConfig?> getSecurityConfig() async {
    final snapshot = await _doc('security_config').get();
    if (!snapshot.exists) return null;
    return SecurityConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveSecurityConfig(SecurityConfig config) async {
    await _doc('security_config').set(config.toJson());
  }

  @override
  Future<FeatureFlags?> getFeatureFlags() async {
    final snapshot = await _doc('feature_flags').get();
    if (!snapshot.exists) return null;
    return FeatureFlags.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveFeatureFlags(FeatureFlags flags) async {
    await _doc('feature_flags').set(flags.toJson());
  }

  @override
  Future<NotificationConfig?> getNotificationConfig() async {
    final snapshot = await _doc('notification_config').get();
    if (!snapshot.exists) return null;
    return NotificationConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveNotificationConfig(NotificationConfig config) async {
    await _doc('notification_config').set(config.toJson());
  }

  @override
  Future<MonitoringConfig?> getMonitoringConfig() async {
    final snapshot = await _doc('monitoring_config').get();
    if (!snapshot.exists) return null;
    return MonitoringConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveMonitoringConfig(MonitoringConfig config) async {
    await _doc('monitoring_config').set(config.toJson());
  }

  @override
  Future<LocalizationConfig?> getLocalizationConfig() async {
    final snapshot = await _doc('localization_config').get();
    if (!snapshot.exists) return null;
    return LocalizationConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveLocalizationConfig(LocalizationConfig config) async {
    await _doc('localization_config').set(config.toJson());
  }

  @override
  Future<BackupConfig?> getBackupConfig() async {
    final snapshot = await _doc('backup_config').get();
    if (!snapshot.exists) return null;
    return BackupConfig.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveBackupConfig(BackupConfig config) async {
    await _doc('backup_config').set(config.toJson());
  }
}
