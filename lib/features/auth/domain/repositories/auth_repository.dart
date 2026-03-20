import '../entities/auth_state.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<AuthUser> verifyOtp(String phoneNumber, String otp);
  Future<AuthUser?> getCurrentUser();
  Future<void> logout();
  Future<bool> checkUsernameAvailable(String username);
  Future<AuthUser> updateProfile({
    required String name,
    required String username,
    String? bio,
    String? avatarUrl,
  });
  Future<void> saveVibe(String vibe);
}
