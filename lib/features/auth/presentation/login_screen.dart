import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../providers/auth_provider.dart';

/// Login ekranı — Google, Apple ve Anonim giriş seçenekleri.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 800),
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
      _showError('Lütfen bir isim gir');
      return;
    }
    setState(() => _isAnonymousLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signIn(name);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isAnonymousLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      // Google Sign-In — MVP kapsamı dışında, yakında eklenecek
      _showError('Google girişi yakında!');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);
    try {
      // Apple Sign-In — MVP kapsamı dışında, yakında eklenecek
      _showError('Apple girişi yakında!');
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo / Başlık
                _buildHeader(),

                const Spacer(),

                // Anonim Giriş Bölümü
                _buildAnonymousSection(),

                const SizedBox(height: 24),

                // Ayırıcı
                _buildDivider(),

                const SizedBox(height: 24),

                // Sosyal Giriş Butonları
                _buildSocialButtons(),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Oyun ikonu
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: Text(
                '🎮',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sosyal Risk',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Arkadaşlarınla oyna, risk al!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hızlı Giriş',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white38,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            hintText: 'İsmini yaz...',
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: Colors.white38,
            ),
          ),
          onSubmitted: (_) => _signInAnonymously(),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Anonim Giriş Yap',
          icon: Icons.rocket_launch_rounded,
          onPressed: _signInAnonymously,
          isLoading: _isAnonymousLoading,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white38,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google
        _SocialLoginButton(
          label: 'Google ile Giriş Yap',
          iconPath: 'G',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          onPressed: _signInWithGoogle,
          isLoading: _isGoogleLoading,
        ),
        const SizedBox(height: 12),
        // Apple
        _SocialLoginButton(
          label: 'Apple ile Giriş Yap',
          iconPath: '',
          backgroundColor: Colors.white10,
          textColor: Colors.white,
          onPressed: _signInWithApple,
          isLoading: _isAppleLoading,
        ),
      ],
    );
  }
}

/// Sosyal giriş butonu (Google, Apple vb.)
class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.iconPath,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final String iconPath;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 52,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (iconPath == 'G') ...[
                          Text(
                            'G',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4285F4),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else ...[
                          Icon(Icons.apple_rounded,
                              color: textColor, size: 24),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
