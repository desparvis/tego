import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _usernameKey = 'username';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Username preference
  static Future<void> setUsername(String username) async {
    await _prefs?.setString(_usernameKey, username);
  }

  static String getUsername() {
    return _prefs?.getString(_usernameKey) ?? 'Username';
  }

  // Theme preference
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_themeKey, themeMode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_themeKey) ?? 'light';
  }

  // Language preference
  static Future<void> setLanguage(String language) async {
    await _prefs?.setString(_languageKey, language);
  }

  static String getLanguage() {
    return _prefs?.getString(_languageKey) ?? 'English';
  }

  // Notifications preference
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsKey, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsKey) ?? true;
  }
}