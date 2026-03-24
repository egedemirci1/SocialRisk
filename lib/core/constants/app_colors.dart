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

  // Oyun durumu renkleri (Kategorilerde de Kullanılır)
  static const fire = Color(0xFFD32F2F); // Koyu Kırmızı (Mahrem)
  static const ice = Color(0xFF0288D1); // Güçlü Mavi (Zihinsel)
  static const glow = Color(0xFFFBC02D); // Koyu Altın Sarısı (İtiraf)
  
  // Oylama renkleri (Kategorilerde de Kullanılır)
  static const votePositive = Color(0xFF059669); // Zümrüt Yeşili (Fiziksel)
  static const voteNeutral = Color(0xFFD97706); // Koyu Amber (Ahlaki)
  static const voteNegative = Color(0xFFDC2626); // Tok Kırmızı
  
  // Kategori Özel Renkleri
  static const categoryDigital = Color(0xFFC2185B); // Koyu Pembe/Mor (Dijital)
  static const categoryVisual = Color(0xFF7B1FA2); // Derin Mor (Görsel)
  static const categoryKnowledge = Color(0xFF0097A7); // Çok Koyu Turkuaz (Bilgi)
  
  // Ceza / Hata
  static const error = Color(0xFFDC2626);
  static const penalty = Color(0xFFDC2626);
  static const passWarning = Color(0xFFD97706);

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
