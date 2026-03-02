import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Login ekranı — Orta Çağ / Fantastik Tema
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

  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _breathingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
    _breathingController.repeat(reverse: true);
  }

  Future<void> _initVideoPlayer() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/ana-menu-arkaplan.mp4',
    );

    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0); // Mute
      await _videoController.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Video initialization error: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _breathingController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Lütfen bir isim nakşet');
      return;
    }
    setState(() => _isAnonymousLoading = true);
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      await cred.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? 'Firebase hatası: ${e.code}');
      }
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isAnonymousLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final provider = GoogleAuthProvider();
      provider.addScope('email');

      final cred = await FirebaseAuth.instance.signInWithPopup(provider);

      if (cred.user != null && cred.user!.displayName == null) {
        await cred.user!.updateDisplayName('Oyuncu');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? 'Google giriş hatası: ${e.code}');
      }
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);
    try {
      final provider = OAuthProvider('apple.com');
      provider.addScope('email');
      provider.addScope('name');

      final cred = await FirebaseAuth.instance.signInWithPopup(provider);

      if (cred.user != null && cred.user!.displayName == null) {
        await cred.user!.updateDisplayName('Oyuncu');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? 'Apple giriş hatası: ${e.code}');
      }
    } catch (e) {
      if (mounted) _showError('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C1616),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Orta çağ renk paleti
    const overlayColor = Color(0xFF140D0B); // Koyu kahve/siyah tonu

    return Scaffold(
      backgroundColor: overlayColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Gradient (Fallback)
          const GradientContainer(child: SizedBox.shrink()),

          // 2. Video Background
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // 3. Dark Overlay (Taverna atmosferi için karartma)
          Container(color: overlayColor.withOpacity(0.5)),

          // 4. Foreground Content with Glassmorphism
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Başlık ve Arkasındaki Glow
                      _buildHeader(),
                      const SizedBox(height: 56),

                      // Glassmorphic Login Card (Orta Çağ / Parşömen hissiyatı)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C1E16).withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 40,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAnonymousSection(),
                                const SizedBox(height: 24),
                                _buildDivider(),
                                const SizedBox(height: 24),
                                _buildSocialButtons(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _breathingAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sosyal Risk Yazısının Arkasındaki Glow Efekti (Büyüyüp Küçülen)
              Container(
                width: 250,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(
                        0.4 - (_breathingAnimation.value.abs() * 0.02),
                      ),
                      blurRadius: 70,
                      spreadRadius: 20,
                    ),
                    BoxShadow(
                      color: const Color(0xFF8B0000).withOpacity(0.35),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
              // Başlık ve Alt Başlık
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sosyal Risk',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 48,
                      color: const Color(0xFFFDEFC2), // Soluk altın/parşömen
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
                  const SizedBox(height: 8),
                  Text(
                    'Risk Al ve Kazan!',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      color: const Color(0xFFD4AF37), // Altın rengi
                      letterSpacing: 1.0,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnonymousSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Maceraya Atıl',
          style: GoogleFonts.cinzel(
            fontSize: 14,
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.cinzel(
            fontSize: 18,
            color: const Color(0xFFFDEFC2),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'İsminizi Nakşedin...',
            hintStyle: GoogleFonts.cinzel(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
            ),
            counterText: '', // Hide the counter to keep UI clean
            prefixIcon: Icon(
              Icons.history_edu_rounded, // Orta çağ tüy kalem hissi
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onSubmitted: (_) => _signInAnonymously(),
        ),
        const SizedBox(height: 20),
        _MedievalLoginButton(
          label: 'Hancı Olarak Gir',
          icon: Icons.shield_rounded,
          backgroundColor: const Color(0xFF5C1616), // Dark Crimson
          textColor: const Color(0xFFFDEFC2),
          borderColor: const Color(0xFFD4AF37).withOpacity(0.6),
          onPressed: _signInAnonymously,
          isLoading: _isAnonymousLoading,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFD4AF37).withOpacity(0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        Expanded(
          child: _MedievalLoginButton(
            label: '', // Sadece ikon
            iconWidget: Text(
              'G',
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD4AF37),
              ),
            ),
            backgroundColor: const Color(0xFF1E140F),
            textColor: const Color(0xFFD4AF37),
            borderColor: const Color(0xFFD4AF37).withOpacity(0.4),
            onPressed: _signInWithGoogle,
            isLoading: _isGoogleLoading,
          ),
        ),
        const SizedBox(width: 16),
        // Apple
        Expanded(
          child: _MedievalLoginButton(
            label: '', // Sadece ikon
            icon: Icons.apple_rounded,
            backgroundColor: const Color(0xFF1E140F),
            textColor: const Color(0xFFD4AF37),
            borderColor: const Color(0xFFD4AF37).withOpacity(0.4),
            onPressed: _signInWithApple,
            isLoading: _isAppleLoading,
          ),
        ),
      ],
    );
  }
}

/// Etkileşimli buton (tıklandığında küçülme animasyonu)
class _InteractiveButton extends StatefulWidget {
  const _InteractiveButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Orta Çağ Temalı Etkileşimli Buton
class _MedievalLoginButton extends StatelessWidget {
  const _MedievalLoginButton({
    required this.label,
    this.icon,
    this.iconWidget,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _InteractiveButton(
      onTap: isLoading ? () {} : onPressed,
      child: Semantics(
        button: true,
        label: label,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                      if (iconWidget != null) iconWidget!,
                      if (icon != null) Icon(icon, color: textColor, size: 28),
                      if (label.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: GoogleFonts.cinzel(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
