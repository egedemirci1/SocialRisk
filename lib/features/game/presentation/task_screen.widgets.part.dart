part of 'task_screen.dart';

class _AnimatedPassButton extends StatefulWidget {
  const _AnimatedPassButton({
    required this.passStreak,
    required this.isPassing,
    required this.onPass,
    required this.compact,
  });

  final int passStreak;
  final bool isPassing;
  final VoidCallback onPass;
  final bool compact;

  @override
  State<_AnimatedPassButton> createState() => _AnimatedPassButtonState();
}

class _AnimatedPassButtonState extends State<_AnimatedPassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;
  bool _isWarningSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isPassing) return;
    if (!_isWarningSelected) {
      HapticFeedback.mediumImpact();
      setState(() => _isWarningSelected = true);
      _controller.forward(from: 0.0);
    } else {
      HapticFeedback.heavyImpact();
      widget.onPass();
      setState(() => _isWarningSelected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: widget.isPassing ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: _isWarningSelected
                ? AppColors.error
                : AppColors.error.withValues(alpha: 0.7),
            side: BorderSide(
              color: _isWarningSelected ? AppColors.error : Colors.white24,
              width: _isWarningSelected ? 2 : 1,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 12 : 24,
              vertical: widget.compact ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isWarningSelected
                ? AppLocalizations.of(context)!.areYouSurePoint
                : AppLocalizations.of(context)!.rejectTaskPoint,
            style: AppTextStyles.labelSmall.copyWith(
              color: _isWarningSelected ? AppColors.error : Colors.white70,
              fontWeight: FontWeight.w900,
              fontSize: widget.compact ? 10 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _TaskLayoutMetrics {
  const _TaskLayoutMetrics({
    required this.isCompact,
    required this.horizontalPadding,
    required this.contentWidth,
    required this.wheelViewHeight,
    required this.taskViewHeight,
    required this.topSpacing,
    required this.wheelGap,
    required this.sectionGap,
    required this.bottomSpacing,
    required this.spectatorTopSpacing,
    required this.titleCardHorizontalPadding,
    required this.titleCardVerticalPadding,
    required this.titleCardBottomPadding,
    required this.titleCardRadius,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.badgeFontSize,
    required this.titleGap,
    required this.titleFontSize,
    required this.subtitleGap,
    required this.subtitleFontSize,
    required this.headerVerticalPadding,
    required this.taskCardPadding,
    required this.categoryBadgeHorizontalPadding,
    required this.categoryBadgeVerticalPadding,
    required this.buttonGap,
    required this.passButtonGap,
    required this.wheelSize,
    required this.spectatorAreaHeight,
    required this.gameCardHeight,
  });

  final bool isCompact;
  final double horizontalPadding;
  final double contentWidth;
  final double wheelViewHeight;
  final double taskViewHeight;
  final double topSpacing;
  final double wheelGap;
  final double sectionGap;
  final double bottomSpacing;
  final double spectatorTopSpacing;
  final double titleCardHorizontalPadding;
  final double titleCardVerticalPadding;
  final double titleCardBottomPadding;
  final double titleCardRadius;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double badgeFontSize;
  final double titleGap;
  final double titleFontSize;
  final double subtitleGap;
  final double subtitleFontSize;
  final double headerVerticalPadding;
  final double taskCardPadding;
  final double categoryBadgeHorizontalPadding;
  final double categoryBadgeVerticalPadding;
  final double buttonGap;
  final double passButtonGap;
  final double wheelSize;
  final double spectatorAreaHeight;
  final double gameCardHeight;

  factory _TaskLayoutMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 400 || size.height < 700;
    final isShort = size.height < 720;

    return _TaskLayoutMetrics(
      isCompact: isCompact,
      horizontalPadding: isCompact ? 14 : 24,
      contentWidth: isCompact ? 340 : 380,
      wheelViewHeight: isShort ? 590 : (isCompact ? 640 : 700),
      taskViewHeight: isShort ? 660 : (isCompact ? 710 : 790),
      topSpacing: isShort ? 10 : (isCompact ? 14 : 24),
      wheelGap: isShort ? 18 : (isCompact ? 24 : 44),
      sectionGap: isShort ? 10 : (isCompact ? 14 : 26),
      bottomSpacing: isShort ? 8 : (isCompact ? 12 : 24),
      spectatorTopSpacing: isShort ? 4 : 8,
      titleCardHorizontalPadding: isShort ? 14 : (isCompact ? 18 : 22),
      titleCardVerticalPadding: isShort ? 14 : (isCompact ? 18 : 22),
      titleCardBottomPadding: isShort ? 12 : (isCompact ? 16 : 20),
      titleCardRadius: isCompact ? 18 : 20,
      badgeHorizontalPadding: isShort ? 10 : (isCompact ? 12 : 14),
      badgeVerticalPadding: isShort ? 5 : (isCompact ? 6 : 7),
      badgeFontSize: isShort ? 9 : (isCompact ? 10 : 12),
      titleGap: isShort ? 8 : (isCompact ? 12 : 16),
      titleFontSize: isShort ? 16 : (isCompact ? 18 : 20),
      subtitleGap: isShort ? 6 : (isCompact ? 8 : 10),
      subtitleFontSize: isShort ? 11.5 : (isCompact ? 13 : 14),
      headerVerticalPadding: isShort ? 10 : (isCompact ? 12 : 16),
      taskCardPadding: isShort ? 16 : (isCompact ? 18 : 24),
      categoryBadgeHorizontalPadding: isShort ? 10 : (isCompact ? 12 : 16),
      categoryBadgeVerticalPadding: isShort ? 5 : (isCompact ? 6 : 8),
      buttonGap: isShort ? 16 : (isCompact ? 20 : 32),
      passButtonGap: isShort ? 8 : (isCompact ? 10 : 12),
      wheelSize: isShort ? 260 : (isCompact ? 270 : 280),
      spectatorAreaHeight: isShort ? 78 : (isCompact ? 90 : 110),
      gameCardHeight: (size.height * (isShort ? 0.36 : 0.34))
          .clamp(220.0, isCompact ? 290.0 : 340.0)
          .toDouble(),
    );
  }
}



