import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Log an event to the analytics system.
  /// Currently, this just prints to the console in debug mode.
  void trackEvent(String name, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('📊 [Analytics] Event: $name, Params: $parameters');
    }
    
    // Future: Integrate with Firebase Analytics or Mixpanel
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  void trackLoginAttempt(String email) {
    trackEvent('login_attempt', parameters: {'email': email});
  }

  void trackLoginSuccess() {
    trackEvent('login_success');
  }

  void trackLoginFailure(String reason) {
    trackEvent('login_failure', parameters: {'reason': reason});
  }

  void trackPasswordResetSent() {
    trackEvent('password_reset_sent');
  }
}
