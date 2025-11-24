import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive preferences service with 5+ settings
class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 1. Theme preference (Light/Dark/System)
  static String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  // 2. Language preference (English/Kinyarwanda)
  static String getLanguage() {
    return _prefs?.getString('language') ?? 'en';
  }

  static Future<void> setLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  // 3. Currency preference (RWF/USD/EUR)
  static String getCurrency() {
    return _prefs?.getString('currency') ?? 'RWF';
  }

  static Future<void> setCurrency(String currency) async {
    await _prefs?.setString('currency', currency);
  }

  // 4. Notification preferences
  static bool getNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
  }

  // 5. Auto-backup preference
  static bool getAutoBackupEnabled() {
    return _prefs?.getBool('auto_backup_enabled') ?? false;
  }

  static Future<void> setAutoBackupEnabled(bool enabled) async {
    await _prefs?.setBool('auto_backup_enabled', enabled);
  }

  // 6. Biometric authentication preference
  static bool getBiometricEnabled() {
    return _prefs?.getBool('biometric_enabled') ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs?.setBool('biometric_enabled', enabled);
  }

  // 7. Default sales view (List/Grid)
  static String getDefaultSalesView() {
    return _prefs?.getString('default_sales_view') ?? 'list';
  }

  static Future<void> setDefaultSalesView(String view) async {
    await _prefs?.setString('default_sales_view', view);
  }

  // Username preference
  static String getUsername() {
    return _prefs?.getString('username') ?? 'User';
  }

  static Future<void> setUsername(String username) async {
    await _prefs?.setString('username', username);
  }

  // First launch check
  static bool isFirstLaunch() {
    return _prefs?.getBool('first_launch') ?? true;
  }

  static Future<void> setFirstLaunchComplete() async {
    await _prefs?.setBool('first_launch', false);
  }
}