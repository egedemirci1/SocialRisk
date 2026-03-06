import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({super.key});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;

        return Stack(
          children: [
            // Top Left -> Moves toward Center
            Positioned(
              top: -100 + (height * 0.3 * _controller.value),
              left: -100 + (width * 0.4 * _controller.value),
              child: Container(
                width: width * 1.2,
                height: width * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom Right -> Moves toward Center Left
            Positioned(
              bottom: -150 + (height * 0.25 * _controller.value),
              right: -100 + (width * 0.3 * _controller.value),
              child: Container(
                width: width * 1.5,
                height: width * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.40),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 1.0],
                  ),
                ),
              ),
            ),
            // Center Pulse -> Deep Purple / Indigo
            Positioned(
              top: height * 0.2 + (50 * (1 - _controller.value)),
              left: width * 0.1,
              child: Transform.scale(
                scale: 1.0 + (0.5 * _controller.value),
                child: Container(
                  width: width * 0.8,
                  height: width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6A0DAD).withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

