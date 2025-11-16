// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/pages/splash_screen.dart';
import 'core/utils/preferences_service.dart';
import 'core/utils/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (if configured). On web, you should run
  // `flutterfire configure` to generate `firebase_options.dart` and
  // platform-specific configuration files (google-services.json /
  // GoogleService-Info.plist). If initialization fails the error
  // will be printed but app will continue to run.
  try {
    await Firebase.initializeApp();
    // ignore: avoid_print
    print('Firebase initialized');
  } catch (e, st) {
    // ignore: avoid_print
    print('Firebase initialization failed: $e\n$st');
  }

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
