import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum NucleusButtonVariant { primary, secondary, ghost, danger }

class NucleusButton extends StatelessWidget {
  const NucleusButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NucleusButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.size = NucleusButtonSize.large,
  });

  final String label;
  final VoidCallback? onPressed;
  final NucleusButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final NucleusButtonSize size;

  bool get _isDisabled => onPressed == null || isLoading;

  Color get _backgroundColor {
    if (_isDisabled) return AppColors.surfaceElevated;
    return switch (variant) {
      NucleusButtonVariant.primary => AppColors.primary,
      NucleusButtonVariant.secondary => AppColors.surfaceElevated,
      NucleusButtonVariant.ghost => Colors.transparent,
      NucleusButtonVariant.danger => AppColors.error,
    };
  }

  Color get _foregroundColor {
    if (_isDisabled) return AppColors.textTertiary;
    return switch (variant) {
      NucleusButtonVariant.primary => AppColors.textPrimary,
      NucleusButtonVariant.secondary => AppColors.textPrimary,
      NucleusButtonVariant.ghost => AppColors.primaryLight,
      NucleusButtonVariant.danger => AppColors.textPrimary,
    };
  }

  BorderSide get _borderSide {
    if (variant == NucleusButtonVariant.secondary) {
      return const BorderSide(color: AppColors.border, width: 0.5);
    }
    return BorderSide.none;
  }

  double get _height => switch (size) {
        NucleusButtonSize.large => 52.0,
        NucleusButtonSize.medium => 44.0,
        NucleusButtonSize.small => 36.0,
      };

  TextStyle get _textStyle => switch (size) {
        NucleusButtonSize.large => AppTextStyles.labelLarge,
        NucleusButtonSize.medium => AppTextStyles.labelLarge,
        NucleusButtonSize.small => AppTextStyles.labelMedium,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ElevatedButton(
        onPressed: _isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: _borderSide,
          ),
          minimumSize: const Size(double.infinity, 0),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSpacing.iconSm),
                    AppSpacing.hGapSm,
                  ],
                  Text(label, style: _textStyle.copyWith(color: _foregroundColor)),
                ],
              ),
      ),
    );
  }
}

enum NucleusButtonSize { large, medium, small }
