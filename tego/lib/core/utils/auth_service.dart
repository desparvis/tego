import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  /// Signs in with Google and returns the [UserCredential] on success,
  /// or null when the user cancels or on failure.
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return await FirebaseAuth.instance.signInWithPopup(provider);
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        // Log cancellation for debugging
        // ignore: avoid_print
        print('GoogleSignIn: user cancelled (googleUser == null)');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('GoogleSignIn: FirebaseAuthException during sign-in: $e');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('GoogleSignIn: unexpected error during sign-in: $e');
      return null;
    }
  }
}
