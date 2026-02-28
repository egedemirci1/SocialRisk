import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Tüm ekranlarda ortak kullanılacak gradient arka plan konteyneri.
///
/// Kullanım:
/// ```dart
/// GradientContainer(
///   child: Column(...),
/// )
/// ```
class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.child,
    this.padding,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Özel gradient renkleri. `null` ise varsayılan palette kullanılır.
  final List<Color>? colors;

  /// Gradient başlangıç yönü.
  final AlignmentGeometry begin;

  /// Gradient bitiş yönü.
  final AlignmentGeometry end;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ??
              const [
                AppColors.background,
                Color(0xFF111128), // background ile surface arası
                AppColors.surface,
              ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}
