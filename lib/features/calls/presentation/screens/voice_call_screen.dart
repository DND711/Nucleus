import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/credit_counter.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../../providers/call_provider.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({super.key, required this.callId});
  final String callId;

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  Duration _elapsed = Duration.zero;
  Timer? _elapsedTimer;
  Timer? _creditTimer;

  static const _creditsPerMinute = 2;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _startTimers();
  }

  void _startTimers() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });

    // Deduct 1 credit every 30 seconds (= 2 credits/minute)
    _creditTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.read(creditsNotifierProvider.notifier).deduct(1);
      _checkLowCredits();
    });
  }

  void _checkLowCredits() {
    final balance = ref.read(creditsNotifierProvider).valueOrNull ?? 0;
    if (balance < 10 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Low Credits — less than 10 remaining'),
          backgroundColor: AppColors.creditLow,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _endCall() async {
    _elapsedTimer?.cancel();
    _creditTimer?.cancel();
    await WakelockPlus.disable();
    ref.read(callManagerProvider).endCall(widget.callId);
    if (mounted) context.pop();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _creditTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CreditCounter(),
                  Text(_formatDuration(_elapsed), style: AppTextStyles.headlineMedium),
                  const Icon(Icons.lock_rounded, color: AppColors.textTertiary, size: 16),
                ],
              ),
            ),

            const Spacer(),

            // Avatar + name
            NucleusAvatar(name: 'Priya', size: AppSpacing.avatarHero),
            AppSpacing.vGapXl,
            const Text('Priya', style: AppTextStyles.displaySmall),
            AppSpacing.vGapSm,
            Text(
              'Voice Call · 2 credits/min',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),

            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxxl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    color: _isMuted ? AppColors.error : AppColors.surfaceElevated,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _CallButton(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    color: AppColors.error,
                    size: 72,
                    onTap: _endCall,
                  ),
                  _CallButton(
                    icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    label: 'Speaker',
                    color: _isSpeaker ? AppColors.primaryLight.withOpacity(0.2) : AppColors.surfaceElevated,
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.icon, required this.label, required this.color, required this.onTap, this.size = 56.0});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
          AppSpacing.vGapXs,
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

// Dummy provider reference — implement fully in call_provider.dart
import '../../providers/credits_provider_ref.dart';
