import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class TheaterLoadingScreen extends StatefulWidget {
  const TheaterLoadingScreen({
    super.key,
    this.message = 'Sahne Hazırlanıyor...',
  });

  final String message;

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
                Icons.theater_comedy_rounded,
                color: AppColors.accent,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 40,
                child: LinearProgressIndicator(
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
