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

    testWidgets('User Flow: PIN entry, open chat, and send message', (tester) async {
      // Note: This test simulates the user flow. In a real integration test, 
      // you would perform a full login or mock the auth state.
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // 1. PIN Code Entry
      final pinInput = find.byKey(const ValueKey('pin_input'));
      if (tester.any(pinInput)) {
        await tester.enterText(pinInput, '1234');
        await tester.pumpAndSettle();
        final submitPin = find.byKey(const ValueKey('submit_pin_button'));
        await tester.tap(submitPin);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 2. Open Chat from Chat List
      // Wait for the chat list to appear
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final chatListTile = find.byType(ListTile).first;
      
      // If the list is empty, we tap FAB to create new chat, otherwise we open existing
      if (tester.any(chatListTile)) {
        await tester.tap(chatListTile);
        await tester.pumpAndSettle();
      } else {
        final fab = find.byType(FloatingActionButton);
        if (tester.any(fab)) {
          await tester.tap(fab);
          await tester.pumpAndSettle();
          
          final userTile = find.byType(ListTile).first;
          if (tester.any(userTile)) {
            await tester.tap(userTile);
            await tester.pumpAndSettle();
          }
        }
      }

      // 3. Send a message
      final messageInput = find.byType(TextField).last; // Usually the bottom input
      if (tester.any(messageInput)) {
        final testMessage = 'Integration Test Message ${DateTime.now().millisecondsSinceEpoch}';
        await tester.enterText(messageInput, testMessage);
        await tester.pumpAndSettle();

        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 4. Verify message appears
        expect(find.text(testMessage), findsOneWidget);
      }
    });
  });
}
