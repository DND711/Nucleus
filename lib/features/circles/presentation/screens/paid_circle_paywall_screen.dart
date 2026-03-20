import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class PaidCirclePaywallScreen extends ConsumerWidget {
  const PaidCirclePaywallScreen({super.key, required this.circleId});
  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_rounded, size: 64, color: AppColors.primaryLight),
            AppSpacing.vGapXl,
            Text('Exclusive Circle', style: AppTextStyles.displaySmall, textAlign: TextAlign.center),
            AppSpacing.vGapSm,
            Text(
              'Subscribe to access all posts, voice notes and moments in this circle.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXxl,
            // Preview blurred post
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Stack(
                children: [
                  Center(child: Text('Preview post…', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary))),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        color: AppColors.surface.withOpacity(0.8),
                        child: Center(
                          child: Icon(Icons.blur_on_rounded, size: 40, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            NucleusButton(
              label: 'Subscribe · ₹299/month',
              onPressed: () {
                // TODO: Razorpay subscription
              },
            ),
            AppSpacing.vGapSm,
            Text(
              'Cancel anytime. Creator gets 90%.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }
}
