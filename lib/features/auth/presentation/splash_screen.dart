import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 2),
      );
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
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Arka Plan Işık Efekti
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // 2. İçerik (Başlık ve Yükleniyor)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Social Risk',
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Parti Hazırlanıyor...',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
