import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialRiskLogo extends StatelessWidget {
  final double height;
  
  const SocialRiskLogo({
    super.key, 
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minimalist Icon
        Container(
          height: height * 0.6,
          width: height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height * 0.15),
            border: Border.all(
              color: Colors.white,
              width: height * 0.05,
            ),
          ),
          child: Center(
            child: Text(
              'S',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: height * 0.35,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.1),
        Text(
          'SOCIALRISK',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: height * 0.2,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
