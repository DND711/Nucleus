import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/credits/providers/credits_provider.dart';

class CreditCounter extends ConsumerWidget {
  const CreditCounter({super.key, this.showWarning = true});

  final bool showWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(creditBalanceProvider);

    return balance.when(
      data: (credits) {
        final isLow = credits < 10;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLow && showWarning
                ? AppColors.creditLow.withOpacity(0.15)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isLow && showWarning ? AppColors.creditLow : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 14,
                color: isLow && showWarning ? AppColors.creditLow : AppColors.creditGold,
              ),
              const SizedBox(width: 4),
              Text(
                '$credits',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isLow && showWarning ? AppColors.creditLow : AppColors.creditGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(credits)).shake(
              duration: isLow && showWarning ? 300.ms : Duration.zero,
            );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
