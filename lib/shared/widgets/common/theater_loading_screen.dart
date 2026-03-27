import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'social_risk_logo.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.surface.withValues(alpha: 0.8),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // S Logo with Pulse Animation
              ScaleTransition(
                scale: _fadeAnimation,
                child: const SocialRiskLogo(
                  height: 120,
                  mode: LogoMode.onlyIcon,
                  showGlow: true,
                ),
              ),
              const SizedBox(height: 32),
              
              // App Title
              Text(
                'Social Risk',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Animated Loading Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.message,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Progress Indicator
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 6,
                        color: AppColors.accent,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    if (widget.progress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${(widget.progress! * 100).toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
