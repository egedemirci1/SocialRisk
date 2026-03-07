import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
  );
  static final displayMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static final headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static final titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static final titleMedium = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final titleSmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final bodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static final labelSmall = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  // Special style for Medieval/Fantasy headers (Replacing Cinzel)
  static final specialHeading = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
  );
}
