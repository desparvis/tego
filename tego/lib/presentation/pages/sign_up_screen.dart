import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/auth_service.dart';
import 'sign_in_screen.dart';
import 'landing_screen.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/curved_header_clipper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      _performSignUp();
    }
  }

  Future<void> _performSignUp() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create or merge the user document in Firestore
      if (cred.user != null) {
        await FirestoreService.instance.createUserDoc(cred.user!.uid, {
          'email': cred.user!.email,
          'displayName': cred.user!.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // remove dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        final message = e.message ?? 'Sign up failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign up failed')));
      }
    }
  }

  Future<void> _performGoogleSignUp() async {
    // For Google, sign-in and sign-up are the same flow.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await AuthService.signInWithGoogle();
    if (!mounted) return;

    if (result != null && result.user != null) {
      // Ensure user doc exists (merge safe)
      await FirestoreService.instance.createUserDoc(result.user!.uid, {
        'email': result.user!.email,
        'displayName': result.user!.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // dismiss
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign up cancelled or failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppConstants.backgroundWhite,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Column(
            children: [
              // Purple Curved Header - Top Quarter
              ClipPath(
                clipper: CurvedHeaderClipper(),
                child: Container(
                  height: screenHeight * 0.3,
                  width: double.infinity,
                  color: AppConstants.primaryPurple,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Center(
                        child: Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontFamily: 'Dancing Script',
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Form Section - Expanded to fill remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Sign Up Title
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textDark,
                            fontFamily: AppConstants.fontFamily,
                          ),
                        ),

                        // Form Fields
                        Column(
                          children: [
                            // Email Field
                            CustomTextField(
                              placeholder: 'Email',
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            CustomTextField(
                              placeholder: 'Password',
                              isPassword: true,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        // Sign Up Button
                        CustomButton(text: 'Sign Up', onPressed: _signUp),

                        const SizedBox(height: 12),

                        // Google Sign-Up (same as sign in)
                        CustomButton(
                          text: 'Sign up with Google',
                          onPressed: _performGoogleSignUp,
                          backgroundColor: Colors.white,
                          textColor: AppConstants.textDark,
                        ),

                        // Sign In Link
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: AppConstants.textDark,
                                fontSize: 16,
                                fontFamily: AppConstants.fontFamily,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: AppConstants.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
