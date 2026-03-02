import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart'; // Still used for votePositive/voteNegative if we wish, or we can use custom
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../../shared/models/enums.dart';
import '../providers/game_provider.dart';
import '../domain/game_entity.dart';
import '../../room/providers/room_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/task_provider.dart'; // Yeni eklendi
import '../../../shared/widgets/common/player_avatar.dart';
import 'package:lottie/lottie.dart';

/// Tur sonu ekranı — Oylama sonucu ve kazanılan/kaybedilen puan (Orta Çağ Temalı).
class RoundResultScreen extends ConsumerStatefulWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends ConsumerState<RoundResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return Scaffold(
      backgroundColor: _bgColor,
      body: gameAsync.when(
        data: (game) {
          if (game == null)
            return Center(child: CircularProgressIndicator(color: _accentGold));

          final earnedScore = game.lastRoundScore ?? 0;
          final multiplier = game.lastRoundMultiplier ?? 1;
          final isPass = multiplier == 0;
          final isGameOver = game.status == GameStatus.finished;

          String playerName = game.currentPlayerId;
          if (playersAsync.value != null) {
            try {
              playerName = playersAsync.value!
                  .firstWhere((p) => p.id == game.currentPlayerId)
                  .name;
            } catch (_) {}
          }

          // Navigate non-hosts automatically when next round starts
          ref.listen<AsyncValue<GameEntity?>>(
            watchGameProvider(widget.gameId),
            (previous, next) {
              if (!context.mounted) return;
              final previousStatus = previous?.value?.status;
              final currentStatus = next.value?.status;

              if (previousStatus == GameStatus.results &&
                  currentStatus == GameStatus.playing) {
                context.go(
                  '/waiting',
                  extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
                );
              } else if (currentStatus == GameStatus.finished) {
                context.go('/game-over', extra: widget.roomCode);
              }
            },
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // Arka Plan Resmi
              Image.asset(
                'assets/Loading-Screen-Background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              // Karartma (Overlay)
              Container(color: _bgColor.withOpacity(0.85)),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: earnedScore >= 0
                              ? AppColors.votePositive.withOpacity(0.2)
                              : AppColors.voteNegative.withOpacity(0.2),
                          border: Border.all(
                            color: earnedScore >= 0
                                ? AppColors.votePositive
                                : AppColors.voteNegative,
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Text(
                              earnedScore >= 0 ? '🎉' : '💀',
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        isPass ? 'Görev Pas Geçildi!' : 'Tur Tamamlandı!',
                        style: GoogleFonts.cinzelDecorative(
                          color: _textLight,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$playerName ${isPass ? 'görevi pas geçti ve ceza aldı.' : 'görevini yaptı.'}',
                        style: GoogleFonts.cinzel(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: _cardColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accentGold.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Skor Detayları
                              if (!isPass) ...[
                                _ScoreRow(
                                  label: 'Oylama Skoru',
                                  value: multiplier != 0
                                      ? '${earnedScore ~/ multiplier}'
                                      : '$earnedScore',
                                  color: earnedScore >= 0
                                      ? AppColors.votePositive
                                      : AppColors.voteNegative,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    color: _accentGold.withOpacity(0.3),
                                  ),
                                ),
                                _ScoreRow(
                                  label: 'Çarpan',
                                  value: '×$multiplier',
                                  color: _textLight,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    color: _accentGold.withOpacity(0.3),
                                  ),
                                ),
                              ],
                              _ScoreRow(
                                label: earnedScore >= 0
                                    ? 'Kazanılan Puan'
                                    : 'Kaybedilen Puan',
                                value: earnedScore >= 0
                                    ? '+$earnedScore'
                                    : '$earnedScore',
                                color: _accentGold,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Liderlik Tablosu
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: _cardColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accentGold.withOpacity(0.3),
                          ),
                        ),
                        child: playersAsync.when(
                          data: (players) {
                            final sortedPlayers = List.of(players)
                              ..sort((a, b) => b.score.compareTo(a.score));
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    4,
                                  ),
                                  child: Text(
                                    '🏆 Liderlik Tablosu',
                                    style: GoogleFonts.cinzel(
                                      color: _textLight,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...List.generate(sortedPlayers.length, (index) {
                                  final player = sortedPlayers[index];
                                  final isMe =
                                      player.id == game.currentPlayerId;

                                  Color rankColor;
                                  if (index == 0) {
                                    rankColor = const Color(0xFFFFD700);
                                  } else if (index == 1) {
                                    rankColor = const Color(0xFFC0C0C0);
                                  } else if (index == 2) {
                                    rankColor = const Color(0xFFCD7F32);
                                  } else {
                                    rankColor = Colors.white54;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      8,
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? _accentCrimson.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: isMe
                                            ? Border.all(
                                                color: _accentGold.withOpacity(
                                                  0.5,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              child: Text(
                                                '#${index + 1}',
                                                style: GoogleFonts.cinzel(
                                                  color: rankColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            PlayerAvatar(
                                              displayName: player.name,
                                              avatarUrl: player.avatarUrl,
                                              score: player.score,
                                              frameId: player.activeFrame,
                                              radius: 14,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                player.name,
                                                style: GoogleFonts.cinzel(
                                                  color: _textLight,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${player.score}',
                                              style: GoogleFonts.cinzel(
                                                color: _accentGold,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 4),
                              ],
                            );
                          },
                          loading: () => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _accentGold,
                              ),
                            ),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Skorlar yüklenemedi: $e',
                                style: GoogleFonts.cinzel(
                                  color: _accentCrimson,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Görev Feedback Alanı
                      if (game.currentTask != null)
                        _TaskFeedbackSection(
                          taskId: game.currentTask!.id,
                          taskContent: game.currentTask!.content,
                          gameId: widget.gameId,
                        ),

                      const SizedBox(height: 24),

                      Consumer(
                        builder: (context, ref, child) {
                          final roomAsync = ref.watch(
                            watchRoomProvider(widget.roomCode),
                          );
                          final user = ref.watch(currentUserProvider);
                          final isHost = roomAsync.value?.hostId == user?.uid;

                          if (isHost) {
                            return MedievalButton(
                              label: isGameOver
                                  ? 'Sonuçları Gör'
                                  : 'Sıradaki Tura Geç',
                              icon: isGameOver
                                  ? Icons.emoji_events_rounded
                                  : Icons.arrow_forward_rounded,
                              backgroundColor: _accentCrimson,
                              textColor: _textLight,
                              borderColor: _accentGold,
                              onPressed: () async {
                                if (isGameOver) {
                                  context.go(
                                    '/game-over',
                                    extra: widget.roomCode,
                                  );
                                } else {
                                  await ref
                                      .read(gameControllerProvider.notifier)
                                      .nextTurn(widget.gameId);
                                }
                              },
                            );
                          } else {
                            return Column(
                              children: [
                                CircularProgressIndicator(color: _accentGold),
                                const SizedBox(height: 16),
                                Text(
                                  isGameOver
                                      ? 'Oyun bitti, sonuçlar bekleniyor...'
                                      : 'Hostun sıradaki tura geçmesi bekleniyor...',
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: _accentGold)),
        error: (e, st) => Center(
          child: Text(
            'Hata: $e',
            style: GoogleFonts.cinzel(color: _accentCrimson),
          ),
        ),
      ),

      // Lottie overlay
      floatingActionButton:
          gameAsync.value?.lastRoundScore != null &&
              gameAsync.value!.lastRoundScore! > 0
          ? IgnorePointer(
              child: Lottie.asset(
                'assets/lotties/confetti.json',
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward(from: 0.0);
                },
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 16),
        ),
        Text(
          value,
          style: GoogleFonts.cinzelDecorative(
            color: color,
            fontSize: isBold ? 24 : 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _TaskFeedbackSection extends ConsumerStatefulWidget {
  final String taskId;
  final String taskContent;
  final String gameId;

  const _TaskFeedbackSection({
    required this.taskId,
    required this.taskContent,
    required this.gameId,
  });

  @override
  ConsumerState<_TaskFeedbackSection> createState() =>
      _TaskFeedbackSectionState();
}

class _TaskFeedbackSectionState extends ConsumerState<_TaskFeedbackSection> {
  bool? _givenFeedback; // true = like, false = dislike, null = none

  // Tematik Renkler for Feedback Box
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  Future<void> _submitFeedback(bool isLike) async {
    if (_givenFeedback != null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _givenFeedback = isLike);

    await ref
        .read(taskControllerProvider.notifier)
        .submitFeedback(
          taskId: widget.taskId,
          userId: user.uid,
          isLike: isLike,
        );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentGold.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Görevi Değerlendir',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFDEFC2),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.taskContent}"',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeedbackButton(
                  icon: Icons.thumb_up_rounded,
                  label: 'İyiydi',
                  isActive: _givenFeedback == true,
                  isDisabled: _givenFeedback != null && _givenFeedback != true,
                  activeColor: AppColors.votePositive,
                  onTap: () => _submitFeedback(true),
                ),
                const SizedBox(width: 16),
                _FeedbackButton(
                  icon: Icons.thumb_down_rounded,
                  label: 'Kötü',
                  isActive: _givenFeedback == false,
                  isDisabled: _givenFeedback != null && _givenFeedback != false,
                  activeColor: AppColors.voteNegative,
                  onTap: () => _submitFeedback(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final Color activeColor;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDisabled,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? activeColor
        : isDisabled
        ? Colors.white24
        : Colors.white54;

    return InkWell(
      onTap: isDisabled || isActive ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.15)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? activeColor : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
