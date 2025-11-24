import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns null for valid emails', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.uk'), null);
      expect(Validators.validateEmail('test123@gmail.com'), null);
    });

    test('validateEmail returns error for invalid emails', () {
      expect(Validators.validateEmail(''), 'Please enter your email');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email');
      expect(Validators.validateEmail('test@'), 'Please enter a valid email');
      expect(Validators.validateEmail('@domain.com'), 'Please enter a valid email');
    });

    test('validatePassword returns null for valid passwords', () {
      expect(Validators.validatePassword('password123'), null);
      expect(Validators.validatePassword('123456'), null);
      expect(Validators.validatePassword('verylongpassword'), null);
    });

    test('validatePassword returns error for invalid passwords', () {
      expect(Validators.validatePassword(''), 'Please enter your password');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('abc'), 'Password must be at least 6 characters');
    });

    test('validateAmount returns null for valid amounts', () {
      expect(Validators.validateAmount('100'), null);
      expect(Validators.validateAmount('1000.50'), null);
      expect(Validators.validateAmount('0.01'), null);
    });

    test('validateAmount returns error for invalid amounts', () {
      expect(Validators.validateAmount(''), 'Please enter an amount');
      expect(Validators.validateAmount('0'), 'Amount must be greater than 0');
      expect(Validators.validateAmount('-100'), 'Amount must be greater than 0');
      expect(Validators.validateAmount('abc'), 'Please enter a valid amount');
    });
  });
}