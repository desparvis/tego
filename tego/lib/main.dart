// lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tego App',
      theme: ThemeData(primaryColor: const Color(0xFF7430EB)),
      home: const SplashScreen(),  // Start with splash screen
    );
  }
}