part of 'spin_wheel.dart';

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
          style: AppTextStyles.labelSmall.copyWith(fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
            ],),
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