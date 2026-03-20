import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/biometric_setup_screen.dart';
import '../../features/auth/presentation/screens/first_circle_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/vibe_selection_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/calls/presentation/screens/video_call_screen.dart';
import '../../features/calls/presentation/screens/voice_call_screen.dart';
import '../../features/circles/presentation/screens/circle_detail_screen.dart';
import '../../features/circles/presentation/screens/circles_list_screen.dart';
import '../../features/circles/presentation/screens/paid_circle_paywall_screen.dart';
import '../../features/credits/presentation/screens/credits_screen.dart';
import '../../features/feed/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/orbit/presentation/screens/live_selfie_screen.dart';
import '../../features/orbit/presentation/screens/orbit_connections_screen.dart';
import '../../features/orbit/presentation/screens/orbit_discover_screen.dart';
import '../../features/orbit/presentation/screens/orbit_message_screen.dart';
import '../../features/orbit/presentation/screens/orbit_onboarding_screen.dart';
import '../../features/orbit/presentation/screens/orbit_profile_screen.dart';
import '../../features/orbit/presentation/screens/signal_questions_screen.dart';
import '../../features/orbit/presentation/screens/verification_status_screen.dart';
import '../../features/posts/presentation/screens/moment_creator_screen.dart';
import '../../features/posts/presentation/screens/moment_viewer_screen.dart';
import '../../features/posts/presentation/screens/post_composer_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/posts/presentation/screens/voice_recorder_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/stickers/presentation/screens/sticker_store_screen.dart';
import '../shell/main_shell.dart';

part 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final onboardingComplete = authState.valueOrNull?.onboardingComplete ?? false;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.phoneInput;
      }

      if (isAuthenticated && !onboardingComplete && !isOnboarding) {
        return AppRoutes.vibeSelection;
      }

      if (isAuthenticated && onboardingComplete && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.phoneInput,
        builder: (context, state) => const PhoneInputScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final phone = state.extra as String;
              return OtpVerificationScreen(phoneNumber: phone);
            },
          ),
        ],
      ),

      // Onboarding routes
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.vibeSelection,
        builder: (context, state) => const VibeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.firstCircle,
        builder: (context, state) => const FirstCircleScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometricSetup,
        builder: (context, state) => const BiometricSetupScreen(),
      ),

      // Main app shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.circles,
            pageBuilder: (context, state) => const NoTransitionPage(child: CirclesListScreen()),
            routes: [
              GoRoute(
                path: ':circleId',
                builder: (context, state) {
                  return CircleDetailScreen(circleId: state.pathParameters['circleId']!);
                },
                routes: [
                  GoRoute(
                    path: 'paywall',
                    builder: (context, state) {
                      return PaidCirclePaywallScreen(circleId: state.pathParameters['circleId']!);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.orbit,
            pageBuilder: (context, state) => const NoTransitionPage(child: OrbitDiscoverScreen()),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (context, state) => const NoTransitionPage(child: NotificationScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: AppRoutes.postComposer,
        builder: (context, state) => const PostComposerScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceRecorder,
        builder: (context, state) => const VoiceRecorderScreen(),
      ),
      GoRoute(
        path: AppRoutes.momentCreator,
        builder: (context, state) => const MomentCreatorScreen(),
      ),
      GoRoute(
        path: '/posts/:postId',
        builder: (context, state) {
          return PostDetailScreen(postId: state.pathParameters['postId']!);
        },
      ),
      GoRoute(
        path: '/moments/:momentId',
        builder: (context, state) {
          return MomentViewerScreen(momentId: state.pathParameters['momentId']!);
        },
      ),
      GoRoute(
        path: AppRoutes.stickerStore,
        builder: (context, state) => const StickerStoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          return ProfileScreen(userId: state.pathParameters['userId']);
        },
      ),

      // Orbit sub-routes
      GoRoute(
        path: AppRoutes.orbitOnboarding,
        builder: (context, state) => const OrbitOnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveSelfie,
        builder: (context, state) => const LiveSelfieScreen(),
      ),
      GoRoute(
        path: '/orbit/profile/:userId',
        builder: (context, state) {
          return OrbitProfileScreen(userId: state.pathParameters['userId']!);
        },
      ),
      GoRoute(
        path: AppRoutes.orbitConnections,
        builder: (context, state) => const OrbitConnectionsScreen(),
      ),
      GoRoute(
        path: '/orbit/messages/:connectionId',
        builder: (context, state) {
          return OrbitMessageScreen(connectionId: state.pathParameters['connectionId']!);
        },
      ),
      GoRoute(
        path: AppRoutes.signalQuestions,
        builder: (context, state) => const SignalQuestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationStatus,
        builder: (context, state) => const VerificationStatusScreen(),
      ),

      // Calls
      GoRoute(
        path: '/calls/voice/:callId',
        builder: (context, state) {
          return VoiceCallScreen(callId: state.pathParameters['callId']!);
        },
      ),
      GoRoute(
        path: '/calls/video/:callId',
        builder: (context, state) {
          return VideoCallScreen(callId: state.pathParameters['callId']!);
        },
      ),

      // Credits
      GoRoute(
        path: AppRoutes.credits,
        builder: (context, state) => const CreditsScreen(),
      ),
    ],
  );
});

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
