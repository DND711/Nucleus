class AuthUser {
  const AuthUser({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.username,
    this.avatarUrl,
    required this.isAuthenticated,
    required this.onboardingComplete,
    required this.vibeSetupComplete,
  });

  final String id;
  final String phoneNumber;
  final String? name;
  final String? username;
  final String? avatarUrl;
  final bool isAuthenticated;
  final bool onboardingComplete;
  final bool vibeSetupComplete;

  static const AuthUser unauthenticated = AuthUser(
    id: '',
    phoneNumber: '',
    isAuthenticated: false,
    onboardingComplete: false,
    vibeSetupComplete: false,
  );

  AuthUser copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? username,
    String? avatarUrl,
    bool? isAuthenticated,
    bool? onboardingComplete,
    bool? vibeSetupComplete,
  }) {
    return AuthUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      vibeSetupComplete: vibeSetupComplete ?? this.vibeSetupComplete,
    );
  }
}
