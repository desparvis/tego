import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/sign_in_screen.dart';
import '../pages/landing_screen.dart';
import '../pages/email_verification_screen.dart';

/// Auth wrapper that maintains authentication state after app restart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          // Check if email is verified
          if (snapshot.data!.emailVerified) {
            return const LandingScreen();
          } else {
            return const EmailVerificationScreen();
          }
        }

        // User is not signed in
        return const SignInScreen();
      },
    );
  }
}