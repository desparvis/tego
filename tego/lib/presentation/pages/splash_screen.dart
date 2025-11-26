import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/splash.jpg',
            fit: BoxFit.cover,
          ),
          // Overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // App Name - Tego
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Dancing Script',
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const Spacer(),
                
                // Get Started Button
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: CustomButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}