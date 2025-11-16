import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_in_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/theme_notifier.dart';
import '../widgets/bottom_navigation_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3; // Settings tab is selected
  String _username = 'Username';
  String _themeMode = 'light';
  String _language = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _username = PreferencesService.getUsername();
      _themeMode = PreferencesService.getThemeMode();
      _language = PreferencesService.getLanguage();
      _notificationsEnabled = PreferencesService.getNotificationsEnabled();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: AppConstants.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontFamily: AppConstants.fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppConstants.primaryPurple,
                  fontFamily: AppConstants.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundGray,
        body: Column(
          children: [
            // Custom Header
            _buildHeader(),

            // Main Content (scrollable)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Settings Title in Purple Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryPurple,
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardRadius,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Settings Options
                      _buildSettingsOption(
                        icon: Icons.person,
                        title: 'Username: $_username',
                        onTap: _editUsername,
                      ),

                      const SizedBox(height: 16),

                      _buildSettingsOption(
                        icon: Icons.palette,
                        title: 'Theme: $_themeMode',
                        onTap: _changeTheme,
                      ),

                      const SizedBox(height: 16),

                      _buildSettingsOption(
                        icon: Icons.language,
                        title: 'Language: $_language',
                        onTap: _changeLanguage,
                      ),

                      const SizedBox(height: 16),

                      _buildToggleOption(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),

                      const SizedBox(height: 16),

                      _buildSettingsOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: _logout,
                        isLogout: true,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Bottom Navigation
        bottomNavigationBar: const BottomNavigationWidget(currentIndex: 3),
      ),
    );
  }

  // Custom Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppConstants.primaryPurple,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              Row(
                children: [
                  Text(
                    _username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editUsername() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _username);
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await PreferencesService.setUsername(controller.text);
                setState(() {
                  _username = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _changeTheme() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Light'),
                onTap: () async {
                  await PreferencesService.setThemeMode('light');
                  setState(() {
                    _themeMode = 'light';
                  });
                  ThemeNotifier().notifyThemeChanged();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dark'),
                onTap: () async {
                  await PreferencesService.setThemeMode('dark');
                  setState(() {
                    _themeMode = 'dark';
                  });
                  ThemeNotifier().notifyThemeChanged();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  await PreferencesService.setLanguage('English');
                  setState(() {
                    _language = 'English';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Kinyarwanda'),
                onTap: () async {
                  await PreferencesService.setLanguage('Kinyarwanda');
                  setState(() {
                    _language = 'Kinyarwanda';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleNotifications(bool value) async {
    await PreferencesService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  // Settings Option Row
  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLogout
                    ? Colors.red.withOpacity(0.1)
                    : AppConstants.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red : AppConstants.primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red : AppConstants.textDark,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // Toggle Option Widget
  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.textDark,
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
