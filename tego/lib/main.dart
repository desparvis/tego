// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/bloc/expense_bloc.dart';
import 'core/utils/preferences_service.dart';
import 'core/utils/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using generated `firebase_options.dart`.
  // `flutterfire configure` created this file and added platform
  // configuration. Use `DefaultFirebaseOptions.currentPlatform` so the
  // correct options are provided on every platform.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Comment out emulator configuration for production Firebase
    // if (!kReleaseMode) {
    //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    //   FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // }

    // ignore: avoid_print
    print('Firebase initialized with DefaultFirebaseOptions');
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (context) => ExpenseBloc(),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
