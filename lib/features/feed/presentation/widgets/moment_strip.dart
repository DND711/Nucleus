import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../../providers/moments_provider.dart';

class MomentStrip extends ConsumerWidget {
  const MomentStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);

    return SizedBox(
      height: 88,
      child: moments.when(
        data: (list) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          itemCount: list.length + 1, // +1 for "Add your moment"
          itemBuilder: (context, index) {
            if (index == 0) {
              return _AddMomentCard(
                onTap: () => context.push('/compose/moment'),
              );
            }
            final moment = list[index - 1];
            return _MomentThumbnail(
              moment: moment,
              onTap: () => context.push('/moments/${moment.id}'),
            );
          },
        ),
        loading: () => const _MomentStripSkeleton(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _AddMomentCard extends StatelessWidget {
  const _AddMomentCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            ),
            AppSpacing.vGapXs,
            Text('Add', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _MomentThumbnail extends StatelessWidget {
  const _MomentThumbnail({required this.moment, required this.onTap});

  final dynamic moment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.primaryLight, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (moment.imageUrl != null)
              CachedNetworkImage(
                imageUrl: moment.imageUrl as String,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  moment.emoji as String? ?? '✨',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MomentStripSkeleton extends StatelessWidget {
  const _MomentStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Container(
          width: 60,
          margin: const EdgeInsets.only(left: AppSpacing.screenPadding, right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}
