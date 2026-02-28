import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Tehlike aksiyonu butonu — Pas geç, Reddet gibi durumlar için.
///
/// Kullanım:
/// ```dart
/// DangerButton(
///   label: 'Pas Geç',
///   onPressed: () => ...,
/// )
/// ```
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  /// `true` ise outlined stil (şeffaf arka plan + kırmızı border).
  /// `false` ise filled stil (kırmızı arka plan).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return Semantics(
      button: true,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled ? 0.6 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: outlined
                ? Colors.transparent
                : isDisabled
                    ? AppColors.penalty.withValues(alpha: 0.4)
                    : AppColors.penalty,
            borderRadius: BorderRadius.circular(12),
            border: outlined
                ? Border.all(
                    color: isDisabled
                        ? AppColors.penalty.withValues(alpha: 0.4)
                        : AppColors.penalty,
                    width: 1.5,
                  )
                : null,
            boxShadow: (isDisabled || outlined)
                ? null
                : [
                    BoxShadow(
                      color: AppColors.penalty.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: outlined
                  ? AppColors.penalty.withValues(alpha: 0.2)
                  : Colors.white24,
              child: SizedBox(
                width: width ?? double.infinity,
                height: 52,
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              outlined ? AppColors.penalty : Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                color: outlined
                                    ? AppColors.penalty
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              label,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: outlined
                                    ? AppColors.penalty
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
