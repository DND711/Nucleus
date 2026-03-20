class StorageKeys {
  const StorageKeys._();

  // Secure Storage (JWT)
  static const String accessToken = 'nucleus_access_token';
  static const String refreshToken = 'nucleus_refresh_token';
  static const String userId = 'nucleus_user_id';

  // Shared Preferences
  static const String onboardingComplete = 'onboarding_complete';
  static const String vibeSetupComplete = 'vibe_setup_complete';
  static const String biometricEnabled = 'biometric_enabled';
  static const String themeMode = 'theme_mode';
  static const String lastNotifCheck = 'last_notif_check';

  // Hive Box Names
  static const String userProfileBox = 'user_profile';
  static const String feedCacheBox = 'feed_cache';
  static const String stickerCacheBox = 'sticker_cache';
  static const String callHistoryBox = 'call_history';
  static const String messageBox = 'messages';
  static const String orbitProfileBox = 'orbit_profile';
  static const String circleBox = 'circles';
  static const String creditsBox = 'credits';
}
