import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_screen.dart';
import 'sign_up_screen.dart';
import 'password_reset_screen.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/curved_header_clipper.dart';
import '../widgets/custom_snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      _performSignIn();
    }
  }

  void _navigateToPasswordReset() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
    );
  }

  Future<void> _performSignIn() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Create/update user document
      await FirestoreService.instance.createUserDoc(credential.user!.uid, {
        'email': credential.user!.email,
        'displayName': credential.user!.displayName ?? '',
        'lastSignIn': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackBar.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _performGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final credential = await AuthService.signInWithGoogle();

      if (credential == null) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Google sign up cancelled or failed',
            type: SnackBarType.error,
          );
        }
        return;
      }

      // Create/update user document
      await FirestoreService.instance.createUserDoc(credential.user!.uid, {
        'email': credential.user!.email,
        'displayName': credential.user!.displayName ?? '',
        'lastSignIn': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: e.toString(),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                        // Sign In Title
                        const Text(
                          'Sign In',
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
                              placeholder: 'Email Address',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
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
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 8),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _navigateToPasswordReset,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppConstants.primaryPurple,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppConstants.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Sign In Button
                        CustomButton(
                          text: 'Sign In',
                          onPressed: _isLoading ? null : _signIn,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 12),

                        // Google Sign-In
                        CustomButton(
                          text: 'Sign in with Google',
                          onPressed: _isLoading ? null : _performGoogleSignIn,
                          backgroundColor: Colors.white,
                          textColor: AppConstants.textDark,
                          icon: Icons.login,
                        ),

                        // Sign Up Link
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: AppConstants.textDark,
                                fontSize: 16,
                                fontFamily: AppConstants.fontFamily,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
