import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class OrbitProfileScreen extends ConsumerWidget {
  const OrbitProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: load orbit profile by userId
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _PhotoGallery(userId: userId),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Priya', style: AppTextStyles.headlineLarge),
                                AppSpacing.hGapSm,
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.verifiedGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    border: Border.all(color: AppColors.verifiedGreen, width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded, size: 12, color: AppColors.verifiedGreen),
                                      AppSpacing.hGapXs,
                                      Text('Verified', style: AppTextStyles.labelSmall.copyWith(color: AppColors.verifiedGreen)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text('@priya_creates', style: AppTextStyles.username),
                          ],
                        ),
                      ),
                      _PullScore(score: 91),
                    ],
                  ),
                  AppSpacing.vGapXl,
                  Text('Compatibility', style: AppTextStyles.labelLarge),
                  AppSpacing.vGapMd,
                  _CompatibilityBar(label: 'Voice Energy', value: 0.88, reason: 'Similar voice patterns in notes'),
                  AppSpacing.vGapMd,
                  _CompatibilityBar(label: 'Sticker Language', value: 0.75, reason: 'Both love Bollywood cards'),
                  AppSpacing.vGapMd,
                  _CompatibilityBar(label: 'Vibe Patterns', value: 0.92, reason: 'Mostly Creative & Focused'),
                  AppSpacing.vGapXl,
                  Text('Signal Questions', style: AppTextStyles.labelLarge),
                  AppSpacing.vGapMd,
                  _SignalTile(q: 'One place you want to visit before you die?', a: 'Patagonia. Just Patagonia.'),
                  _SignalTile(q: 'What are you building right now?', a: 'A design studio. Slowly but surely.'),
                  AppSpacing.vGapXxl,
                  Row(
                    children: [
                      Expanded(
                        child: NucleusButton(
                          label: 'Pull into Orbit',
                          onPressed: () {
                            // TODO: orbit pull API call
                          },
                          icon: Icons.radar_rounded,
                        ),
                      ),
                      AppSpacing.hGapMd,
                      OutlinedButton(
                        onPressed: () => _showBlockReport(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(52, 52),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                  AppSpacing.vGapXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block_rounded, color: AppColors.error),
            title: const Text('Block'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.flag_rounded, color: AppColors.warning),
            title: const Text('Report'),
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceElevated),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text('${index + 1}/3', style: AppTextStyles.labelMedium),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PullScore extends StatelessWidget {
  const _PullScore({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orbitGlow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.orbitGlow, width: 0.5),
      ),
      child: Column(
        children: [
          Text('$score%', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.orbitGlow)),
          Text('gravity', style: AppTextStyles.labelSmall.copyWith(color: AppColors.orbitGlow)),
        ],
      ),
    );
  }
}

class _CompatibilityBar extends StatelessWidget {
  const _CompatibilityBar({
    required this.label,
    required this.value,
    required this.reason,
  });

  final String label;
  final double value;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text('${(value * 100).round()}%', style: AppTextStyles.labelLarge.copyWith(color: AppColors.orbitGlow)),
          ],
        ),
        AppSpacing.vGapXs,
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: v,
              backgroundColor: AppColors.surfaceElevated,
              color: AppColors.orbitGlow,
              minHeight: 6,
            ),
          ),
        ),
        AppSpacing.vGapXs,
        Text(reason, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.q, required this.a});
  final String q;
  final String a;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTextStyles.bodySmall),
          AppSpacing.vGapXs,
          Text(a, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
