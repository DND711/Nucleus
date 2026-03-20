import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nucleus/core/theme/app_theme.dart';
import 'package:nucleus/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:nucleus/features/auth/providers/auth_provider.dart';

void main() {
  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const PhoneInputScreen(),
      ),
    );
  }

  testWidgets('renders phone input screen', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Nucleus'), findsOneWidget);
    expect(find.text('Enter your phone number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  testWidgets('send OTP button is disabled when phone is empty', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Send OTP'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('send OTP button enables when 10+ digits entered', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '9876543210');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Send OTP'),
    );
    expect(button.onPressed, isNotNull);
  });
}
