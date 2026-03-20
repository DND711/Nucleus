import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class PostComposerScreen extends ConsumerWidget {
  const PostComposerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.createPost),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
        children: [
          _FormatCard(
            icon: Icons.mic_rounded,
            label: AppStrings.recordVoice,
            color: AppColors.accent,
            onTap: () => context.pushReplacement(AppRoutes.voiceRecorder),
          ),
          _FormatCard(
            icon: Icons.bolt_rounded,
            label: AppStrings.sparkPost,
            color: AppColors.vibeEnergetic,
            onTap: () => context.pushReplacement('/compose/spark'),
          ),
          _FormatCard(
            icon: Icons.auto_awesome_rounded,
            label: AppStrings.createMoment,
            color: AppColors.vibeCreative,
            onTap: () => context.pushReplacement(AppRoutes.momentCreator),
          ),
          _FormatCard(
            icon: Icons.mood_rounded,
            label: 'Share Your Vibe',
            color: AppColors.vibeChill,
            onTap: () => context.pushReplacement('/compose/vibe'),
          ),
        ].indexed.map((e) => e.$2.animate(
          delay: Duration(milliseconds: e.$1 * 60),
        ).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9))).toList(),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppSpacing.iconXl),
            AppSpacing.vGapMd,
            Text(label, style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
