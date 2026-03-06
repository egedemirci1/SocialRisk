import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.penalty,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54), // Daha dolgun (52 -> 54)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Daha modern yuvarlaklık (12 -> 16)
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 18, // Bir tık daha görünür (16 -> 18)
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            elevation: 8, // Parlama/Derinlik efekti için yükselti eklendi (0 -> 8)
            shadowColor: AppColors.primary.withOpacity(0.6), // Sarımsı glow efekti
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: AppColors.primary, width: 2.0), // Kalınlaştırıldı (1.5 -> 2.0)
            textStyle: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            elevation: 0,
          ).copyWith(
            // Tıklama anında veya odaklandığında çok hafif neon parlama hissi (Ripple rengi)
            overlayColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.1)),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.inter(
              fontSize: 15, // Ufak bir büyüme
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        // Input (TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated.withOpacity(0.7), // Hafif bir iç şeffaflık (Cam değil ama hafif saydam)
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18), // Daha ferah iç boşluk
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 2.5), // Tıklayınca Camgöbeği (Cyan) parlayan dış çizgi
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.penalty, width: 2.0),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white38,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: Colors.white12,
          thickness: 1,
          space: 1,
        ),

        // ProgressIndicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.surfaceElevated,
        ),
      );
}
