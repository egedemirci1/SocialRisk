import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF231D4D), // AppColors.surface
            Color(0xFF16103A), // AppColors.background
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}
