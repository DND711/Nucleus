import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class NucleusAvatar extends StatelessWidget {
  const NucleusAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.isVerified = false,
    this.verificationState = VerificationState.none,
    this.onTap,
    this.heroTag,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool isVerified;
  final VerificationState verificationState;
  final VoidCallback? onTap;
  final Object? heroTag;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  Color get _badgeColor => switch (verificationState) {
        VerificationState.none => Colors.transparent,
        VerificationState.verified => AppColors.verifiedGreen,
        VerificationState.expiringSoon => AppColors.verifiedAmber,
        VerificationState.expired => AppColors.verifiedRed,
      };

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _Placeholder(initials: _initials, size: size),
              errorWidget: (_, __, ___) => _Placeholder(initials: _initials, size: size),
            )
          : _Placeholder(initials: _initials, size: size),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    final withBadge = verificationState != VerificationState.none
        ? Stack(
            children: [
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: _VerificationBadge(
                  color: _badgeColor,
                  size: size * 0.3,
                  state: verificationState,
                ),
              ),
            ],
          )
        : avatar;

    return onTap != null
        ? GestureDetector(onTap: onTap, child: withBadge)
        : withBadge;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.labelLarge.copyWith(
          fontSize: size * 0.35,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({
    required this.color,
    required this.size,
    required this.state,
  });

  final Color color;
  final double size;
  final VerificationState state;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: switch (state) {
        VerificationState.verified => 'Verified real person',
        VerificationState.expiringSoon => 'Verification expiring soon',
        VerificationState.expired => 'Verification expired',
        VerificationState.none => '',
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: AppColors.background, width: 1.5),
        ),
        child: Icon(
          Icons.check_rounded,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }
}

enum VerificationState { none, verified, expiringSoon, expired }
