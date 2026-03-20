import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen> {
  final _auth = LocalAuthentication();
  bool _isLoading = false;
  bool? _canUseBiometrics;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    setState(() => _canUseBiometrics = canCheck && isSupported);
  }

  Future<void> _enable() async {
    setState(() => _isLoading = true);
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Enable biometric login for Nucleus',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        // Save preference
        context.go(AppRoutes.home);
      }
    } catch (_) {
      // Biometric failed — skip
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.fingerprint_rounded,
                size: 80,
                color: AppColors.primaryLight,
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              AppSpacing.vGapXxl,
              Text(
                'Quick & secure login',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapSm,
              Text(
                'Use Face ID or fingerprint to log in instantly next time.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
              const Spacer(),
              if (_canUseBiometrics == true) ...[
                NucleusButton(
                  label: 'Enable Biometric Login',
                  onPressed: _enable,
                  isLoading: _isLoading,
                ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
                AppSpacing.vGapSm,
              ],
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Skip'),
              ).animate(delay: 500.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}
