import 'package:flutter/material.dart';

class AppColors {
  // Arka plan (Derin İndigo / Gece Mavisi)
  static const background = Color(0xFF16103A); // Koyu İndigo
  static const surface = Color(0xFF231D4D); // Kartlar için biraz daha açık İndigo
  static const surfaceElevated = Color(0xFF332A6B); // Yüksek surface

  // Vurgu (Mango Sarısı ve Genç Cyan)
  static const primary = Color(0xFFFFB020); // Eğlenceli Mango Sarısı
  static const secondary = Color(0xFF14B8A6); // Temiz Turkuaz/Teal
  static const accent = Color(0xFF06B6D4); // Parlak Camgöbeği (Cyan)

  // Oyun durumu renkleri
  static const fire = Color(0xFFFF5252); // Enerjik Kırmızı
  static const ice = Color(0xFF4DD0E1); // Ferah Mavi
  static const glow = Color(0xFFFFF176); // Glow Sarısı

  // Oylama renkleri
  static const votePositive = Color(0xFF10B981); // Zümrüt Yeşili
  static const voteNeutral = Color(0xFFF59E0B); // Amber
  static const voteNegative = Color(0xFFEF4444); // Tok Kırmızı

  // Ceza / Hata
  static const error = Color(0xFFEF4444);
  static const penalty = Color(0xFFEF4444);
  static const passWarning = Color(0xFFF59E0B);

  // Modern Gradyanlar (Aksiyonlar İçin)
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB020), // Mango Yellow
      Color(0xFFF59E0B), // Deep Amber
    ],
  );

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF231D4D), // Surface
      Color(0xFF16103A), // Background
    ],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22D3EE), // Bright Cyan
      Color(0xFF06B6D4), // Cyan
      Color(0xFF0891B2), // Deep Cyan
    ],
  );
}
