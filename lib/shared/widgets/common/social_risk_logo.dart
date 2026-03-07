import 'package:flutter/material.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

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
            child: Text(
              'S',
              style: AppTextStyles.specialHeading.copyWith(
                color: Colors.white,
                fontSize: height * 0.35,
                height: 1.1,
              ),
            ),
        ),
        SizedBox(height: height * 0.1),
        Text(
          'SOCIALRISK',
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white,
            fontSize: height * 0.2,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            height: 1.0,),
        ),
      ],
    );
  }
}
