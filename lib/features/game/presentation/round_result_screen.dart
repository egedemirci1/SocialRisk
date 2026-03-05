import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/models/enums.dart';
import '../providers/game_provider.dart';
import '../domain/game_entity.dart';
import '../../room/providers/room_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/task_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../room/domain/room_entity.dart';

/// Tur sonu ekranı — Tiyatro Temalı
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: LeaveRoomButton(roomCode: widget.roomCode),
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final earnedScore = game.lastRoundScore ?? 0;
          final multiplier = game.lastRoundMultiplier ?? 1;
          final isPass = multiplier == 0;
          final isGameOver = game.status == GameStatus.finished;
          final players = playersAsync.value ?? [];
          final currentPlayer = players
              .where(
                (p) => p.id == (game.lastRoundPlayerId ?? game.currentPlayerId),
              )
              .firstOrNull;
          final playerName = currentPlayer?.name ?? 'Aktör';

          ref.listen<AsyncValue<GameEntity?>>(
            watchGameProvider(widget.gameId),
            (previous, next) {
              if (!context.mounted) return;
              final currentStatus = next.value?.status;

              if (currentStatus == GameStatus.playing ||
                  currentStatus == GameStatus.choosingDifficulty) {
                // nextTurn çağrıldı — tüm oyuncular task ekranına
                context.go(
                  '/task',
                  extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
                );
              } else if (currentStatus == GameStatus.finished) {
                context.go('/game-over', extra: widget.roomCode);
              }
            },
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _buildResultHeader(earnedScore, isPass, playerName),
                  const SizedBox(height: 24),
                  _buildScoreCard(earnedScore, multiplier, isPass),
                  const SizedBox(height: 24),
                  _buildLeaderboard(players, game),
                  const SizedBox(height: 24),
                  if (game.currentTask != null)
                    _TaskFeedbackSection(
                      taskId: game.currentTask!.id,
                      taskContent: game.currentTask!.content,
                    ),
                  const SizedBox(height: 32),
                  _buildActionButtons(isGameOver, game),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: _buildConfetti(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildResultHeader(int score, bool isPass, String playerName) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: score >= 0
                ? Colors.green.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: score >= 0 ? Colors.green : AppColors.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              score >= 0 ? '👏' : '🎭',
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isPass ? 'ROL REDDEDİLDİ' : 'PERDE KAPANDI',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isPass
              ? '$playerName rolünü yapmayı reddetti.'
              : '$playerName performansını tamamladı.',
          style: GoogleFonts.libreBaskerville(
            color: Colors.white54,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreCard(int score, int multiplier, bool isPass) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (!isPass) ...[
            _ScoreRow(
              label: 'Seyirci Puanı',
              value: multiplier != 0 ? '${score ~/ multiplier}' : '$score',
              color: score >= 0 ? Colors.green : AppColors.primary,
            ),
            const Divider(color: Colors.white10, height: 24),
            _ScoreRow(
              label: 'Zorluk Çarpanı',
              value: '×$multiplier',
              color: Colors.white,
            ),
            const Divider(color: Colors.white10, height: 24),
          ],
          _ScoreRow(
            label: score >= 0 ? 'Kazanılan Alkış' : 'Kaybedilen Alkış',
            value: score >= 0 ? '+$score' : '$score',
            color: AppColors.accent,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(List<PlayerEntity> players, GameEntity game) {
    final sortedPlayers = List.of(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            'AKTÖR SIRALAMASI',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(sortedPlayers.length, (index) {
            final p = sortedPlayers[index];
            final isMe = p.id == game.currentPlayerId;
            return _LeaderboardTile(player: p, rank: index + 1, isTarget: isMe);
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isGameOver, GameEntity game) {
    return Consumer(
      builder: (context, ref, child) {
        final room = ref.watch(watchRoomProvider(widget.roomCode)).value;
        final isHost = room?.hostId == ref.watch(currentUserProvider)?.uid;

        if (isHost) {
          return StageButton(
            label: isGameOver ? 'FİNAL PERDESİ' : 'SIRADAKİ SAHNE',
            icon: isGameOver
                ? Icons.emoji_events_rounded
                : Icons.arrow_forward_rounded,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent.withValues(alpha: 0.3),
            onPressed: () async {
              if (isGameOver) {
                context.go('/game-over', extra: widget.roomCode);
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
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                isGameOver
                    ? 'Final bekleniyor...'
                    : 'Başaktörün yeni sahneye geçmesi bekleniyor...',
                style: GoogleFonts.libreBaskerville(
                  color: Colors.white30,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }

  Widget? _buildConfetti() {
    final score =
        ref.watch(watchGameProvider(widget.gameId)).value?.lastRoundScore ?? 0;
    if (score <= 0) return null;
    return IgnorePointer(
      child: Lottie.asset(
        'assets/lotties/confetti.json',
        controller: _lottieController,
        onLoaded: (comp) {
          _lottieController.duration = comp.duration;
          _lottieController.forward(from: 0.0);
        },
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isBold;
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            color: color,
            fontSize: isBold ? 24 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends ConsumerWidget {
  final PlayerEntity player;
  final int rank;
  final bool isTarget;
  const _LeaderboardTile({
    required this.player,
    required this.rank,
    required this.isTarget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(watchUserProfileProvider(player.id)).value;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final titleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isTarget
            ? AppColors.accent.withValues(alpha: 0.05)
            : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '#$rank',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PlayerAvatar(uid: player.id, displayName: player.name, radius: 15),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (titleItem != null)
                  Text(
                    '${titleItem.imageUrl} ${titleItem.name}',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${player.score}',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFeedbackSection extends ConsumerStatefulWidget {
  final String taskId, taskContent;
  const _TaskFeedbackSection({required this.taskId, required this.taskContent});

  @override
  ConsumerState<_TaskFeedbackSection> createState() =>
      _TaskFeedbackSectionState();
}

class _TaskFeedbackSectionState extends ConsumerState<_TaskFeedbackSection> {
  bool? _givenFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            'SENARYOYU DEĞERLENDİR',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeedbackButton(
                icon: Icons.thumb_up_rounded,
                label: 'İYİ',
                isActive: _givenFeedback == true,
                color: Colors.green,
                onTap: () => _submit(true),
              ),
              const SizedBox(width: 12),
              _FeedbackButton(
                icon: Icons.thumb_down_rounded,
                label: 'KÖTÜ',
                isActive: _givenFeedback == false,
                color: AppColors.primary,
                onTap: () => _submit(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(bool like) {
    if (_givenFeedback != null) return;
    setState(() => _givenFeedback = like);
    ref
        .read(taskControllerProvider.notifier)
        .submitFeedback(
          taskId: widget.taskId,
          userId: ref.read(currentUserProvider)!.uid,
          isLike: like,
        );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? color : Colors.white38, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.playfairDisplay(
                color: isActive ? color : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
