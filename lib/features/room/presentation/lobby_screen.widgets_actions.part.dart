part of 'lobby_screen.dart';

class _ReadyToggleButton extends ConsumerWidget {
  const _ReadyToggleButton({required this.roomCode, required this.playerId});

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final me = (playersAsync.value ?? []).where((p) => p.id == playerId).firstOrNull;
    final isReady = me?.isReady ?? false;

    final compact = MediaQuery.sizeOf(context).width < 390;

    return StageButton(
      label: isReady
          ? AppLocalizations.of(context)!.readyForParty
          : AppLocalizations.of(context)!.notReadyYet,
      icon: isReady ? Icons.close_rounded : Icons.check_circle_outline_rounded,
      backgroundColor: isReady ? AppColors.error : AppColors.primary,
      textColor: Colors.white,
      borderColor: isReady
          ? AppColors.error.withValues(alpha: 0.5)
          : AppColors.accent.withValues(alpha: 0.5),
      onPressed: () => ref.read(roomControllerProvider.notifier).toggleReady(
            roomCode: roomCode,
            playerId: playerId,
            isReady: !isReady,
          ),
      compact: compact,
    );
  }
}

class _RotatingTooltips extends StatefulWidget {
  const _RotatingTooltips({required this.compact});

  final bool compact;

  @override
  State<_RotatingTooltips> createState() => _RotatingTooltipsState();
}

class _RotatingTooltipsState extends State<_RotatingTooltips> {
  int _currentIndex = 0;
  late final Timer _timer;
  List<String> get _tips => [
    AppLocalizations.of(context)!.lobbyTip1,
    AppLocalizations.of(context)!.lobbyTip2,
    AppLocalizations.of(context)!.lobbyTip3,
    AppLocalizations.of(context)!.lobbyTip4,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _tips.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(_currentIndex),
        padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 16, vertical: widget.compact ? 6 : 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MediaQuery.sizeOf(context).width < 390 ? 14 : 16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Text(
          _tips[_currentIndex],
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.accent,
            fontSize: widget.compact ? 11 : 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AnimatedHostStartButton extends StatefulWidget {
  final bool isReady;
  final VoidCallback onPressed;

  const _AnimatedHostStartButton({
    required this.isReady,
    required this.onPressed,
  });

  @override
  State<_AnimatedHostStartButton> createState() => _AnimatedHostStartButtonState();
}

class _AnimatedHostStartButtonState extends State<_AnimatedHostStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
    ]).animate(_controller);

    if (widget.isReady) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedHostStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      _controller.repeat();
    } else if (!widget.isReady && oldWidget.isReady) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isReady) {
      final compact = MediaQuery.sizeOf(context).width < 390;

      return StageButton(
        label: AppLocalizations.of(context)!.startGame,
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.surface,
        textColor: Colors.white30,
        borderColor: Colors.white10,
        onPressed: null,
        compact: compact,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.sizeOf(context).width < 390 ? 14 : 16),
            ),
            child: child,
          ),
        );
      },
      child: StageButton(
        label: AppLocalizations.of(context)!.startGame,
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        borderColor: AppColors.accent,
        onPressed: widget.onPressed,
        compact: MediaQuery.sizeOf(context).width < 390,
      ),
    );
  }
}














