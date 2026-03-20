import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:nucleus/features/auth/domain/entities/auth_state.dart';
import 'package:nucleus/features/auth/domain/repositories/auth_repository.dart';
import 'package:nucleus/features/auth/providers/auth_provider.dart';

@GenerateMocks([AuthRepository])
import 'auth_notifier_test.mocks.dart';

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    test('initial state returns unauthenticated when no cached user', () async {
      when(mockRepo.getCurrentUser()).thenAnswer((_) async => null);

      final state = await container.read(authStateProvider.future);
      expect(state.isAuthenticated, isFalse);
    });

    test('initial state returns user when cached', () async {
      const mockUser = AuthUser(
        id: 'user123',
        phoneNumber: '+919876543210',
        isAuthenticated: true,
        onboardingComplete: true,
        vibeSetupComplete: true,
      );
      when(mockRepo.getCurrentUser()).thenAnswer((_) async => mockUser);

      final state = await container.read(authStateProvider.future);
      expect(state.isAuthenticated, isTrue);
      expect(state.id, equals('user123'));
    });

    test('verifyOtp updates state to authenticated', () async {
      when(mockRepo.getCurrentUser()).thenAnswer((_) async => null);

      const mockUser = AuthUser(
        id: 'user123',
        phoneNumber: '+919876543210',
        isAuthenticated: true,
        onboardingComplete: false,
        vibeSetupComplete: false,
      );
      when(mockRepo.verifyOtp(any, any)).thenAnswer((_) async => mockUser);

      // Wait for initial build
      await container.read(authStateProvider.future);

      await container.read(authStateProvider.notifier).verifyOtp('+919876543210', '123456');
      final state = container.read(authStateProvider).valueOrNull;

      expect(state?.isAuthenticated, isTrue);
    });

    test('logout resets state to unauthenticated', () async {
      const mockUser = AuthUser(
        id: 'user123',
        phoneNumber: '+919876543210',
        isAuthenticated: true,
        onboardingComplete: true,
        vibeSetupComplete: true,
      );
      when(mockRepo.getCurrentUser()).thenAnswer((_) async => mockUser);
      when(mockRepo.logout()).thenAnswer((_) async {});

      await container.read(authStateProvider.future);
      await container.read(authStateProvider.notifier).logout();

      final state = container.read(authStateProvider).valueOrNull;
      expect(state?.isAuthenticated, isFalse);
    });
  });
}
