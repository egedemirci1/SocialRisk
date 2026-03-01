import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Kategori bilgisi — çark dilimi için renk, ikon ve isim.
class WheelCategory {
  final String name;
  final Color color;
  final IconData icon;

  const WheelCategory({
    required this.name,
    required this.color,
    required this.icon,
  });
}

/// 6 kategorili dönen çark widget'ı.
/// [onResult] callback'i çark durduğunda seçilen kategoriyi döndürür.
class SpinWheel extends StatefulWidget {
  const SpinWheel({
    super.key,
    this.spinningTarget,
    this.canSpin = true,
    this.onSpinRequest,
    required this.onSpinComplete,
  });

  final String? spinningTarget;
  final bool canSpin;
  final VoidCallback? onSpinRequest;
  final ValueChanged<String> onSpinComplete;

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  static const _categories = [
    WheelCategory(
      name: 'Cesaret',
      color: AppColors.fire,
      icon: Icons.local_fire_department_rounded,
    ),
    WheelCategory(
      name: 'İtiraf',
      color: AppColors.glow,
      icon: Icons.psychology_rounded,
    ),
    WheelCategory(
      name: 'Taklit',
      color: AppColors.ice,
      icon: Icons.theater_comedy_rounded,
    ),
    WheelCategory(
      name: 'Sosyal Medya',
      color: AppColors.primary,
      icon: Icons.phone_android_rounded,
    ),
    WheelCategory(
      name: 'Fiziksel',
      color: AppColors.votePositive,
      icon: Icons.fitness_center_rounded,
    ),
    WheelCategory(
      name: 'Bilgi',
      color: AppColors.accent,
      icon: Icons.lightbulb_outline_rounded,
    ),
  ];

  late final AnimationController _controller;
  late Animation<double> _animation;

  final _random = Random();
  bool _isSpinning = false;
  bool _hasResult = false;
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _animation = AlwaysStoppedAnimation(_currentAngle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpinWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinningTarget != oldWidget.spinningTarget &&
        widget.spinningTarget != null) {
      _spinTo(widget.spinningTarget!);
    }
  }

  void _spinTo(String targetCategory) {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _hasResult = false;
    });

    final targetIndex = _categories.indexWhere((c) => c.name == targetCategory);
    if (targetIndex == -1) return;

    final extraTurns = 3 + _random.nextInt(3); // 3-5 tur
    final sliceAngle = 2 * pi / _categories.length;
    
    // Rastgele bir sapma (dilimin içinde rastgele bir yer)
    final offset = (_random.nextDouble() * 0.8 + 0.1) * sliceAngle; // %10-%90 arası
    
    // Hedef açı (Ok her zaman en üstte yani 3π/2 (270 derece))
    // Formül: (Hedef index * sliceAngle) + offset açısı saat yönünün TERSİNE (çünkü çark saat yönünde dönüyor)
    final targetBaseAngle = (2 * pi) - (targetIndex * sliceAngle) - offset;
    
    final currentMod = _currentAngle % (2 * pi);
    double distance = targetBaseAngle - currentMod;
    if (distance <= 0) distance += 2 * pi;

    final totalAngle = (extraTurns * 2 * pi) + distance;

    _animation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + totalAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.reset();
    _controller.forward().then((_) {
      _currentAngle = _animation.value;
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _hasResult = true;
        });
        widget.onSpinComplete(targetCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pointer oku (üstte)
        const Icon(
          Icons.arrow_drop_down_rounded,
          color: Colors.white,
          size: 48,
        ),

        // Çark
        SizedBox(
          width: 280,
          height: 280,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _animation.isCompleted || !_isSpinning
                  ? _currentAngle
                  : _animation.value;
              return Transform.rotate(
                angle: angle,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _WheelPainter(categories: _categories),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Çevir butonu
        if (!_hasResult && widget.canSpin)
          GestureDetector(
            onTap: _isSpinning ? null : widget.onSpinRequest,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: _isSpinning
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.fire],
                      ),
                color: _isSpinning ? AppColors.surfaceElevated : null,
                borderRadius: BorderRadius.circular(30),
                boxShadow: _isSpinning
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSpinning
                        ? Icons.hourglass_top_rounded
                        : Icons.casino_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSpinning ? 'Dönüyor...' : 'Çarkı Çevir!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (!_hasResult && !widget.canSpin && _isSpinning)
          Text(
            'Çark dönüyor...',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          )
        else if (!_hasResult && !widget.canSpin)
          Text(
            'Host\'un çarkı çevirmesi bekleniyor...',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
      ],
    );
  }
}

/// AnimatedBuilder — AnimatedWidget ile aynı, kısa yol.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}

/// CustomPainter — 6 dilimli çark çizer.
class _WheelPainter extends CustomPainter {
  final List<WheelCategory> categories;

  _WheelPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = 2 * pi / categories.length;

    for (int i = 0; i < categories.length; i++) {
      final startAngle = i * sliceAngle - pi / 2; // -π/2 to start from top
      final cat = categories[i];

      // Dilim
      final paint = Paint()
        ..color = cat.color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );

      // Dilim kenarlık
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Kategori ismi — dilimin ortasına
      final midAngle = startAngle + sliceAngle / 2;
      final textRadius = radius * 0.62;
      final textX = center.dx + textRadius * cos(midAngle);
      final textY = center.dy + textRadius * sin(midAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: cat.name,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(midAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Merkez daire
    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()..color = AppColors.surfaceElevated,
    );
    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}
