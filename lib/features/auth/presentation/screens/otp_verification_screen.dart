import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  int _resendSeconds = 30;
  Timer? _resendTimer;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    try {
      await ref.read(authStateProvider.notifier).sendOtp(widget.phoneNumber);
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _verify(String otp) async {
    if (otp.length < 6 || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      await ref.read(authStateProvider.notifier).verifyOtp(widget.phoneNumber, otp);

      if (!mounted) return;
      final authUser = ref.read(authStateProvider).valueOrNull;
      if (authUser == null) return;

      if (!authUser.onboardingComplete) {
        context.go(AppRoutes.profileSetup);
      } else {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _error = AppStrings.invalidOtp;
        _isVerifying = false;
        _otpController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.headlineLarge,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
    );

    final focusedTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      ),
    );

    final errorTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(AppStrings.enterOtp, style: AppTextStyles.headlineLarge)
                  .animate().fadeIn(duration: 300.ms),
              AppSpacing.vGapSm,
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: '${AppStrings.otpSentTo} '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapXxxl,
              Center(
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedTheme,
                  errorPinTheme: errorTheme,
                  onCompleted: _verify,
                  enabled: !_isVerifying,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              if (_error != null) ...[
                AppSpacing.vGapMd,
                Center(
                  child: Text(
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  ),
                ),
              ],
              if (_isVerifying) ...[
                AppSpacing.vGapMd,
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ],
              const Spacer(),
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend OTP in $_resendSeconds seconds',
                        style: AppTextStyles.bodySmall,
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text(AppStrings.resendOtp),
                      ),
              ),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}
