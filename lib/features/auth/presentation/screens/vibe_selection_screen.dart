import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../providers/auth_provider.dart';

class VibeSelectionScreen extends ConsumerStatefulWidget {
  const VibeSelectionScreen({super.key});

  @override
  ConsumerState<VibeSelectionScreen> createState() => _VibeSelectionScreenState();
}

class _VibeSelectionScreenState extends ConsumerState<VibeSelectionScreen> {
  String? _selectedVibe;
  bool _isLoading = false;

  static const _vibes = [
    _Vibe('creative', AppStrings.vibeCreative, AppColors.vibeCreative),
    _Vibe('energetic', AppStrings.vibeEnergetic, AppColors.vibeEnergetic),
    _Vibe('chill', AppStrings.vibeChill, AppColors.vibeChill),
    _Vibe('deep', AppStrings.vibeDeep, AppColors.vibeDeep),
    _Vibe('happy', AppStrings.vibeHappy, AppColors.vibeHappy),
    _Vibe('anxious', AppStrings.vibeAnxious, AppColors.vibeAnxious),
    _Vibe('lonely', AppStrings.vibeLonely, AppColors.vibeLonely),
    _Vibe('focused', AppStrings.vibeFocused, AppColors.vibeFocused),
  ];

  Future<void> _confirm() async {
    if (_selectedVibe == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).saveVibe(_selectedVibe!);
      if (mounted) context.go(AppRoutes.firstCircle);
    } catch (e) {
      // ignore — vibe can be retried
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.massive),
              Text(AppStrings.chooseVibe, style: AppTextStyles.displaySmall)
                  .animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
              AppSpacing.vGapSm,
              Text(
                'This shapes your world on Nucleus.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapXxl,
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _vibes.length,
                  itemBuilder: (context, index) {
                    final vibe = _vibes[index];
                    final isSelected = _selectedVibe == vibe.key;
                    return _VibeCard(
                      vibe: vibe,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedVibe = vibe.key);
                      },
                    ).animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2);
                  },
                ),
              ),
              AppSpacing.vGapXl,
              NucleusButton(
                label: AppStrings.continueText,
                onPressed: _selectedVibe != null ? _confirm : null,
                isLoading: _isLoading,
              ),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _VibeCard extends StatefulWidget {
  const _VibeCard({
    required this.vibe,
    required this.isSelected,
    required this.onTap,
  });

  final _Vibe vibe;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_VibeCard> createState() => _VibeCardState();
}

class _VibeCardState extends State<_VibeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_VibeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.vibe.color.withOpacity(0.2)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: widget.isSelected ? widget.vibe.color : AppColors.border,
              width: widget.isSelected ? 1.5 : 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.vibe.label,
            style: AppTextStyles.headlineSmall.copyWith(
              color: widget.isSelected ? widget.vibe.color : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Vibe {
  const _Vibe(this.key, this.label, this.color);

  final String key;
  final String label;
  final Color color;
}
