import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_messenger/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('App launches, shows login screen, and navigates to register', (tester) async {
      // Load app widget.
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Verify the login screen is presented initially
      expect(find.byKey(const ValueKey('username_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('password_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('login_button')), findsOneWidget);

      // Navigate to the register screen
      final registerLink = find.byKey(const ValueKey('register_link'));
      await tester.tap(registerLink);

      // Trigger a frame and wait for animations to complete.
      await tester.pumpAndSettle();

      // Verify the Register screen is displayed
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
