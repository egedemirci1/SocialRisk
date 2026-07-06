import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/splash_remover.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import 'package:social_risk/l10n/app_localizations.dart';

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
    User? user;
    try {
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      user = FirebaseAuth.instance.currentUser;
    }

    if (!mounted) return;
    removeNativeSplash();
    context.go(user != null ? '/home' : '/');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedMeshBackground(),
          TheaterLoadingScreen(message: l.preparingParty),
        ],
      ),
    );
  }
}
