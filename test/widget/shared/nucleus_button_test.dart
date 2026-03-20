import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nucleus/shared/widgets/nucleus_button.dart';
import 'package:nucleus/core/theme/app_theme.dart';

void main() {
  Widget buildButton({VoidCallback? onPressed, bool isLoading = false}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: NucleusButton(
          label: 'Test Button',
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }

  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(buildButton(onPressed: () {}));
    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(buildButton(onPressed: () => tapped = true));
    await tester.tap(find.text('Test Button'));
    expect(tapped, isTrue);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(buildButton());
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows loading indicator when isLoading is true', (tester) async {
    await tester.pumpWidget(buildButton(onPressed: () {}, isLoading: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Test Button'), findsNothing);
  });
}
