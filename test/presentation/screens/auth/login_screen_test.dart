import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seven_ftrends_mvp/app/app_router.dart';
import 'package:seven_ftrends_mvp/data/services/local_session_service.dart';
import 'package:seven_ftrends_mvp/data/services/mock_auth_service.dart';
import 'package:seven_ftrends_mvp/presentation/providers/auth_provider.dart';
import 'package:seven_ftrends_mvp/presentation/screens/auth/login_screen.dart';

void main() {
  // Set up a mock for SharedPreferences
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // A helper function to wrap widgets in a MaterialApp with providers
  Widget createLoginScreen() {
    final mockAuthService = MockAuthService();
    final localSessionService = LocalSessionService();
    final authProvider = AuthProvider(mockAuthService, localSessionService);
    final appRouter = AppRouter(authProvider);

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
      child: MaterialApp.router(routerConfig: appRouter.router),
    );
  }

  testWidgets('LoginScreen validation: empty fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLoginScreen());

    // Find the login button and tap it without entering any text
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Rebuild the widget after the tap

    // Check for validation error messages
    expect(find.text('Please enter an email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
  });

  testWidgets('LoginScreen validation: invalid email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLoginScreen());

    // Enter an invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter a valid email.'), findsOneWidget);
  });

  testWidgets('LoginScreen validation: short password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLoginScreen());

    // Enter a short password
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      find.text('Password must be at least 6 characters long.'),
      findsOneWidget,
    );
  });

  testWidgets('LoginScreen success: navigates to home', (
    WidgetTester tester,
  ) async {
    // Use a real auth provider that can be manipulated
    final mockAuthService = MockAuthService();
    final localSessionService = LocalSessionService();
    final authProvider = AuthProvider(mockAuthService, localSessionService);
    final appRouter = AppRouter(authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: authProvider)],
        child: MaterialApp.router(routerConfig: appRouter.router),
      ),
    );

    // Pre-register a user to simulate a successful login
    await mockAuthService.signup('test@example.com', 'password123');
    authProvider.logout(); // Ensure we are logged out before testing login
    await tester.pump(); // Let the UI update after logout

    // Enter valid credentials
    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap the login button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(); // Wait for animations and navigation

    // After successful login, the router should redirect to the home screen
    // We can check for a widget that is unique to the HomeScaffold
    expect(find.text('Home Tab'), findsOneWidget);
  });
}
