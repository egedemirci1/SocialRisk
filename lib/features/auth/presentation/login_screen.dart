import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../core/constants/app_colors.dart';
import '../data/firebase_user_source.dart';
import '../domain/user_entity.dart';
import '../constants/auth_constants.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/utils/pending_toast.dart';
import '../../../shared/widgets/common/social_risk_logo.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';

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
  bool _showFlare = false;

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
    HapticFeedback.mediumImpact();
    setState(() => _showFlare = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _showFlare = false);
    });

    final name = _nameController.text.trim();
    final nameRegex = RegExp(r'^[a-zA-Z0-9ığüşöçİĞÜŞÖÇ ]+$');
    
    if (name.isEmpty) {
      _showError('Lütfen sahne adınızı belirleyin');
      return;
    }
    if (name.length < 3) {
      _showError('İsim en az 3 karakter olmalıdır');
      return;
    }
    if (!nameRegex.hasMatch(name)) {
      _showError('Sadece harf ve rakam kullanın');
      return;
    }
    
    setState(() => _isAnonymousLoading = true);
    try {
      PendingToast.instance.setSuccess('Anonim olarak giriş yapıldı');
      await ref.read(authControllerProvider.notifier).signIn(name);
    } catch (e) {
      PendingToast.instance.consume(); // clear the pending toast if login failed
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isAnonymousLoading = false);
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return FirebaseAuth.instance.signInWithPopup(provider);
    }
    // Android / iOS: Firebase Auth için Web Client ID gerekli (Google Cloud Console → Credentials → OAuth 2.0 Web client)
    final googleSignIn = GoogleSignIn(
      serverClientId: kGoogleSignInWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google giriş iptal edildi');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
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
        final displayName = cred.user!.displayName ?? 'Oyuncu';
        if (cred.user!.displayName == null) {
          await cred.user!.updateDisplayName(displayName);
        }
        // Kullanıcı profilini Firestore'da oluştur (anonim hesap oluşturmadan)
        final userSource = FirebaseUserSource();
        await userSource.createUserProfile(
          UserEntity(uid: cred.user!.uid, displayName: displayName),
        );
        PendingToast.instance.setSuccess('Giriş Başarılı');
      }
    } catch (e) {
      PendingToast.instance.consume();
      if (mounted) {
        String msg = 'Giriş başarısız';
        if (e is PlatformException) {
          msg = '${e.message ?? e.code}';
          if (e.code != null && e.code!.isNotEmpty) msg = '${e.code}: $msg';
        } else if (e.toString().contains('ApiException') || e.toString().contains('sign_in_failed')) {
          msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        } else {
          msg = e.toString();
        }
        _showError(msg);
      }
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
    ToastUtils.showInfo(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isAnonymousLoading || _isGoogleLoading || _isAppleLoading,
      message: 'Partiye giriş yapılıyor...',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
          children: [
            // Animasyonlu Parti Işıklandırması
            const Positioned.fill(
              child: AnimatedMeshBackground(),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
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
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        SocialRiskLogo(height: 180),
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
            style: GoogleFonts.nunito(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Oyuncu Adınız...',
              hintStyle: GoogleFonts.nunito(
                color: Colors.white38,
                fontWeight: FontWeight.w600,
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
          Stack(
            children: [
              StageButton(
                label: 'Partiye Katıl!',
                icon: Icons.local_fire_department_rounded,
                backgroundColor: AppColors.primary,
                textColor: AppColors.background,
                borderColor: Colors.transparent,
                onPressed: _signInAnonymously,
                isLoading: _isAnonymousLoading,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showFlare ? 0.6 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '* Anonim olarak devam edeceksiniz. İstatistikleriniz bu cihaza kaydedilir.',
            style: GoogleFonts.nunito(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
                style: GoogleFonts.nunito(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
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
                label: 'Google ile Devam Et',
                icon: Icons.g_mobiledata_rounded,
                backgroundColor: AppColors.surfaceElevated,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                onPressed: () => _signInSocial(_signInWithGoogle, 'google'),
                isLoading: _isGoogleLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
