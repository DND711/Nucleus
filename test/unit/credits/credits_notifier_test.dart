import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nucleus/features/credits/providers/credits_provider.dart';

void main() {
  group('CreditsNotifier', () {
    test('deduct reduces balance correctly', () async {
      final container = ProviderContainer(
        overrides: [
          creditsNotifierProvider.overrideWith(() {
            return _MockCreditsNotifier(initialBalance: 50);
          }),
        ],
      );

      await container.read(creditsNotifierProvider.future);
      container.read(creditsNotifierProvider.notifier).deduct(5);

      final balance = container.read(creditsNotifierProvider).valueOrNull;
      expect(balance, equals(45));

      container.dispose();
    });

    test('deduct does not go below zero', () async {
      final container = ProviderContainer(
        overrides: [
          creditsNotifierProvider.overrideWith(() {
            return _MockCreditsNotifier(initialBalance: 3);
          }),
        ],
      );

      await container.read(creditsNotifierProvider.future);
      container.read(creditsNotifierProvider.notifier).deduct(10);

      final balance = container.read(creditsNotifierProvider).valueOrNull;
      expect(balance, equals(0));

      container.dispose();
    });
  });
}

class _MockCreditsNotifier extends CreditsNotifier {
  _MockCreditsNotifier({required this.initialBalance});
  final int initialBalance;

  @override
  Future<int> build() async => initialBalance;
}
