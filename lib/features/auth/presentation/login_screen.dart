import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../core/constants/app_colors.dart';
import '../data/firebase_user_source.dart';
import '../domain/user_entity.dart';

/// Login ekranı — Tiyatro Temalı
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _isAnonymousLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Lütfen sahne adınızı belirleyin');
      return;
    }
    setState(() => _isAnonymousLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signIn(name);
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isAnonymousLoading = false);
    }
  }

  Future<void> _signInSocial(
    Future<UserCredential> Function() method,
    String name,
  ) async {
    setState(() {
      if (name == 'google') _isGoogleLoading = true;
      if (name == 'apple') _isAppleLoading = true;
    });
    try {
      final cred = await method();
      if (cred.user != null) {
        final displayName = cred.user!.displayName ?? 'Aktör';
        if (cred.user!.displayName == null) {
          await cred.user!.updateDisplayName(displayName);
        }
        // Kullanıcı profilini Firestore'da oluştur (anonim hesap oluşturmadan)
        final userSource = FirebaseUserSource();
        await userSource.createUserProfile(
          UserEntity(uid: cred.user!.uid, displayName: displayName),
        );
      }
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isAppleLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Yumuşak bir üst aydınlatma
            Positioned(
              top: -150,
              left: -50,
              right: -50,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 64),
                      _buildLoginCard(),
                      const SizedBox(height: 32),
                      _buildSocialSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Sosyal Risk',
              style: GoogleFonts.playfairDisplay(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            maxLength: 24,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: 'Sahne Adınız...',
              hintStyle: GoogleFonts.playfairDisplay(
                color: Colors.white24,
                fontWeight: FontWeight.w500,
              ),
              counterText: '',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.accent,
              ),
              filled: true,
              fillColor: Colors.black26,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 24),
          StageButton(
            label: 'Gösteriye Katıl',
            icon: Icons.theater_comedy_rounded,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent,
            onPressed: _signInAnonymously,
            isLoading: _isAnonymousLoading,
          ),
          const SizedBox(height: 12),
          Text(
            '* Anonim olarak devam edeceksiniz. İstatistikleriniz bu cihaza kaydedilir.',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Veya',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white24,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StageButton(
                label: '',
                icon: Icons.g_mobiledata_rounded,
                backgroundColor: AppColors.surface,
                textColor: Colors.white,
                borderColor: Colors.white12,
                onPressed: () => _signInSocial(() {
                  final provider = GoogleAuthProvider();
                  return FirebaseAuth.instance.signInWithPopup(provider);
                }, 'google'),
                isLoading: _isGoogleLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StageButton(
                label: '',
                icon: Icons.apple_rounded,
                backgroundColor: AppColors.surface,
                textColor: Colors.white,
                borderColor: Colors.white12,
                onPressed: () => _signInSocial(() {
                  final provider = OAuthProvider('apple.com');
                  return FirebaseAuth.instance.signInWithPopup(provider);
                }, 'apple'),
                isLoading: _isAppleLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
