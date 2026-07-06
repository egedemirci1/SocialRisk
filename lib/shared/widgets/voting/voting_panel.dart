import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Oylama paneli — Beğeni butonları (Parti Temalı).
class VotingPanel extends ConsumerStatefulWidget {
  const VotingPanel({
    super.key,
    required this.onVote,
    this.isEnabled = true,
    this.timeLimit = const Duration(seconds: 15),
  });

  final void Function(String voteValue, {bool timedOut}) onVote;
  final bool isEnabled;
  final Duration timeLimit;

  @override
  ConsumerState<VotingPanel> createState() => _VotingPanelState();
}

class _VotingPanelState extends ConsumerState<VotingPanel>
    with TickerProviderStateMixin {
  String? _selectedVote;
  late final AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: widget.timeLimit,
    )..forward();

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _selectedVote == null) {
        _castVote('neutral', timedOut: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isEnabled) return;
      ref.read(audioServiceProvider).startCountdownLoop();
    });
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stopCountdown();
    _timerController.dispose();
    super.dispose();
  }

  void _castVote(String value, {bool timedOut = false}) {
    if (_selectedVote != null || !widget.isEnabled) return;
    ref.read(audioServiceProvider).stopCountdown();
    if (!timedOut) {
      ref.read(audioServiceProvider).playSfx(AppSfx.buttonClick);
    }
    setState(() => _selectedVote = value);
    widget.onVote(value, timedOut: timedOut);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmall = screenHeight < 700;
    final containerPadding = isSmall ? 12.0 : 16.0;
    final emojiSize = isSmall ? 18.0 : 22.0;
    final innerGap = isSmall ? 10.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context)!.howWasPerformance,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontSize: isSmall ? 20 : 24, // Reduced slightly
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.evaluatePerformance,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white54,
              fontSize: isSmall ? 12 : 14, // Reduced slightly
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: innerGap),

          // Geri sayım çubuğu (Spotlight ışığı gibi sarıdan kırmızıya)
          AnimatedBuilder(
            animation: _timerController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 1 - _timerController.value,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timerController.value > 0.8
                        ? AppColors.primary
                        : AppColors.accent,
                  ),
                  minHeight: 4,
                ),
              );
            },
          ),
          SizedBox(height: innerGap),

          Row(
            children: [
              Expanded(
                child: _VoteButton(
                  emoji: '👏',
                  label: AppLocalizations.of(context)!.voteLike,
                  color: AppColors.votePositive,
                  isSelected: _selectedVote == 'like',
                  isDisabled: _selectedVote != null && _selectedVote != 'like',
                  onTap: () => _castVote('like'),
                  emojiSize: emojiSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteButton(
                  emoji: '😶',
                  label: AppLocalizations.of(context)!.voteNeutral,
                  color: AppColors.voteNeutral,
                  isSelected: _selectedVote == 'neutral',
                  isDisabled:
                      _selectedVote != null && _selectedVote != 'neutral',
                  onTap: () => _castVote('neutral'),
                  emojiSize: emojiSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteButton(
                  emoji: '🎭',
                  label: AppLocalizations.of(context)!.voteDislike,
                  color: AppColors.voteNegative,
                  isSelected: _selectedVote == 'dislike',
                  isDisabled:
                      _selectedVote != null && _selectedVote != 'dislike',
                  onTap: () => _castVote('dislike'),
                  emojiSize: emojiSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    this.emojiSize = 24,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: emojiSize)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12, // Reduced from 14
                    color: isSelected ? color : Colors.white54,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

