import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class TheaterLoadingScreen extends StatefulWidget {
  const TheaterLoadingScreen({
    super.key,
    this.message = 'Parti Hazırlanıyor...',
    /// 0.0–1.0: determinate progress bar; null: indeterminate
    this.progress,
  });

  final String message;
  final double? progress;

  @override
  State<TheaterLoadingScreen> createState() => _TheaterLoadingScreenState();
}

class _TheaterLoadingScreenState extends State<TheaterLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration_rounded,
                color: AppColors.accent,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
