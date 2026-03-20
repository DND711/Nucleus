import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/auth_state.dart';
import '../domain/repositories/auth_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in ProviderScope overrides');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dioClient: ref.watch(dioClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthUser>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthUser> {
  @override
  Future<AuthUser> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return await repo.getCurrentUser() ?? AuthUser.unauthenticated;
  }

  Future<void> sendOtp(String phoneNumber) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.sendOtp(phoneNumber);
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.verifyOtp(phoneNumber, otp);
    });
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.updateProfile(
        name: name,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );
    });
  }

  Future<void> saveVibe(String vibe) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.saveVibe(vibe);
    // Mark vibe complete locally
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(vibeSetupComplete: true));
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(AuthUser.unauthenticated);
  }
}
