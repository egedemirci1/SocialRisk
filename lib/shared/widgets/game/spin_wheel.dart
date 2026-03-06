import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_constants.dart';

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

/// Dönen çark widget'ı. Kategori renk/ikon CategoryConstants'tan.
class SpinWheel extends StatefulWidget {
  const SpinWheel({
    super.key,
    this.spinningTarget,
    this.canSpin = true,
    this.onSpinRequest,
    required this.onSpinComplete,
    this.playerName,
    required this.categories,
  });

  final String? spinningTarget;
  final bool canSpin;
  final VoidCallback? onSpinRequest;
  final ValueChanged<String> onSpinComplete;
  final String? playerName;
  final List<String> categories;

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  List<WheelCategory> get _activeCategories {
    if (widget.categories.isEmpty) {
      return CategoryConstants.defaultCategoriesOnly
          .map((c) => WheelCategory(name: c.name, color: c.color, icon: c.icon))
          .toList();
    }
    return widget.categories
        .map((c) {
          final def = CategoryConstants.byId(c);
          if (def != null) {
            return WheelCategory(name: def.name, color: def.color, icon: def.icon);
          }
          return WheelCategory(
            name: c,
            color: AppColors.primary,
            icon: Icons.category_rounded,
          );
        })
        .toList();
  }

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

    final activeCats = _activeCategories;
    final targetIndex = activeCats.indexWhere((c) => c.name == targetCategory);
    if (targetIndex == -1) return;

    final extraTurns = 3 + _random.nextInt(3); // 3-5 tur
    final sliceAngle = 2 * pi / activeCats.length;

    // Rastgele bir sapma (dilimin içinde rastgele bir yer)
    final offset =
        (_random.nextDouble() * 0.8 + 0.1) * sliceAngle; // %10-%90 arası

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
              return Transform.rotate(angle: angle, child: child);
            },
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _WheelPainter(categories: _activeCategories),
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
            '${widget.playerName ?? 'Oyuncu'}\'nun çarkı çevirmesi bekleniyor...',
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

    // Dış halka parlaması (subtle outer glow)
    final outerGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    canvas.drawCircle(center, radius, outerGlowPaint);

    for (int i = 0; i < categories.length; i++) {
      final startAngle = i * sliceAngle - pi / 2;
      final cat = categories[i];

      // Dilim Gradient
      final slicePath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sliceAngle,
          false,
        )
        ..close();

      final sliceGradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          cat.color.withValues(alpha: 0.95),
          cat.color.withValues(alpha: 0.7),
        ],
        stops: const [0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final paint = Paint()..shader = sliceGradient;
      canvas.drawPath(slicePath, paint);

      // Dilim kenarlık (ince ve şık)
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(slicePath, borderPaint);

      // Metin ve İkon yerleşimi — yazılar dışta (geniş alan), ikonlar ortaya yakın
      final midAngle = startAngle + sliceAngle / 2;
      
      // Kategori ismi (Dışta, daha geniş alan — sığması için)
      final textRadius = radius * 0.70;
      final textX = center.dx + textRadius * cos(midAngle);
      final textY = center.dy + textRadius * sin(midAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: cat.name,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Ölçeklendirme (Overflow engelleme — dış halkada daha geniş alan)
      final maxContextWidth = radius * 0.50;
      final scale = textPainter.width > maxContextWidth 
          ? maxContextWidth / textPainter.width 
          : 1.0;

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(midAngle + pi / 2);
      canvas.scale(scale);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      // İkon (Ortaya yakın)
      final iconRadius = radius * 0.42;
      final iconX = center.dx + iconRadius * cos(midAngle);
      final iconY = center.dy + iconRadius * sin(midAngle);

      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(cat.icon.codePoint),
          style: TextStyle(
            fontSize: 22,
            fontFamily: cat.icon.fontFamily,
            package: cat.icon.fontPackage,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(iconX, iconY);
      canvas.rotate(midAngle + pi / 2);
      iconPainter.paint(
        canvas,
        Offset(-iconPainter.width / 2, -iconPainter.height / 2),
      );
      canvas.restore();
    }

    // Merkez göbek (Premium Glassmorphism / Metalic Hub)
    final hubRadius = radius * 0.22;
    
    // Hub Gölgesi
    canvas.drawCircle(
      center,
      hubRadius + 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Hub Arka Plan (Metalik Gradient)
    final hubGradient = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.9),
        Colors.white.withValues(alpha: 0.4),
        Colors.white.withValues(alpha: 0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: hubRadius));

    canvas.drawCircle(center, hubRadius, Paint()..shader = hubGradient);
    
    // Hub İç Halkası
    canvas.drawCircle(
      center,
      hubRadius * 0.7,
      Paint()
        ..color = AppColors.background.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}
