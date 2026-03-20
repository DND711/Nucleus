import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';

class OrbitVisualization extends StatefulWidget {
  const OrbitVisualization({
    super.key,
    required this.profiles,
    required this.onProfileTap,
  });

  final List<dynamic> profiles;
  final ValueChanged<String> onProfileTap;

  @override
  State<OrbitVisualization> createState() => _OrbitVisualizationState();
}

class _OrbitVisualizationState extends State<OrbitVisualization>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final maxRadius = math.min(constraints.maxWidth, constraints.maxHeight) * 0.42;

        return AnimatedBuilder(
          animation: Listenable.merge([_rotateController, _pulseController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _OrbitRingsPainter(
                pulseValue: _pulseController.value,
              ),
              child: Stack(
                children: [
                  // Centre avatar (own profile)
                  Positioned(
                    left: center.dx - AppSpacing.avatarLg / 2,
                    top: center.dy - AppSpacing.avatarLg / 2,
                    child: _PulsingAvatar(
                      pulseValue: _pulseController.value,
                      child: NucleusAvatar(name: 'Me', size: AppSpacing.avatarLg),
                    ),
                  ),

                  // Orbiting profiles
                  ...List.generate(
                    math.min(widget.profiles.length, 4),
                    (index) {
                      final profile = widget.profiles[index];
                      final ring = index < 2 ? 0.5 : 0.85;
                      final baseAngle = (index / widget.profiles.length) * 2 * math.pi;
                      final angle = baseAngle +
                          _rotateController.value * 2 * math.pi * (index.isEven ? 1 : -1);
                      final radius = maxRadius * ring;
                      final x = center.dx + radius * math.cos(angle);
                      final y = center.dy + radius * math.sin(angle);
                      const avatarSize = AppSpacing.avatarMd;

                      return Positioned(
                        left: x - avatarSize / 2,
                        top: y - avatarSize / 2,
                        child: GestureDetector(
                          onTap: () => widget.onProfileTap(profile.userId as String),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              NucleusAvatar(
                                name: profile.name as String,
                                size: avatarSize,
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.orbitPull,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    '${(profile.score as double).round()}%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PulsingAvatar extends StatelessWidget {
  const _PulsingAvatar({required this.pulseValue, required this.child});
  final double pulseValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: AppSpacing.avatarLg + 12 + pulseValue * 8,
          height: AppSpacing.avatarLg + 12 + pulseValue * 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orbitGlow.withOpacity(0.15 - pulseValue * 0.1),
          ),
        ),
        child,
      ],
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  const _OrbitRingsPainter({required this.pulseValue});
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.42;

    for (final ringFraction in [0.5, 0.85]) {
      final paint = Paint()
        ..color = AppColors.orbitGlow.withOpacity(0.12 + pulseValue * 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(center, maxRadius * ringFraction, paint);
    }

    // Centre glow
    final glowPaint = Paint()
      ..color = AppColors.orbitGlow.withOpacity(0.08 + pulseValue * 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, AppSpacing.avatarLg * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(_OrbitRingsPainter old) => old.pulseValue != pulseValue;
}
