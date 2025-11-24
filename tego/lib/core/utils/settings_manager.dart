import 'preferences_service.dart';

/// Settings manager for handling app preferences with validation
class SettingsManager {
  // Theme options
  static const List<String> themeOptions = ['system', 'light', 'dark'];
  
  // Language options
  static const List<String> languageOptions = ['en', 'rw'];
  
  // Currency options
  static const List<String> currencyOptions = ['RWF', 'USD', 'EUR'];
  
  // Sales view options
  static const List<String> salesViewOptions = ['list', 'grid'];

  /// Initialize all settings with default values
  static Future<void> initializeSettings() async {
    // Set defaults if not already set
    if (PreferencesService.isFirstLaunch()) {
      await PreferencesService.setThemeMode('system');
      await PreferencesService.setLanguage('en');
      await PreferencesService.setCurrency('RWF');
      await PreferencesService.setNotificationsEnabled(true);
      await PreferencesService.setAutoBackupEnabled(false);
      await PreferencesService.setBiometricEnabled(false);
      await PreferencesService.setDefaultSalesView('list');
      await PreferencesService.setFirstLaunchComplete();
    }
  }

  /// Get all current settings as a map
  static Map<String, dynamic> getAllSettings() {
    return {
      'theme': PreferencesService.getThemeMode(),
      'language': PreferencesService.getLanguage(),
      'currency': PreferencesService.getCurrency(),
      'notifications': PreferencesService.getNotificationsEnabled(),
      'autoBackup': PreferencesService.getAutoBackupEnabled(),
      'biometric': PreferencesService.getBiometricEnabled(),
      'salesView': PreferencesService.getDefaultSalesView(),
    };
  }

  /// Validate and set theme preference
  static Future<bool> setTheme(String theme) async {
    if (themeOptions.contains(theme)) {
      await PreferencesService.setThemeMode(theme);
      return true;
    }
    return false;
  }

  /// Validate and set language preference
  static Future<bool> setLanguage(String language) async {
    if (languageOptions.contains(language)) {
      await PreferencesService.setLanguage(language);
      return true;
    }
    return false;
  }

  /// Validate and set currency preference
  static Future<bool> setCurrency(String currency) async {
    if (currencyOptions.contains(currency)) {
      await PreferencesService.setCurrency(currency);
      return true;
    }
    return false;
  }

  /// Reset all settings to defaults
  static Future<void> resetToDefaults() async {
    await PreferencesService.setThemeMode('system');
    await PreferencesService.setLanguage('en');
    await PreferencesService.setCurrency('RWF');
    await PreferencesService.setNotificationsEnabled(true);
    await PreferencesService.setAutoBackupEnabled(false);
    await PreferencesService.setBiometricEnabled(false);
    await PreferencesService.setDefaultSalesView('list');
  }
}