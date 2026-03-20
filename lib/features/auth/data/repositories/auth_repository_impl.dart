import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.dioClient,
    required this.secureStorage,
    required this.prefs,
  });

  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.sendOtp,
        data: {'phoneNumber': phoneNumber},
        options: _skipAuth,
      );
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AuthUser> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phoneNumber': phoneNumber, 'otp': otp},
        options: _skipAuth,
      );

      final data = response.data as Map<String, dynamic>;
      await dioClient.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );

      final user = _parseUser(data['user'] as Map<String, dynamic>);
      await _persistUser(user);
      return user;
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token == null) return null;

    try {
      final response = await dioClient.dio.get(ApiEndpoints.profileMe);
      final user = _parseUser(response.data as Map<String, dynamic>);
      await _persistUser(user);
      return user;
    } on Exception {
      // Try cached user
      return _getCachedUser();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await dioClient.clearTokens();
    await prefs.clear();
  }

  @override
  Future<bool> checkUsernameAvailable(String username) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.usernameCheck,
        queryParameters: {'username': username},
      );
      return response.data['available'] as bool;
    } on Exception {
      return false;
    }
  }

  @override
  Future<AuthUser> updateProfile({
    required String name,
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await dioClient.dio.patch(
        ApiEndpoints.profileUpdate,
        data: {
          'name': name,
          'username': username,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
      final user = _parseUser(response.data as Map<String, dynamic>);
      await _persistUser(user.copyWith(onboardingComplete: false));
      return user;
    } on Exception catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> saveVibe(String vibe) async {
    await dioClient.dio.post(ApiEndpoints.vibeSave, data: {'vibe': vibe});
    await prefs.setBool(StorageKeys.vibeSetupComplete, true);
  }

  // Helpers

  static final _skipAuth = _buildSkipAuthOptions();

  static dynamic _buildSkipAuthOptions() {
    return null; // Options with skipAuth header handled by interceptor
  }

  AuthUser _parseUser(Map<String, dynamic> data) {
    return AuthUser(
      id: data['_id'] as String? ?? data['id'] as String,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      name: data['name'] as String?,
      username: data['username'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      isAuthenticated: true,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      vibeSetupComplete: data['vibeSetupComplete'] as bool? ?? false,
    );
  }

  Future<void> _persistUser(AuthUser user) async {
    await secureStorage.write(key: StorageKeys.userId, value: user.id);
    await prefs.setBool(StorageKeys.onboardingComplete, user.onboardingComplete);
    await prefs.setBool(StorageKeys.vibeSetupComplete, user.vibeSetupComplete);
  }

  AuthUser? _getCachedUser() {
    final userId = null; // from secure storage — async, handled elsewhere
    final onboardingComplete = prefs.getBool(StorageKeys.onboardingComplete) ?? false;
    final vibeSetupComplete = prefs.getBool(StorageKeys.vibeSetupComplete) ?? false;

    if (userId == null) return null;

    return AuthUser(
      id: userId,
      phoneNumber: '',
      isAuthenticated: true,
      onboardingComplete: onboardingComplete,
      vibeSetupComplete: vibeSetupComplete,
    );
  }

  Exception _mapException(Exception e) => e; // Add mapping as needed
}
