part of 'app_router.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String phoneInput = '/auth/phone';
  static const String otpVerification = '/auth/phone/otp';

  // Onboarding
  static const String profileSetup = '/onboarding/profile';
  static const String vibeSelection = '/onboarding/vibe';
  static const String firstCircle = '/onboarding/circle';
  static const String biometricSetup = '/onboarding/biometric';

  // Main
  static const String home = '/home';
  static const String circles = '/circles';
  static const String orbit = '/orbit';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Posts
  static const String postComposer = '/compose';
  static const String voiceRecorder = '/compose/voice';
  static const String momentCreator = '/compose/moment';

  // Stickers
  static const String stickerStore = '/stickers/store';

  // Search
  static const String search = '/search';

  // Settings
  static const String settings = '/settings';

  // Orbit
  static const String orbitOnboarding = '/orbit/onboarding';
  static const String liveSelfie = '/orbit/verify/selfie';
  static const String orbitConnections = '/orbit/connections';
  static const String signalQuestions = '/orbit/signal-questions';
  static const String verificationStatus = '/orbit/verification';

  // Credits
  static const String credits = '/credits';
}
