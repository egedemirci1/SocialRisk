import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart'; // Still used for votePositive/Neutral/Negative

/// Oylama paneli — Beğen / Nötr / Beğenme butonları + geri sayım (Orta Çağ Temalı).
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

  // Tematik Renkler
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu
  static const _accentCrimson = Color(0xFF5C1616); // Bordo

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
          color: _cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accentGold.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nasıl buldun?',
                style: GoogleFonts.cinzelDecorative(
                  color: _textLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Oyuncunun performansını oyla',
                style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
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
                      backgroundColor: Colors.black.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timerController.value > 0.7
                            ? _accentCrimson
                            : _accentGold,
                      ),
                      minHeight: 6,
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
                      isDisabled:
                          _selectedVote != null && _selectedVote != 'like',
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
                      isDisabled:
                          _selectedVote != null && _selectedVote != 'neutral',
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
                      isDisabled:
                          _selectedVote != null && _selectedVote != 'dislike',
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
                ? color.withOpacity(0.2)
                : Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.white12,
              width: 1.5,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDisabled ? 0.4 : 1.0,
            child: Column(
              children: [
                Text(emoji, style: TextStyle(fontSize: isSelected ? 32 : 28)),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.white70,
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
