import 'package:flutter/material.dart';
import '../data/repositories/i_settings_repository.dart';
import '../data/models/global_config.dart';
import '../data/models/business_config.dart';
import '../data/models/ai_config.dart';
import '../data/models/security_config.dart';
import '../data/models/feature_flags.dart';
import '../data/models/notification_config.dart';
import '../data/models/monitoring_config.dart';
import '../data/models/localization_config.dart';
import '../data/models/backup_config.dart';

class SettingsProvider extends ChangeNotifier {
  final ISettingsRepository _repository;

  SettingsProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Configuration States (Original vs Edited) ---
  
  // Global
  GlobalConfig? _originalGlobal;
  GlobalConfig? _editedGlobal;
  GlobalConfig? get global => _editedGlobal;

  // Business
  BusinessConfig? _originalBusiness;
  BusinessConfig? _editedBusiness;
  BusinessConfig? get business => _editedBusiness;

  // AI
  AIConfig? _originalAI;
  AIConfig? _editedAI;
  AIConfig? get ai => _editedAI;

  // Security
  SecurityConfig? _originalSecurity;
  SecurityConfig? _editedSecurity;
  SecurityConfig? get security => _editedSecurity;

  // Feature Flags
  FeatureFlags? _originalFeatureFlags;
  FeatureFlags? _editedFeatureFlags;
  FeatureFlags? get featureFlags => _editedFeatureFlags;

  // Notification
  NotificationConfig? _originalNotification;
  NotificationConfig? _editedNotification;
  NotificationConfig? get notification => _editedNotification;

  // Localization
  LocalizationConfig? _originalLocalization;
  LocalizationConfig? _editedLocalization;
  LocalizationConfig? get localization => _editedLocalization;

  // Monitoring
  MonitoringConfig? _originalMonitoring;
  MonitoringConfig? _editedMonitoring;
  MonitoringConfig? get monitoring => _editedMonitoring;

  // Backup
  BackupConfig? _originalBackup;
  BackupConfig? _editedBackup;
  BackupConfig? get backup => _editedBackup;

  // --- Dirty State Detection ---
  
  bool get isGlobalDirty => _originalGlobal != _editedGlobal;
  bool get isBusinessDirty => _originalBusiness != _editedBusiness;
  bool get isAIDirty => _originalAI != _editedAI;
  bool get isSecurityDirty => _originalSecurity != _editedSecurity;
  bool get isFeatureFlagsDirty => _originalFeatureFlags != _editedFeatureFlags;
  bool get isNotificationDirty => _originalNotification != _editedNotification;
  bool get isLocalizationDirty => _originalLocalization != _editedLocalization;
  bool get isMonitoringDirty => _originalMonitoring != _editedMonitoring;
  bool get isBackupDirty => _originalBackup != _editedBackup;

  bool get isAnyDirty => 
      isGlobalDirty || isBusinessDirty || isAIDirty || isSecurityDirty || 
      isFeatureFlagsDirty || isNotificationDirty || isLocalizationDirty || 
      isMonitoringDirty || isBackupDirty;

  // --- Actions ---

