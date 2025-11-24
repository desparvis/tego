// Test coverage runner for comprehensive testing
import 'package:flutter_test/flutter_test.dart';

// Unit Tests
import 'unit/auth_service_test.dart' as auth_service_test;
import 'unit/validators_test.dart' as validators_test;
import 'unit/sales_bloc_test.dart' as sales_bloc_test;

// Widget Tests
import 'widget/custom_button_test.dart' as custom_button_test;
import 'widget/custom_text_field_test.dart' as custom_text_field_test;
import 'widget/sign_in_screen_test.dart' as sign_in_screen_test;

void main() {
  group('Comprehensive Test Suite', () {
    group('Unit Tests', () {
      auth_service_test.main();
      validators_test.main();
      sales_bloc_test.main();
    });

    group('Widget Tests', () {
      custom_button_test.main();
      custom_text_field_test.main();
      sign_in_screen_test.main();
    });
  });
}