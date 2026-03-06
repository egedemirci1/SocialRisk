import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/game/spin_wheel.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/game_entity.dart';
import '../../room/domain/room_entity.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';
import 'widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

/// Senaryo Ekranı — Parti Temalı
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key, required this.gameId, required this.roomCode});

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with SingleTickerProviderStateMixin {
  bool _isAccepting = false;
  bool _isPassing = false;
  bool _contentRevealed = false;

  late final AnimationController _cardController;
  late final Animation<double> _cardAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _onWheelResult(String category) {
    if (ref.read(watchGameProvider(widget.gameId)).value?.currentPlayerId ==
        ref.read(currentUserProvider)?.uid) {
      ref
          .read(gameControllerProvider.notifier)
          .assignTaskByCategory(gameId: widget.gameId, category: category);
    }
  }

  Future<void> _acceptTask() async {
    setState(() => _isAccepting = true);
    try {
      await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId);
      await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId);
      // Removed context.push to rely purely on the provider listener!
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid == null) return;
      await ref
          .read(gameControllerProvider.notifier)
          .passTask(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: uid,
          );
      setState(() => _contentRevealed = false);
      _cardController.reset();
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = game.currentTask;
        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;

        // Seyirciler artık bekleme ekranına yönlendirilmiyor.
        // task_screen zaten isMyTurn ile spectator görünümü sunuyor.

        final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
        final players = playersAsync.value ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final playerName = currentPlayer?.name ?? 'Oyuncu';

        ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
          previous,
          next,
        ) {
          if (previous?.value?.currentTask == null &&
              next.value?.currentTask != null) {
            setState(() => _contentRevealed = false);
            _cardController.forward(from: 0.0);
          }
        });

        if (task != null &&
            !_cardController.isAnimating &&
            _cardController.value == 0.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _cardController.forward(from: 0.0);
          });
        }

        _handleStatusChanges(game, isMyTurn);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Parti Başlıyor',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: ExitRoomButton(roomCode: widget.roomCode),
            actions: [
              if (roomAsync.value != null)
                TurnCounterBadge(
                  currentRound: game.currentRound,
                  endConditionType: roomAsync.value!.endConditionType,
                  endConditionValue: roomAsync.value!.endConditionValue,
                ),
              IconButton(
                icon: const Icon(
                  Icons.leaderboard_rounded,
                  color: AppColors.accent,
                ),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: ResponsiveWrapper(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: task != null
                                  ? _buildTaskView(
                                      game.passStreak,
                                      task,
                                      roomAsync.value?.visibility ?? RoomVisibility.open,
                                      isMyTurn,
                                      playerName,
                                    )
                                  : (roomAsync.value?.mode == GameMode.economy
                                        ? _buildEconomyRedirect()
                                        : _buildWheelView(
                                            isMyTurn,
                                            playerName,
                                            currentPlayer,
                                            roomAsync.value?.categories ?? [],
                                          )),
                            ),
                          ),
                          if (players.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24, top: 8),
                              child: SpectatorStrip(
                                players: players,
                                currentPlayerId: game.currentPlayerId,
                                myPlayerId: user?.uid,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(message: 'Parti Başlıyor...'),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Hata: $e')),
      ),
    );
  }

  void _handleStatusChanges(GameEntity game, bool isMyTurn) {
    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;
      final nextG = next.value;
      if (nextG != null && previous?.value?.status != nextG.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (nextG.status == GameStatus.choosingDifficulty) {
              context.replace(
                '/difficulty',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextG.status == GameStatus.performing) {
              context.replace(
                '/performing',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextG.status == GameStatus.voting) {
              context.replace(
                '/voting',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextG.status == GameStatus.results) {
              context.replace(
                '/round-result',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextG.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
            }
          }
        });
      }
    });
  }

  Widget _buildWheelView(
    bool isMyTurn,
    String playerName,
    PlayerEntity? currentPlayer,
    List<String> categories,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        if (currentPlayer != null)
          PlayerSpotlight(player: currentPlayer, isMe: isMyTurn),
        const Spacer(),
        Text(
          '🎡 Senaryonu Belirle',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sahne ışıkları altına çıkmadan önce rolünü seç...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 32),
        SpinWheel(
          spinningTarget: ref
              .watch(watchGameProvider(widget.gameId))
              .value
              ?.spinningTarget,
          canSpin: isMyTurn,
          playerName: playerName,
          categories: categories,
          onSpinRequest: () {
            if (categories.isEmpty) return;
            final randomCat = categories[_random.nextInt(categories.length)];
            ref
                .read(gameControllerProvider.notifier)
                .setSpinningTarget(gameId: widget.gameId, target: randomCat);
          },
          onSpinComplete: _onWheelResult,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildEconomyRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.replace(
          '/economy-pick',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildTaskView(
    int passStreak,
    TaskEntity task,
    RoomVisibility visibility,
    bool isMyTurn,
    String playerName,
  ) {
    final isClosed = visibility == RoomVisibility.closed && !_contentRevealed;
    return Column(
      children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Text(
            'Kategori: ${task.category} • ${task.difficulty == 'easy'
                ? 'KOLAY'
                : task.difficulty == 'medium'
                ? 'ORTA'
                : 'ZOR'}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        if (task.id.length >
            15) // UserTask ID'leri timestamp olduğu için genelde uzundur, veya tags kontrolü yapılabilir
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'SAHNEYE ÖZEL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          isClosed
              ? 'Sıradaki Sahne Gizli'
              : (isMyTurn ? 'Senaryon Burada:' : '$playerName\'ın Senaryosu:'),
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ScaleTransition(
          scale: _cardAnimation,
          child: GameCard(
            category: task.category,
            content: isClosed
                ? 'Mevcut görevi görmek için kartı aç...'
                : task.content,
            multiplier: task.multiplier,
          ),
        ),
        const Spacer(),
        if (isClosed && isMyTurn)
          StageButton(
            label: 'Görevi Aç',
            backgroundColor: AppColors.accent,
            textColor: Colors.black,
            borderColor: AppColors.accent,
            onPressed: () => setState(() => _contentRevealed = true),
          )
        else if (isMyTurn) ...[
          StageButton(
            label: 'Gösteriye Katıl',
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isPassing ? null : _passTask,
            child: Text(
              'Bu Rolü Reddet (-${50 * (passStreak + 1)} Alkış)',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white38,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ] else
          Text(
            '$playerName senaryosunu okuyor...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white30,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}
