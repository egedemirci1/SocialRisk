import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Uygulama başlarken gösterilen splash ekranı.
/// Firebase auth durumunu dinler ve uygun sayfaya yönlendirir.
/// Not: Şu an router'da kullanılmıyor; uygulama doğrudan / (Login) ile başlıyor.
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
    User? user;
    try {
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      user = FirebaseAuth.instance.currentUser;
    }

    if (!mounted) return;
    context.go(user != null ? '/home' : '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Social Risk',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,),
            ),
            const SizedBox(height: 16),
            Text(
              'Parti Hazırlanıyor...',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,),
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
    );
  }
}
