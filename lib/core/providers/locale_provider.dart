import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localePrefKey = 'language_preference';

  Locale _locale = const Locale('vi');
  late SharedPreferences _prefs;

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final languageCode = _prefs.getString(_localePrefKey) ?? 'vi';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_localePrefKey, locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'vi') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('vi'));
    }
  }
}
