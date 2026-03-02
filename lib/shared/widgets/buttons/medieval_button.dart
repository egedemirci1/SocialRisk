import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Etkileşimli buton (tıklandığında küçülme animasyonu)
class InteractiveButton extends StatefulWidget {
  const InteractiveButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Orta Çağ Temalı Etkileşimli Buton (Ortak Kullanım)
class MedievalButton extends StatelessWidget {
  const MedievalButton({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InteractiveButton(
      onTap: isLoading ? () {} : onPressed,
      child: Semantics(
        button: true,
        label: label.isNotEmpty ? label : 'Button',
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconWidget != null) iconWidget!,
                      if (icon != null) Icon(icon, color: textColor, size: 28),
                      if (label.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: GoogleFonts.cinzel(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
