import 'package:flutter/material.dart';

/// A43: Responsive layout wrapper — telefon ve tablet uyumu.
///
/// İçeriği merkeze alır ve max genişlik kısıtlaması uygular.
/// Tablet ve geniş ekranlarda içerik 600px ile sınırlanır.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  /// Ekran genişliğine göre tablet mi telefon mu olduğunu belirle
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  /// Ekran genişliğine göre grid sütun sayısı
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}
