import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Uygulama başlarken gösterilen splash ekranı.
/// Firebase auth durumunu dinler ve uygun sayfaya yönlendirir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Give Firebase Auth up to 2 seconds to restore a cached session.
    // authStateChanges().first may never complete if the initial event
    // already fired before this widget subscribed, so we use a timeout.
    User? user;
    try {
      user = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Timeout or error — fall back to synchronous check
      user = FirebaseAuth.instance.currentUser;
    }

    if (!mounted) return;
    context.go(user != null ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Text('🎮', style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Sosyal Risk',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yükleniyor...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
