// lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/pages/splash_screen.dart';
import 'core/utils/preferences_service.dart';
import 'core/utils/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    ThemeNotifier().setThemeChangeListener(_loadTheme);
  }

  void _loadTheme() {
    final savedTheme = PreferencesService.getThemeMode();
    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tego App',
      themeMode: _themeMode,
      theme: ThemeData(
        primaryColor: const Color(0xFF7B4EFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B4EFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF7B4EFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B4EFF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}