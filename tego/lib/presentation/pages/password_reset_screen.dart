import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_snackbar.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/screen_utils.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      CustomSnackBar.show(
        context,
        message: 'Password reset email sent! Check your inbox.',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    return Scaffold(
      backgroundColor: AppConstants.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryPurple,
        foregroundColor: Colors.white,
        title: const Text('Reset Password'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtils.w(20)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset,
                size: ScreenUtils.w(80),
                color: AppConstants.primaryPurple,
              ),
              SizedBox(height: ScreenUtils.h(24)),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: ScreenUtils.sp(24),
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: ScreenUtils.h(12)),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtils.sp(16),
                  color: Colors.grey[600],
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
              SizedBox(height: ScreenUtils.h(32)),
              CustomTextField(
                placeholder: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              SizedBox(height: ScreenUtils.h(24)),
              CustomButton(
                text: 'Send Reset Link',
                onPressed: _isLoading ? null : _resetPassword,
                isLoading: _isLoading,
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
    super.dispose();
  }
}