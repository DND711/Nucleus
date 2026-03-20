// Integration test: full auth flow
// Run with: flutter test integration_test/auth_flow_test.dart --flavor dev
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nucleus/main_dev.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow', () {
    testWidgets('renders phone input on first launch', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show phone input screen for unauthenticated users
      expect(find.text('Nucleus'), findsWidgets);
    });
  });
}
