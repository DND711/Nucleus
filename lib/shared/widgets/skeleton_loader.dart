import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.border,
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.radiusSm,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class FeedCardSkeleton extends StatelessWidget {
  const FeedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(width: 40, height: 40, borderRadius: AppSpacing.radiusFull),
                AppSpacing.hGapMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: MediaQuery.of(context).size.width * 0.3),
                    AppSpacing.vGapXs,
                    const SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ],
            ),
            AppSpacing.vGapMd,
            const SkeletonBox(height: 16),
            AppSpacing.vGapXs,
            SkeletonBox(width: MediaQuery.of(context).size.width * 0.7),
            AppSpacing.vGapMd,
            const SkeletonBox(height: 48, borderRadius: AppSpacing.radiusMd),
            AppSpacing.vGapMd,
            Row(
              children: const [
                SkeletonBox(width: 60, height: 28, borderRadius: AppSpacing.radiusFull),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 60, height: 28, borderRadius: AppSpacing.radiusFull),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 60, height: 28, borderRadius: AppSpacing.radiusFull),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrbitCardSkeleton extends StatelessWidget {
  const OrbitCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonBox(height: 12, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const Center(
            child: SkeletonBox(
              width: AppSpacing.avatarHero,
              height: AppSpacing.avatarHero,
              borderRadius: AppSpacing.radiusFull,
            ),
          ),
          AppSpacing.vGapMd,
          const Center(child: SkeletonBox(width: 120, height: 22)),
          AppSpacing.vGapSm,
          const Center(child: SkeletonBox(width: 80, height: 14)),
          AppSpacing.vGapXxl,
          const Divider(height: 0),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: 9,
              itemBuilder: (_, __) => Container(color: AppColors.surfaceElevated),
            ),
          ),
        ],
      ),
    );
  }
}
