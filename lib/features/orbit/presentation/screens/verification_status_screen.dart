import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class VerificationStatusScreen extends ConsumerWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiryDate = DateTime.now().add(const Duration(days: 76));
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 14;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Verification Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.verifiedGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.verifiedGreen, width: 0.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.verifiedGreen, size: 48),
                  AppSpacing.vGapMd,
                  Text('Verified', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.verifiedGreen)),
                  AppSpacing.vGapSm,
                  Text(
                    'Your identity is verified. Your blue tick is active.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            AppSpacing.vGapXxl,
            _InfoRow(label: 'Verified on', value: DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 14)))),
            _InfoRow(label: 'Expires on', value: DateFormat('d MMM yyyy').format(expiryDate)),
            _InfoRow(
              label: 'Days remaining',
              value: '$daysLeft days',
              valueColor: isExpiringSoon ? AppColors.verifiedAmber : AppColors.verifiedGreen,
            ),
            if (isExpiringSoon) ...[
              AppSpacing.vGapXxl,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.verifiedAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.verifiedAmber, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.verifiedAmber),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Text(
                        'Your verification expires soon. Renew to keep your blue tick.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.verifiedAmber),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGapLg,
              NucleusButton(
                label: 'Renew Verification',
                onPressed: () => context.push('/orbit/verify/selfie'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.labelLarge.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
