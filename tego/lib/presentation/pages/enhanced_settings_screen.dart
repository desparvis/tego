import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/theme_notifier.dart';
import '../../core/utils/screen_utils.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/custom_snackbar.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'RWF';
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  bool _biometricEnabled = false;
  String _defaultSalesView = 'List';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      final theme = PreferencesService.getThemeMode();
      _selectedTheme = theme == 'dark' ? 'Dark' : theme == 'light' ? 'Light' : 'System';
      _selectedLanguage = PreferencesService.getLanguage() == 'en' ? 'English' : 'Kinyarwanda';
      _selectedCurrency = PreferencesService.getCurrency();
      _notificationsEnabled = PreferencesService.getNotificationsEnabled();
      _autoBackupEnabled = PreferencesService.getAutoBackupEnabled();
      _biometricEnabled = PreferencesService.getBiometricEnabled();
      _defaultSalesView = PreferencesService.getDefaultSalesView() == 'list' ? 'List' : 'Grid';
    });
  }

  void _saveTheme(String theme) async {
    String themeMode;
    switch (theme) {
      case 'Dark':
        themeMode = 'dark';
        break;
      case 'Light':
        themeMode = 'light';
        break;
      default:
        themeMode = 'system';
    }
    await PreferencesService.setThemeMode(themeMode);
    ThemeNotifier().notifyThemeChanged();
    setState(() => _selectedTheme = theme);
    _showSuccessMessage('Theme updated to $theme');
  }

  void _saveLanguage(String language) async {
    final langCode = language == 'English' ? 'en' : 'rw';
    await PreferencesService.setLanguage(langCode);
    setState(() => _selectedLanguage = language);
    _showSuccessMessage('Language changed to $language');
  }

  void _saveCurrency(String currency) async {
    await PreferencesService.setCurrency(currency);
    setState(() => _selectedCurrency = currency);
    _showSuccessMessage('Currency set to $currency');
  }

  void _saveNotifications(bool enabled) async {
    await PreferencesService.setNotificationsEnabled(enabled);
    setState(() => _notificationsEnabled = enabled);
    _showSuccessMessage('Notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  void _saveAutoBackup(bool enabled) async {
    await PreferencesService.setAutoBackupEnabled(enabled);
    setState(() => _autoBackupEnabled = enabled);
    _showSuccessMessage('Auto-backup ${enabled ? 'enabled' : 'disabled'}');
  }

  void _saveBiometric(bool enabled) async {
    await PreferencesService.setBiometricEnabled(enabled);
    setState(() => _biometricEnabled = enabled);
    _showSuccessMessage('Biometric auth ${enabled ? 'enabled' : 'disabled'}');
  }

  void _saveSalesView(String view) async {
    final viewMode = view == 'List' ? 'list' : 'grid';
    await PreferencesService.setDefaultSalesView(viewMode);
    setState(() => _defaultSalesView = view);
    _showSuccessMessage('Default view set to $view');
  }

  void _showSuccessMessage(String message) {
    CustomSnackBar.show(
      context,
      message: message,
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtils.w(20)),
              child: Column(
                children: [
                  _buildSettingsCard('Appearance', [
                    _buildDropdownSetting(
                      'Theme',
                      _selectedTheme,
                      ['System', 'Light', 'Dark'],
                      Icons.palette,
                      _saveTheme,
                    ),
                    _buildDropdownSetting(
                      'Language',
                      _selectedLanguage,
                      ['English', 'Kinyarwanda'],
                      Icons.language,
                      _saveLanguage,
                    ),
                  ]),
                  SizedBox(height: ScreenUtils.h(16)),
                  _buildSettingsCard('Financial', [
                    _buildDropdownSetting(
                      'Currency',
                      _selectedCurrency,
                      ['RWF', 'USD', 'EUR'],
                      Icons.attach_money,
                      _saveCurrency,
                    ),
                    _buildDropdownSetting(
                      'Sales View',
                      _defaultSalesView,
                      ['List', 'Grid'],
                      Icons.view_list,
                      _saveSalesView,
                    ),
                  ]),
                  SizedBox(height: ScreenUtils.h(16)),
                  _buildSettingsCard('Security & Privacy', [
                    _buildSwitchSetting(
                      'Notifications',
                      _notificationsEnabled,
                      Icons.notifications,
                      _saveNotifications,
                    ),
                    _buildSwitchSetting(
                      'Auto Backup',
                      _autoBackupEnabled,
                      Icons.backup,
                      _saveAutoBackup,
                    ),
                    _buildSwitchSetting(
                      'Biometric Auth',
                      _biometricEnabled,
                      Icons.fingerprint,
                      _saveBiometric,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppConstants.primaryPurple,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(20),
            vertical: ScreenUtils.h(16),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.w(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: ScreenUtils.w(18),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtils.w(16)),
              Text(
                'Settings & Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtils.sp(20),
                  fontWeight: FontWeight.w600,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ScreenUtils.w(16)),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtils.sp(18),
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryPurple,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<String> options,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(16),
        vertical: ScreenUtils.h(8),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtils.w(40),
            height: ScreenUtils.w(40),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryPurple,
              size: ScreenUtils.w(20),
            ),
          ),
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtils.sp(16),
                fontWeight: FontWeight.w500,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: (newValue) => onChanged(newValue!),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(16),
        vertical: ScreenUtils.h(8),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtils.w(40),
            height: ScreenUtils.w(40),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryPurple,
              size: ScreenUtils.w(20),
            ),
          ),
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ScreenUtils.sp(16),
                fontWeight: FontWeight.w500,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryPurple,
          ),
        ],
      ),
    );
  }
}