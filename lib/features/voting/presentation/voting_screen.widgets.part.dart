part of 'voting_screen.dart';

class _VisualCountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onElapsed;

  const _VisualCountdownTimer({
    required this.duration,
    this.onElapsed,
  });

  @override
  State<_VisualCountdownTimer> createState() => _VisualCountdownTimerState();
}

class _VisualCountdownTimerState extends State<_VisualCountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
        vsync: this, duration: widget.duration);

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _progressController.forward();
    _progressController.addListener(() {
      final remaining =
          (1.0 - _progressController.value) * widget.duration.inSeconds;
      if (remaining <= 3.0 && !_shakeController.isAnimating) {
        _shakeController.repeat();
      }
    });
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onElapsed?.call();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _shakeController]),
      builder: (context, child) {
        final progress = 1.0 - _progressController.value;
        final remaining = progress * widget.duration.inSeconds;
        Color barColor;
        if (remaining > 10) {
          barColor = Colors.greenAccent;
        } else if (remaining > 5) {
          barColor = Colors.orangeAccent;
        } else {
          barColor = Colors.redAccent;
        }

        return Transform.translate(
          offset: Offset(remaining <= 3.0 ? _shakeAnimation.value : 0, 0),
          child: Container(
            height: 4,
            width: double.infinity,
            color: Colors.white12,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: remaining <= 3.0 ? 2 : 0,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingPsychologicalTexts extends StatefulWidget {
  @override
  State<_FloatingPsychologicalTexts> createState() =>
      _FloatingPsychologicalTextsState();
}

class _FloatingPsychologicalTextsState
    extends State<_FloatingPsychologicalTexts> with TickerProviderStateMixin {
  String _currentText = "";
  Alignment _currentAlignment = Alignment.center;
  late Timer _timer;
  final Random _rng = Random();

  List<String> _getLocalizedTexts(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.waitingTip1,
      l10n.waitingTip2,
      l10n.waitingTip3,
      l10n.waitingTip4,
      l10n.waitingTip5,
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final texts = _getLocalizedTexts(context);
      setState(() {
        _currentText = texts[_rng.nextInt(texts.length)];
      });
    });
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final texts = _getLocalizedTexts(context);
      setState(() {
        _currentText = texts[_rng.nextInt(texts.length)];
        _currentAlignment = Alignment(
          (_rng.nextDouble() * 1.6) - 0.8, // -0.8 to 0.8
          (_rng.nextDouble() * 1.6) - 0.8,
        );
      });
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
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: Align(
        key: ValueKey<String>(_currentText),
        alignment: _currentAlignment,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _currentText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.15),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


