import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_messenger/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays correctly and accepts input', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify initial state
    expect(find.byKey(const ValueKey('username_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('password_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('login_button')), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byKey(const ValueKey('username_input')), 'testuser');
    await tester.enterText(find.byKey(const ValueKey('password_input')), 'password123');
    
    // We can't fully tap the login button without mocking auth provider in the test, 
    // but we can verify inputs hold the correct value.
    expect(find.text('testuser'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });
}
