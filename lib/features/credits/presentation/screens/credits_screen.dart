import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../providers/credits_provider.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  bool _isClaimLoading = false;
  bool _alreadyClaimed = false;

  static const _packs = [
    _CreditPack('starter', 50, 29, '50 Credits'),
    _CreditPack('basic', 200, 99, '200 Credits'),
    _CreditPack('popular', 500, 199, '500 Credits', isBestValue: true),
    _CreditPack('mega', 1500, 499, '1500 Credits'),
  ];

  Future<void> _claimDaily() async {
    setState(() => _isClaimLoading = true);
    try {
      await ref.read(creditsNotifierProvider.notifier).claimDaily();
      setState(() => _alreadyClaimed = true);
    } catch (_) {}
    setState(() => _isClaimLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(creditsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text(AppStrings.credits),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.creditGold, size: 40),
                  AppSpacing.vGapSm,
                  credits.when(
                    data: (balance) => Text(
                      '$balance',
                      style: AppTextStyles.credit.copyWith(fontSize: 56),
                    ).animate().fadeIn(duration: 300.ms),
                    loading: () => const CircularProgressIndicator(color: AppColors.creditGold),
                    error: (_, __) => const Text('--', style: AppTextStyles.credit),
                  ),
                  Text(AppStrings.yourBalance, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  AppSpacing.vGapLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CallCostInfo(icon: Icons.call_rounded, label: 'Voice', cost: '2 credits/min'),
                      Container(width: 1, height: 30, color: Colors.white24),
                      _CallCostInfo(icon: Icons.videocam_rounded, label: 'Video', cost: '5 credits/min'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),

            AppSpacing.vGapXl,

            // Daily claim
            NucleusButton(
              label: _alreadyClaimed ? AppStrings.alreadyClaimed : AppStrings.claimDaily,
              onPressed: _alreadyClaimed ? null : _claimDaily,
              isLoading: _isClaimLoading,
              icon: Icons.bolt_rounded,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            AppSpacing.vGapXxl,

            Text(AppStrings.buyCredits, style: AppTextStyles.headlineMedium)
                .animate(delay: 150.ms).fadeIn(duration: 300.ms),
            AppSpacing.vGapMd,

            // Credit packs
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
              ),
              itemCount: _packs.length,
              itemBuilder: (context, index) {
                final pack = _packs[index];
                return _CreditPackCard(
                  pack: pack,
                  onTap: () {
                    // TODO: Razorpay payment
                  },
                ).animate(delay: Duration(milliseconds: 200 + index * 60))
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9));
              },
            ),

            AppSpacing.vGapXxl,
            Text(AppStrings.callHistory, style: AppTextStyles.headlineMedium),
            AppSpacing.vGapMd,
            const _CallHistoryList(),
          ],
        ),
      ),
    );
  }
}

class _CallCostInfo extends StatelessWidget {
  const _CallCostInfo({required this.icon, required this.label, required this.cost});
  final IconData icon;
  final String label;
  final String cost;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        AppSpacing.vGapXs,
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
        Text(cost, style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _CreditPack {
  const _CreditPack(this.id, this.credits, this.priceInr, this.label, {this.isBestValue = false});
  final String id;
  final int credits;
  final int priceInr;
  final String label;
  final bool isBestValue;
}

class _CreditPackCard extends StatelessWidget {
  const _CreditPackCard({required this.pack, required this.onTap});
  final _CreditPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: pack.isBestValue ? AppColors.creditGold : AppColors.border,
                width: pack.isBestValue ? 1.5 : 0.5,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.creditGold, size: 20),
                    Text(
                      '${pack.credits}',
                      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.creditGold),
                    ),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(
                  '₹${pack.priceInr}',
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryLight),
                ),
                Text(
                  '₹${(pack.priceInr / pack.credits * 10).toStringAsFixed(1)} per 10 cr',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          if (pack.isBestValue)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.creditGold,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSpacing.radiusLg),
                    bottomLeft: Radius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: Text('BEST VALUE', style: AppTextStyles.labelSmall.copyWith(color: Colors.black, fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CallHistoryList extends StatelessWidget {
  const _CallHistoryList();

  @override
  Widget build(BuildContext context) {
    // Demo call history
    final items = [
      _CallHistoryItem(name: 'Priya', type: 'voice', durationMin: 18, credits: 36, ago: '2 hours ago'),
      _CallHistoryItem(name: 'Ananya', type: 'video', durationMin: 5, credits: 25, ago: 'Yesterday'),
    ];

    if (items.isEmpty) {
      return Center(
        child: Text('No calls yet', style: AppTextStyles.bodySmall),
      );
    }

    return Column(
      children: items.map((item) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: item.type == 'voice' ? AppColors.primary.withOpacity(0.2) : AppColors.accent.withOpacity(0.2),
          child: Icon(
            item.type == 'voice' ? Icons.call_rounded : Icons.videocam_rounded,
            color: item.type == 'voice' ? AppColors.primaryLight : AppColors.accent,
            size: 18,
          ),
        ),
        title: Text(item.name, style: AppTextStyles.bodyMedium),
        subtitle: Text('${item.durationMin} min · ${item.ago}', style: AppTextStyles.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.creditGold, size: 14),
            Text('${item.credits}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.creditGold)),
          ],
        ),
      )).toList(),
    );
  }
}

class _CallHistoryItem {
  const _CallHistoryItem({required this.name, required this.type, required this.durationMin, required this.credits, required this.ago});
  final String name;
  final String type;
  final int durationMin;
  final int credits;
  final String ago;
}
