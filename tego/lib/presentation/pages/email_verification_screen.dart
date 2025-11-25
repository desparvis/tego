import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../../core/utils/screen_utils.dart';
import 'landing_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        timer.cancel();
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Email verified successfully!',
            type: SnackBarType.success,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingScreen()),
          );
        }
      }
    });
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email sent to: ${user.email}');
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        CustomSnackBar.show(
          context,
          message: 'Verification email sent to ${user.email}. Check spam folder if not received.',
          type: SnackBarType.success,
        );
        _startCooldown();
      }
    } catch (e) {
      print('Email verification error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      CustomSnackBar.show(
        context,
        message: 'Failed to send email: $e',
        type: SnackBarType.error,
      );
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0 || !mounted) {
        timer.cancel();
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundWhite,
      body: Padding(
        padding: EdgeInsets.all(ScreenUtils.w(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread,
              size: ScreenUtils.w(100),
              color: AppConstants.primaryPurple,
            ),
            SizedBox(height: ScreenUtils.h(24)),
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: ScreenUtils.sp(24),
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: ScreenUtils.h(16)),
            Text(
              'We\'ve sent a verification email to:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenUtils.sp(16),
                color: Colors.grey[600],
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: ScreenUtils.h(8)),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenUtils.sp(16),
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryPurple,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: ScreenUtils.h(24)),
            Text(
              'Please check your email and click the verification link to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenUtils.sp(14),
                color: Colors.grey[600],
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: ScreenUtils.h(32)),
            CustomButton(
              text: _resendCooldown > 0 
                  ? 'Resend in ${_resendCooldown}s'
                  : 'Resend Verification Email',
              onPressed: _resendCooldown > 0 || _isLoading ? null : _resendVerification,
              isLoading: _isLoading,
            ),
            SizedBox(height: ScreenUtils.h(16)),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Sign in with different account'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}