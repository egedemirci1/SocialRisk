import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Tehlike aksiyonu butonu — Pas geç, Reddet gibi durumlar için. Haptic & Scale animeli.
class DangerButton extends StatefulWidget {
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
  final bool outlined;

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDisabled ? 0.6 : 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.outlined
                    ? Colors.transparent
                    : isDisabled
                        ? AppColors.penalty.withValues(alpha: 0.4)
                        : AppColors.penalty,
                borderRadius: BorderRadius.circular(12),
                border: widget.outlined
                    ? Border.all(
                        color: isDisabled
                            ? AppColors.penalty.withValues(alpha: 0.4)
                            : AppColors.penalty,
                        width: 1.5,
                      )
                    : null,
                boxShadow: (isDisabled || widget.outlined)
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.penalty.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: SizedBox(
                width: widget.width ?? double.infinity,
                height: 52,
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.outlined ? AppColors.penalty : Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.outlined
                                    ? AppColors.penalty
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: AppTextStyles.titleMedium.copyWith(fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.outlined
                                    ? AppColors.penalty
                                    : Colors.white,),
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
