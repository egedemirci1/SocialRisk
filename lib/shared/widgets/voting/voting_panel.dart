import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Oylama paneli — Beğen / Nötr / Beğenme butonları + geri sayım.
class VotingPanel extends StatefulWidget {
  const VotingPanel({
    super.key,
    required this.onVote,
    this.isEnabled = true,
    this.timeLimit = const Duration(seconds: 15),
  });

  final void Function(String voteValue) onVote;
  final bool isEnabled;
  final Duration timeLimit;

  @override
  State<VotingPanel> createState() => _VotingPanelState();
}

class _VotingPanelState extends State<VotingPanel>
    with TickerProviderStateMixin {
  String? _selectedVote;
  late final AnimationController _timerController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: widget.timeLimit,
    )..forward();

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _selectedVote == null) {
        // Süre doldu, nötr oy
        _castVote('neutral');
      }
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _castVote(String value) {
    if (_selectedVote != null || !widget.isEnabled) return;
    setState(() => _selectedVote = value);
    widget.onVote(value);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nasıl buldun?',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Oyuncunun performansını oyla',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 20),

              // Geri sayım çubuğu
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1 - _timerController.value,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timerController.value > 0.7
                            ? AppColors.penalty
                            : AppColors.accent,
                      ),
                      minHeight: 4,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Oylama butonları
              Row(
                children: [
                  Expanded(
                    child: _VoteButton(
                      emoji: '👍',
                      label: 'Beğendim',
                      color: AppColors.votePositive,
                      isSelected: _selectedVote == 'like',
                      isDisabled: _selectedVote != null &&
                          _selectedVote != 'like',
                      onTap: () => _castVote('like'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VoteButton(
                      emoji: '😐',
                      label: 'Nötr',
                      color: AppColors.voteNeutral,
                      isSelected: _selectedVote == 'neutral',
                      isDisabled: _selectedVote != null &&
                          _selectedVote != 'neutral',
                      onTap: () => _castVote('neutral'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VoteButton(
                      emoji: '👎',
                      label: 'Beğenmedim',
                      color: AppColors.voteNegative,
                      isSelected: _selectedVote == 'dislike',
                      isDisabled: _selectedVote != null &&
                          _selectedVote != 'dislike',
                      onTap: () => _castVote('dislike'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
  });

  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDisabled ? 0.4 : 1.0,
            child: Column(
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: isSelected ? 32 : 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
