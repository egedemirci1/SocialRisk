import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kısa süreli / satır içi yükleme göstergesi.
/// Tam ekran markalı yükleme için [TheaterLoadingScreen] kullan.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
  });

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
