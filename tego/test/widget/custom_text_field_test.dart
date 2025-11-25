import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/presentation/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('renders text field with placeholder', (WidgetTester tester) async {
      // Arrange
      const placeholder = 'Enter text';
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: placeholder,
              controller: controller,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text(placeholder), findsOneWidget);
    });

    testWidgets('shows validation error when validator returns error', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const errorMessage = 'This field is required';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                placeholder: 'Test Field',
                controller: controller,
                validator: (value) => value?.isEmpty == true ? errorMessage : null,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Trigger validation
      final form = tester.widget<Form>(find.byType(Form));
      final formState = form.key as GlobalKey<FormState>;
      formState.currentState?.validate();
      await tester.pump();

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('obscures text when isPassword is true', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: 'Password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      // Act
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));

      // Assert
      expect(textField.obscureText, true);
    });

    testWidgets('updates controller when text is entered', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const testText = 'Hello World';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: 'Test Field',
              controller: controller,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), testText);
      await tester.pump();

      // Assert
      expect(controller.text, testText);
    });

    testWidgets('applies correct keyboard type', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholder: 'Email',
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      // Act
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));

      // Assert
      expect(textField.keyboardType, TextInputType.emailAddress);
    });
  });
}