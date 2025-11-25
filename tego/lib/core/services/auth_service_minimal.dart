import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
  
  static Future<void> reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }
  
  static Future<void> resendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }
}