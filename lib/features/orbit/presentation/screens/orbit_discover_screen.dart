import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../widgets/orbit_visualization.dart';

class OrbitDiscoverScreen extends ConsumerWidget {
  const OrbitDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: check if orbit is enabled
    const isOrbitEnabled = true;

    if (!isOrbitEnabled) {
      return const _OrbitDisabledView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.orbit,
            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.orbitGlow)),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            onPressed: () => context.push(AppRoutes.orbitConnections),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: const _OrbitDiscoverBody(),
    );
  }
}

class _OrbitDiscoverBody extends ConsumerWidget {
  const _OrbitDiscoverBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demo profiles for the orbit
    final profiles = [
      _DemoProfile('Priya', 'priya', 91.0),
      _DemoProfile('Ananya', 'ananya', 78.0),
      _DemoProfile('Sneha', 'sneha', 65.0),
      _DemoProfile('Ritu', 'ritu', 54.0),
    ];

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: RepaintBoundary(
            child: OrbitVisualization(
              profiles: profiles,
              onProfileTap: (userId) => context.push('/orbit/profile/$userId'),
            ),
          ),
        ),
        Expanded(
          child: _PersonCardScroll(profiles: profiles),
        ),
      ],
    );
  }
}

class _DemoProfile {
  const _DemoProfile(this.name, this.userId, this.score);
  final String name;
  final String userId;
  final double score;
}

class _PersonCardScroll extends StatelessWidget {
  const _PersonCardScroll({required this.profiles});
  final List<_DemoProfile> profiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: Text('In your orbit', style: AppTextStyles.labelLarge),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final p = profiles[index];
              return GestureDetector(
                onTap: () => context.push('/orbit/profile/${p.userId}'),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NucleusAvatar(name: p.name, size: AppSpacing.avatarLg),
                      AppSpacing.vGapSm,
                      Text(p.name, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        '${p.score.round()}% pull',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.orbitGlow),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: index * 80))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }
}

class _OrbitDisabledView extends StatelessWidget {
  const _OrbitDisabledView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.radar_rounded, size: 80, color: AppColors.orbitGlow),
              AppSpacing.vGapXxl,
              Text(AppStrings.orbit, style: AppTextStyles.displaySmall, textAlign: TextAlign.center),
              AppSpacing.vGapSm,
              Text(
                AppStrings.orbitTagline,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapXxxl,
              _FeatureBullet(text: 'Your Nucleus activity becomes your dating profile'),
              _FeatureBullet(text: 'Real verified photos — no fakes'),
              _FeatureBullet(text: 'Gravitational matching — not swiping'),
              _FeatureBullet(text: 'Voice + video calls inside the app'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.orbitOnboarding),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: const Text(AppStrings.enableOrbit),
              ),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.orbitGlow, size: 20),
          AppSpacing.hGapMd,
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
