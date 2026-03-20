import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import 'package:social_risk/core/audio/audio_service.dart';

/// Etkilesimli buton (tiklandiginda kuculme animasyonu)
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

/// Parti Temali Buton
class StageButton extends StatelessWidget {
  const StageButton({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 52.0 : 60.0;
    final iconSize = compact ? 20.0 : 24.0;
    final fontSize = compact ? 16.0 : 18.0;
    final spacing = compact ? 8.0 : 12.0;

    return InteractiveButton(
      onTap: isLoading
          ? () {}
          : () {
              // Ortak StageButton tıklamalarında buton click SFX çal.
              try {
                ProviderScope.containerOf(
                  context,
                  listen: false,
                ).read(audioServiceProvider).playSfx(AppSfx.buttonClick);
              } catch (_) {
                // Provider bağlamı yoksa sessizce geç.
              }
              onPressed();
            },
      child: Semantics(
        button: true,
        label: label.isNotEmpty ? label : 'Buton',
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 12,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconWidget != null) iconWidget!,
                        if (icon != null) Icon(icon, color: textColor, size: iconSize),
                        if (label.isNotEmpty) ...[
                          if (icon != null || iconWidget != null)
                            SizedBox(width: spacing),
                          Flexible(
                            child: Text(
                              label,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: compact ? 0.4 : 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
