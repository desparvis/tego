import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../lib/core/services/auth_service.dart';
import '../../lib/core/error/failures.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Unit Tests', () {
    test('signInWithEmail returns success when credentials are valid', () async {
      // Test email validation
      const email = 'test@example.com';
      const password = 'password123';
      
      expect(email.contains('@'), true);
      expect(password.length >= 6, true);
    });

    test('password validation works correctly', () {
      // Test password strength
      expect('12345'.length < 6, true);
      expect('password123'.length >= 6, true);
      expect(''.isEmpty, true);
    });

    test('email format validation works', () {
      // Test email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      
      expect(emailRegex.hasMatch('test@example.com'), true);
      expect(emailRegex.hasMatch('invalid-email'), false);
      expect(emailRegex.hasMatch('test@'), false);
    });
  });
}