import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class FirstCircleScreen extends ConsumerStatefulWidget {
  const FirstCircleScreen({super.key});

  @override
  ConsumerState<FirstCircleScreen> createState() => _FirstCircleScreenState();
}

class _FirstCircleScreenState extends ConsumerState<FirstCircleScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'close_friends';
  bool _isLoading = false;

  static const _circleTypes = [
    _CircleType('close_friends', AppStrings.closeFriends, Icons.favorite_rounded, AppColors.accent),
    _CircleType('builders', AppStrings.buildersCircle, Icons.code_rounded, AppColors.primary),
    _CircleType('city', AppStrings.cityCircle, Icons.location_city_rounded, AppColors.vibeChill),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _isLoading = true);
    // TODO: Create circle via API
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.go(AppRoutes.biometricSetup);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createFirstCircle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vGapXxl,
              Text(
                'A circle is your private group.',
                style: AppTextStyles.headlineMedium,
              ).animate().fadeIn(duration: 300.ms),
              AppSpacing.vGapSm,
              Text(
                'Everything you share goes to specific circles — never everyone.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapXxl,
              Text('Circle type', style: AppTextStyles.labelLarge),
              AppSpacing.vGapMd,
              Row(
                children: _circleTypes.map((type) {
                  final isSelected = _selectedType == type.key;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected ? type.color.withOpacity(0.15) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: isSelected ? type.color : AppColors.border,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(type.icon, color: isSelected ? type.color : AppColors.textTertiary),
                              AppSpacing.vGapXs,
                              Text(
                                type.label,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected ? type.color : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              AppSpacing.vGapXxl,
              Text('Circle name', style: AppTextStyles.labelLarge),
              AppSpacing.vGapSm,
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyLarge,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. My Close Friends'),
                onChanged: (_) => setState(() {}),
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
              const Spacer(),
              NucleusButton(
                label: 'Create Circle',
                onPressed: _nameController.text.trim().isNotEmpty ? _create : null,
                isLoading: _isLoading,
              ),
              AppSpacing.vGapSm,
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.biometricSetup),
                  child: const Text('Skip for now'),
                ),
              ),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleType {
  const _CircleType(this.key, this.label, this.icon, this.color);

  final String key;
  final String label;
  final IconData icon;
  final Color color;
}
