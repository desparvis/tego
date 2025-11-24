import 'package:flutter_test/flutter_test.dart';
import 'package:tego/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.uk'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid-email'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), 'Email is required');
        expect(Validators.validateEmail(null), 'Email is required');
      });
    });

    group('Password Validation', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('Password123'), null);
        expect(Validators.validatePassword('MyPass1'), null);
      });

      test('should return error for weak password', () {
        expect(Validators.validatePassword('weak'), isNotNull);
        expect(Validators.validatePassword('password'), isNotNull);
        expect(Validators.validatePassword('PASSWORD'), isNotNull);
        expect(Validators.validatePassword('12345'), isNotNull);
      });
    });

    group('Amount Validation', () {
      test('should return null for valid amount', () {
        expect(Validators.validateAmount('100'), null);
        expect(Validators.validateAmount('1,000'), null);
        expect(Validators.validateAmount('50.5'), null);
      });

      test('should return error for invalid amount', () {
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('-10'), isNotNull);
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount(''), isNotNull);
      });
    });
  });
}