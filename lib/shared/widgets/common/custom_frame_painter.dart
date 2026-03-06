import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';

class CustomFramePainter extends CustomPainter {
  final String frameId;
  final double radius;

  CustomFramePainter({
    required this.frameId,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = radius + 4; // Çizimi avatarın biraz daha dışına al

    // Canvas'ı döndür: 0 açısı tam alt nokta olsun (pi/2)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 2);

    switch (frameId) {
      case 'frame_fire':
        _paintFire(canvas, r);
        break;
      case 'frame_ice':
        _paintIce(canvas, r);
        break;
      case 'frame_flower':
        _paintFlower(canvas, r);
        break;
      case 'frame_shield':
        _paintShield(canvas, r);
        break;
      case 'frame_ivy':
        _paintIvy(canvas, r);
        break;
      case 'frame_neon':
        _paintNeon(canvas, r);
        break;
      case 'frame_stars':
        _paintStars(canvas, r);
        break;
      case 'frame_lightning':
        _paintLightning(canvas, r);
        break;
    }
    
    canvas.restore();
  }

  void _paintFire(Canvas canvas, double r) {
    // Alttan çıkan güçlü alev efekti
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final paintObj = Paint()..style = PaintingStyle.fill;
    
    List<Color> colors = [Colors.redAccent.shade400.withOpacity(0.8), Colors.orangeAccent, Colors.yellowAccent];
    List<double> offsets = [14.0, 9.0, 5.0];
    
    // Alt taban için ekstra kırmızı parlama
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r + 6), -math.pi * 0.4, math.pi * 0.8, false, 
        Paint()..color=Colors.red.withOpacity(0.6)..style=PaintingStyle.stroke..strokeWidth=8..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10));

    for (int k = 0; k < 3; k++) {
      paintObj.color = colors[k];
      glowPaint.color = colors[k].withOpacity(0.5);
      
      final flamePath = Path();
      
      for (double angle = -math.pi * 0.9; angle <= math.pi * 0.9; angle += 0.05) {
        double intensity = math.cos(angle * 1.1);
        if (intensity < 0) intensity = 0;
        
        double wobble = math.sin(angle * 12 + k * 8) * 5 * intensity;
        double currentR = r + (offsets[k] + wobble) * intensity;
        
        double x = currentR * math.cos(angle);
        double y = currentR * math.sin(angle);
        
        if (angle == -math.pi * 0.9) flamePath.moveTo(x, y);
        else flamePath.lineTo(x, y);
      }
      
      for (double angle = math.pi * 0.9; angle >= -math.pi * 0.9; angle -= 0.05) {
        double innerR = r - 2;
        flamePath.lineTo(innerR * math.cos(angle), innerR * math.sin(angle));
      }
      flamePath.close();
      
      if (k == 0) canvas.drawPath(flamePath, glowPaint); // Dıştaki katman için ekstra glow
      canvas.drawPath(flamePath, paintObj);
    }
  }

  void _paintIce(Canvas canvas, double r) {
    final glow = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final paintObj = Paint()
      ..color = Colors.lightBlue.shade100
      ..style = PaintingStyle.fill;
    
    final path = Path();
    int crystals = 16;
    for (int i = 0; i < crystals; i++) {
        double angle = -math.pi + (i * 2 * math.pi / crystals);
        double nextAngle = -math.pi + ((i+1) * 2 * math.pi / crystals);
        
        path.moveTo((r-2) * math.cos(angle), (r-2) * math.sin(angle));
        
        double midAngle = (angle + nextAngle) / 2;
        // Daha büyük sivri üçgenler
        double pointyR = r + 8 + ((i % 2 == 0) ? 8 : 3);
        path.lineTo(pointyR * math.cos(midAngle), pointyR * math.sin(midAngle));
        path.lineTo((r-2) * math.cos(nextAngle), (r-2) * math.sin(nextAngle));
    }
    
    canvas.drawCircle(Offset.zero, r, glow);
    canvas.drawCircle(Offset.zero, r, Paint()..color = Colors.cyanAccent.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawPath(path, paintObj);
    canvas.drawPath(path, Paint()..color=Colors.white.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=1.5);
  }

  void _paintFlower(Canvas canvas, double r) {
    // Daha kalın, gölgeli sarmaşık
    final vineGlow = Paint()..color=Colors.lightGreenAccent.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=6..maskFilter=const MaskFilter.blur(BlurStyle.normal, 4);
    final vinePaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    for (double angle = -math.pi * 0.95; angle <= math.pi * 0.95; angle += 0.1) {
        double wobble = math.sin(angle * 10) * 3.5;
        double currentR = r + wobble;
        double x = currentR * math.cos(angle);
        double y = currentR * math.sin(angle);
        if (angle == -math.pi * 0.95) path.moveTo(x, y);
        else path.lineTo(x, y);
    }
    canvas.drawPath(path, vineGlow);
    canvas.drawPath(path, vinePaint);

    List<double> angles = [0, math.pi*0.25, -math.pi*0.25, math.pi*0.55, -math.pi*0.55, math.pi*0.85, -math.pi*0.85];
    
    for (double angle in angles) {
      double flowerR = r + ((angle.abs() < 0.5) ? 4 : 2);
      double x = flowerR * math.cos(angle);
      double y = flowerR * math.sin(angle);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      
      final petalGlow = Paint()..color=Colors.pink.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3);
      final petalPaint = Paint()..color = Colors.pinkAccent.shade100;
      
      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.rotate(i * 2 * math.pi / 5);
        final rect = Rect.fromCenter(center: const Offset(0, 6), width: 7, height: 10);
        canvas.drawOval(rect, petalGlow);
        canvas.drawOval(rect, petalPaint);
        // Taç yaprak içi ince çizgi
        canvas.drawLine(const Offset(0, 3), const Offset(0, 9), Paint()..color=Colors.pink..strokeWidth=1);
        canvas.restore();
      }
      canvas.drawCircle(Offset.zero, 5, Paint()..color = Colors.orangeAccent);
      canvas.drawCircle(Offset.zero, 3, Paint()..color = Colors.yellow);
      canvas.restore();
    }
  }

  void _paintShield(Canvas canvas, double r) {
    // Holografik aydınlatma
    final hexGlow = Paint()
      ..color = Colors.indigoAccent.shade100.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final hexPaint = Paint()
      ..color = Colors.blueAccent.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    int sides = 6; // Altıgen daha teknolojik duruyor
    final path = Path();
    for (int i = 0; i <= sides; i++) {
        double angle = i * 2 * math.pi / sides;
        angle += math.pi / sides;
        double currentR = r + 6;
        double x = currentR * math.cos(angle);
        double y = currentR * math.sin(angle);
        if (i == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
    }
    canvas.drawPath(path, hexGlow);
    canvas.drawPath(path, hexPaint);
    
    // Güçlü bağlantı noktaları (nodüller)
    for (int i = 0; i <= sides; i++) {
        double angle = i * 2 * math.pi / sides + (math.pi / sides);
        double x = (r + 6) * math.cos(angle);
        double y = (r + 6) * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.cyan..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
    
    // İç katman
    canvas.drawCircle(Offset.zero, r-1, Paint()..color = Colors.indigoAccent.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  void _paintIvy(Canvas canvas, double r) {
    // 3 kalın sarmaşık dalı
    final vineGlow = Paint()..color=Colors.greenAccent.withOpacity(0.4)..style=PaintingStyle.stroke..strokeWidth=6..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3);
    final vinePaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    final leafPaint = Paint()
      ..color = Colors.lightGreenAccent.shade400
      ..style = PaintingStyle.fill;
    final leafBorder = Paint()..color=Colors.green.shade900..style=PaintingStyle.stroke..strokeWidth=1;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      for (double angle = -math.pi * 0.95; angle <= math.pi * 0.95; angle += 0.1) {
        double offset = math.sin(angle * 5 + i * 2) * 5;
        double currentR = r + 2 + offset;
        double x = currentR * math.cos(angle);
        double y = currentR * math.sin(angle);
        
        if (angle == -math.pi * 0.95) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      canvas.drawPath(path, vineGlow);
      canvas.drawPath(path, vinePaint);
    }

    // Dolgun yapraklar
    for (double angle = -math.pi * 0.9; angle <= math.pi * 0.9; angle += math.pi / 6) {
      double leafX = (r + 7) * math.cos(angle);
      double leafY = (r + 7) * math.sin(angle);
      
      canvas.save();
      canvas.translate(leafX, leafY);
      canvas.rotate(angle + math.pi / 3); 
      
      final leafParam = Path();
      leafParam.moveTo(0, -9);
      leafParam.quadraticBezierTo(7, -4, 0, 9);
      leafParam.quadraticBezierTo(-7, -4, 0, -9);
      
      // Yaprak gölgesi
      canvas.drawPath(leafParam, Paint()..color=Colors.black26..maskFilter=const MaskFilter.blur(BlurStyle.normal, 2));
      canvas.drawPath(leafParam, leafPaint);
      canvas.drawPath(leafParam, leafBorder);
      // Damar
      canvas.drawLine(const Offset(0, -7), const Offset(0, 7), Paint()..color=Colors.green.shade800..strokeWidth=1.5);
      canvas.restore();
    }
  }

  void _paintNeon(Canvas canvas, double r) {
    final neonGlowPaint = Paint()
      ..color = Colors.cyanAccent.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
    final neonCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Etrafı saran güçlü neon kesikleri (6 parça)
    int segments = 6;
    double sweep = math.pi * 2 / segments * 0.6; // %60 dolu, %40 boş
    for (int i = 0; i < segments; i++) {
        double startAngle = i * math.pi * 2 / segments;
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r+2), startAngle, sweep, false, neonGlowPaint);
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r+2), startAngle, sweep, false, neonCorePaint);
    }
    
    // Zıt renk dış/iç varyasyon
    final secondaryGlow = Paint()
      ..color = Colors.pinkAccent.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final secondaryCore = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5;

    for (int i = 0; i < segments; i++) {
        double startAngle = (i * math.pi * 2 / segments) + math.pi/segments; // Offset
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r + 8), startAngle, sweep*0.8, false, secondaryGlow);
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r + 8), startAngle, sweep*0.8, false, secondaryCore);
    }
  }

  void _paintStars(Canvas canvas, double r) {
    final orbitGlow = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final orbitPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
      
    final orbitPath = Path();
    for (double angle = -math.pi; angle <= math.pi; angle += 0.1) {
      double currentR = r + math.sin(angle * 12) * 4;
      if (angle == -math.pi) orbitPath.moveTo(currentR * math.cos(angle), currentR * math.sin(angle));
      else orbitPath.lineTo(currentR * math.cos(angle), currentR * math.sin(angle));
    }
    canvas.drawPath(orbitPath, orbitGlow);
    canvas.drawPath(orbitPath, orbitPaint);
    
    final starPaint = Paint()..color = Colors.white;
    int starsCount = 8;
    for (int i = 0; i < starsCount; i++) {
      double angle = (i * 2 * math.pi / starsCount);
      double starR = r + ((i % 2 == 0) ? 7 : -3); 
      double x = starR * math.cos(angle);
      double y = starR * math.sin(angle);
      
      final starPath = Path();
      starPath.moveTo(0, -9);
      starPath.lineTo(2.5, -2.5);
      starPath.lineTo(9, 0);
      starPath.lineTo(2.5, 2.5);
      starPath.lineTo(0, 9);
      starPath.lineTo(-2.5, 2.5);
      starPath.lineTo(-9, 0);
      starPath.lineTo(-2.5, -2.5);
      starPath.close();
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + i); // Dönüş açısını biraz rastgele yap
      
      canvas.drawPath(starPath, Paint()..color = Colors.amberAccent..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFD700));
      // İç çekirdek beyaz
      canvas.scale(0.5);
      canvas.drawPath(starPath, starPaint);
      canvas.restore();
    }
  }

  void _paintLightning(Canvas canvas, double r) {
    final paintGlow = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      
    final paintOutline = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
      
    final paintCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    // Sağa ve sola ani kırılan dinamik şimşek halkası
    for (double angle = -math.pi; angle <= math.pi; angle += 0.15) {
      double jitter = (angle * 10).toInt() % 2 == 0 ? 10.0 : -4.0; 
      if ((angle * 10).toInt() % 5 == 0) jitter += 8.0;

      double currentR = r + 2 + jitter;
      double x = currentR * math.cos(angle);
      double y = currentR * math.sin(angle);
      
      if (angle == -math.pi) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paintGlow);
    canvas.drawPath(path, paintOutline);
    canvas.drawPath(path, paintCore);
    
    // Rastgele dış şimşek kolları
    for (double angle = -math.pi*0.8; angle <= math.pi*0.8; angle += math.pi/2.5) {
      final spike = Path();
      double startX = r * math.cos(angle);
      double startY = r * math.sin(angle);
      spike.moveTo(startX, startY);
      spike.lineTo((r+15)*math.cos(angle+0.1), (r+15)*math.sin(angle+0.1));
      spike.lineTo((r+22)*math.cos(angle-0.05), (r+22)*math.sin(angle-0.05));
      
      canvas.drawPath(spike, Paint()..color=Colors.blueAccent..style=PaintingStyle.stroke..strokeWidth=6..maskFilter=const MaskFilter.blur(BlurStyle.normal,3));
      canvas.drawPath(spike, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CustomFramePainter) {
      return oldDelegate.frameId != frameId || oldDelegate.radius != radius;
    }
    return true;
  }
}