  Future<void> loadAllSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getGlobalConfig(),
        _repository.getBusinessConfig(),
        _repository.getAIConfig(),
        _repository.getSecurityConfig(),
        _repository.getFeatureFlags(),
        _repository.getNotificationConfig(),
        _repository.getLocalizationConfig(),
        _repository.getMonitoringConfig(),
        _repository.getBackupConfig(),
      ]);

      _originalGlobal = _editedGlobal = results[0] as GlobalConfig? ?? const GlobalConfig();
      _originalBusiness = _editedBusiness = results[1] as BusinessConfig? ?? const BusinessConfig();
      _originalAI = _editedAI = results[2] as AIConfig? ?? const AIConfig();
      _originalSecurity = _editedSecurity = results[3] as SecurityConfig? ?? const SecurityConfig();
      _originalFeatureFlags = _editedFeatureFlags = results[4] as FeatureFlags? ?? const FeatureFlags();
      _originalNotification = _editedNotification = results[5] as NotificationConfig? ?? const NotificationConfig();
      _originalLocalization = _editedLocalization = results[6] as LocalizationConfig? ?? const LocalizationConfig();
      _originalMonitoring = _editedMonitoring = results[7] as MonitoringConfig? ?? const MonitoringConfig();
      _originalBackup = _editedBackup = results[8] as BackupConfig? ?? const BackupConfig();

    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Individual Update Methods (Synchronous, for UI forms)
  
  void updateGlobal(GlobalConfig config) {
    _editedGlobal = config;
    notifyListeners();
  }

  void updateBusiness(BusinessConfig config) {
    _editedBusiness = config;
    notifyListeners();
  }

  void updateAI(AIConfig config) {
    _editedAI = config;
    notifyListeners();
  }

  void updateSecurity(SecurityConfig config) {
    _editedSecurity = config;
    notifyListeners();
  }

  void updateFeatureFlags(FeatureFlags flags) {
    _editedFeatureFlags = flags;
    notifyListeners();
  }

  void updateNotification(NotificationConfig config) {
    _editedNotification = config;
    notifyListeners();
  }

  void updateLocalization(LocalizationConfig config) {
    _editedLocalization = config;
    notifyListeners();
  }

  void updateMonitoring(MonitoringConfig config) {
    _editedMonitoring = config;
    notifyListeners();
  }

  void updateBackup(BackupConfig config) {
    _editedBackup = config;
    notifyListeners();
  }

  // --- Save Actions ---

  Future<bool> saveGlobal() async {
    if (!isGlobalDirty || _editedGlobal == null) return true;
    return _performSave(() => _repository.saveGlobalConfig(_editedGlobal!), () {
      _originalGlobal = _editedGlobal;
    });
  }

  Future<bool> saveBusiness() async {
    if (!isBusinessDirty || _editedBusiness == null) return true;
    return _performSave(() => _repository.saveBusinessConfig(_editedBusiness!), () {
      _originalBusiness = _editedBusiness;
    });
  }

  Future<bool> saveAI() async {
    if (!isAIDirty || _editedAI == null) return true;
    return _performSave(() => _repository.saveAIConfig(_editedAI!), () {
      _originalAI = _editedAI;
    });
  }

  Future<bool> saveSecurity() async {
    if (!isSecurityDirty || _editedSecurity == null) return true;
    return _performSave(() => _repository.saveSecurityConfig(_editedSecurity!), () {
      _originalSecurity = _editedSecurity;
    });
  }

  Future<bool> saveFeatureFlags() async {
    if (!isFeatureFlagsDirty || _editedFeatureFlags == null) return true;
    return _performSave(() => _repository.saveFeatureFlags(_editedFeatureFlags!), () {
      _originalFeatureFlags = _editedFeatureFlags;
    });
  }

  Future<bool> saveNotification() async {
    if (!isNotificationDirty || _editedNotification == null) return true;
    return _performSave(() => _repository.saveNotificationConfig(_editedNotification!), () {
      _originalNotification = _editedNotification;
    });
  }

  Future<bool> saveMonitoring() async {
    if (!isMonitoringDirty || _editedMonitoring == null) return true;
    return _performSave(() => _repository.saveMonitoringConfig(_editedMonitoring!), () {
      _originalMonitoring = _editedMonitoring;
    });
  }

  Future<bool> saveLocalization() async {
    if (!isLocalizationDirty || _editedLocalization == null) return true;
    return _performSave(() => _repository.saveLocalizationConfig(_editedLocalization!), () {
      _originalLocalization = _editedLocalization;
    });
  }

  Future<bool> saveBackup() async {
    if (!isBackupDirty || _editedBackup == null) return true;
    return _performSave(() => _repository.saveBackupConfig(_editedBackup!), () {
      _originalBackup = _editedBackup;
    });
  }

  /// Special action: Trigger system-wide force logout
  Future<bool> triggerGlobalForceLogout() async {
    if (_editedSecurity == null) return false;
    
    // Set timestamp to now (for the UI state)
    final now = DateTime.now();
    updateSecurity(_editedSecurity!.copyWith(globalForceLogoutTimestamp: now));
    
    // Save immediately to Firestore
    return await saveSecurity();
  }
  
  // Helper for boiler-plate save logic
  Future<bool> _performSave(Future<void> Function() saveCall, VoidCallback onSuccess) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await saveCall();
      onSuccess();
      return true;
    } catch (e) {
      _errorMessage = 'Save failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset method
  void discardChanges() {
    _editedGlobal = _originalGlobal;
    _editedBusiness = _originalBusiness;
    _editedAI = _originalAI;
    _editedSecurity = _originalSecurity;
    _editedFeatureFlags = _originalFeatureFlags;
    _editedNotification = _originalNotification;
    _editedLocalization = _originalLocalization;
    _editedMonitoring = _originalMonitoring;
    _editedBackup = _originalBackup;
    notifyListeners();
  }
}
