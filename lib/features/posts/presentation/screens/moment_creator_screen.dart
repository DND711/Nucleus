import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class MomentCreatorScreen extends ConsumerStatefulWidget {
  const MomentCreatorScreen({super.key});

  @override
  ConsumerState<MomentCreatorScreen> createState() => _MomentCreatorScreenState();
}

class _MomentCreatorScreenState extends ConsumerState<MomentCreatorScreen> {
  static const _gradients = [
    [Color(0xFF6B21A8), Color(0xFF4C1D95)],
    [Color(0xFFEC4899), Color(0xFF9333EA)],
    [Color(0xFF0EA5E9), Color(0xFF0284C7)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEF4444), Color(0xFFB91C1C)],
    [Color(0xFF1E1B4B), Color(0xFF312E81)],
    [Color(0xFF0F172A), Color(0xFF1E293B)],
  ];

  static const _emojis = ['✨', '💜', '🌊', '⚡', '🌌', '🎯', '🔥', '🌸', '🎭', '🚀', '💫', '🎪'];

  int _selectedGradient = 0;
  String _selectedEmoji = '✨';
  bool _isLoading = false;

  Future<void> _publish() async {
    setState(() => _isLoading = true);
    // TODO: create moment via API
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.createMoment),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  // Preview
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradients[_selectedGradient],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _selectedEmoji,
                          key: ValueKey(_selectedEmoji),
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.vGapXl,
                  // Gradient picker
                  Text('Background', style: AppTextStyles.labelLarge),
                  AppSpacing.vGapSm,
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _gradients.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedGradient;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGradient = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: _gradients[index]),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AppSpacing.vGapLg,
                  // Emoji picker
                  Text('Emoji', style: AppTextStyles.labelLarge),
                  AppSpacing.vGapSm,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _emojis.map((emoji) {
                      final isSelected = emoji == _selectedEmoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight.withOpacity(0.2) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryLight : AppColors.border,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              MediaQuery.of(context).padding.bottom + AppSpacing.lg,
            ),
            child: NucleusButton(
              label: 'Share Moment',
              onPressed: _publish,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
