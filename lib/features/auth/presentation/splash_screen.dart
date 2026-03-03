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
    const overlayColor = Color(0xFF140D0B); // Koyu kahve/siyah tonu

    return Scaffold(
      backgroundColor: overlayColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Arka Plan Resmi
          Image.asset(
            'assets/Loading-Screen-Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Hata durumunda (resim bulunamazsa) gradient göster
              return const GradientContainer(child: SizedBox.shrink());
            },
          ),

          // 2. Koyu Katman (Taverna atmosferi)
          Container(color: overlayColor.withValues(alpha: 0.5)),

          // 3. İçerik (Glow efekti, Başlık, Yükleniyor ikonu)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Yazı arkasındaki Glow
                    Container(
                      width: 250,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.4),
                            blurRadius: 70,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFF8B0000,
                            ).withValues(alpha: 0.35),
                            blurRadius: 100,
                            spreadRadius: 40,
                          ),
                        ],
                      ),
                    ),
                    // Başlık
                    Text(
                      'Sosyal Risk',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 48,
                        color: const Color(0xFFFDEFC2),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          const Shadow(
                            color: Colors.black87,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Maceraya Atılıyor...',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: Color(0xFFD4AF37), // Altın sarısı
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
