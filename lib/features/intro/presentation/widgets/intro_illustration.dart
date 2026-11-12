import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Concentric gold rings around a hero icon, with small floating badges.
final class IntroIllustration extends StatelessWidget {
  const IntroIllustration({
    super.key,
    required this.icon,
    required this.badges,
    required this.floatAnimation,
  });

  final IconData icon;
  final List<IconData> badges;
  final Animation<double> floatAnimation;

  // Badge anchors on the outer ring, as fractions of the illustration size.
  static const _badgeAnchors = [
    Alignment(-0.92, -0.55),
    Alignment(0.95, -0.15),
    Alignment(-0.6, 0.9),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          300.0,
        );

        return SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Ring(diameter: size, alpha: 0.10),
              _Ring(diameter: size * 0.76, alpha: 0.18),
              _Ring(diameter: size * 0.54, alpha: 0.28),
              _HeroCircle(diameter: size * 0.42, icon: icon),
              for (
                var i = 0;
                i < badges.length && i < _badgeAnchors.length;
                i++
              )
                Align(
                  alignment: _badgeAnchors[i],
                  child: AnimatedBuilder(
                    animation: floatAnimation,
                    builder: (_, child) {
                      // Offset each badge's phase so they drift independently.
                      final t = (floatAnimation.value + i / 3) % 1;
                      final dy = math.sin(t * math.pi * 2) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: _Badge(icon: badges[i], size: size * 0.18),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _Ring extends StatelessWidget {
  const _Ring({required this.diameter, required this.alpha});

  final double diameter;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: alpha)),
      ),
    );
  }
}

final class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.diameter, required this.icon});

  final double diameter;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary300, AppColors.primary700],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: diameter * 0.44, color: AppColors.neutral1000),
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: AppColors.neutral800),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral1000.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: AppColors.primary),
    );
  }
}
