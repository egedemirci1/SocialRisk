import 'package:flutter/material.dart';

class AppColors {
  // Arka plan (Modern Kahverengi / Derin Çikolata)
  static const background = Color(0xFF0F0805); // Daha kahverengi bir siyah
  static const surface = Color(0xFF1F0E0A);
  static const surfaceElevated = Color(0xFF2D1612);

  // Vurgu (Mat Altın / Amber)
  static const primary = Color(0xFF8B2500); // Daha sıcak bir "Burnt Orange/Red"
  static const secondary = Color(0xFF4A1404);
  static const accent = Color(0xFFE5B137); // Daha canlı bir Altın

  // Oyun durumu renkleri
  static const fire = Color(0xFFFF4500);
  static const ice = Color(0xFFAEC6CF);
  static const glow = Color(0xFFFFFDD1);

  // Oylama renkleri
  static const votePositive = Color(0xFF4CAF50);
  static const voteNeutral = Color(0xFFFF9800);
  static const voteNegative = Color(0xFFF44336);

  // Ceza / Hata
  static const error = Color(0xFFE53935);
  static const penalty = Color(0xFFE53935);
  static const passWarning = Color(0xFFFFC107);

  // Modern Gradyanlar
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B2500), // Burnt Red / Mahogany
      Color(0xFF5A1000), // Deep Brown/Red
    ],
  );

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D1612), // Deep Mahogany
      Color(0xFF1F0E0A), // Dark Chocolate
    ],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD740), // Bright Gold
      Color(0xFFE5B137), // Golden
      Color(0xFFA67C00), // Dark Gold
    ],
  );
}
