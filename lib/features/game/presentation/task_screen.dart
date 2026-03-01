import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/game/spin_wheel.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../domain/game_entity.dart';
import '../../room/domain/room_entity.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';

/// Görev ekranı — Çark → Kategori → Görev → Kabul/Pas.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

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
  final List<String> _categories = const [
    'Cesaret', 'İtiraf', 'Taklit', 'Sosyal Medya', 'Fiziksel', 'Bilgi'
  ];

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
    final user = ref.read(currentUserProvider);
    final game = ref.read(watchGameProvider(widget.gameId)).value;
    final isMyTurn = game?.currentPlayerId == user?.uid;

    if (isMyTurn) {
      ref.read(gameControllerProvider.notifier).assignTaskByCategory(
            gameId: widget.gameId,
            category: category,
          );
    }
  }

  Future<void> _acceptTask() async {
    setState(() => _isAccepting = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .acceptTask(widget.gameId);
      if (mounted) {
        context.push('/performing', extra: {
          'gameId': widget.gameId,
          'roomCode': widget.roomCode,
        });
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      await ref.read(gameControllerProvider.notifier).passTask(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: user.uid,
          );
      // Reset card state
      setState(() {
        _contentRevealed = false;
      });
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = game.currentTask;
        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;

        // Aktif oyuncunun ismini ve objesini bul
        final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
        String currentPlayerName = game.currentPlayerId;
        PlayerEntity? currentPlayer;
        List<PlayerEntity> players = [];
        
        if (playersAsync.value != null) {
          players = playersAsync.value!;
          try {
            currentPlayer = players.firstWhere((p) => p.id == game.currentPlayerId);
            currentPlayerName = currentPlayer.name;
          } catch (_) {}
        }

         ref.listen<AsyncValue<GameEntity?>>(
          watchGameProvider(widget.gameId),
          (previous, next) {
            final prevTask = previous?.value?.currentTask;
            final nextTask = next.value?.currentTask;
            if (prevTask == null && nextTask != null) {
              setState(() {
                _contentRevealed = false;
              });
              _cardController.forward(from: 0.0);
            }
          }
        );

        // If we arrive with a task already set (e.g. returning from difficulty
        // selection), ensure the card animation plays so the card is visible.
        if (task != null && !_cardController.isAnimating && _cardController.value == 0.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _cardController.forward(from: 0.0);
          });
        }

        // Navigate based on game status changes to prevent double routing
        ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (previous, next) {
          if (!mounted) return;
          final nextGame = next.value;
          final prevGame = previous?.value;
          
          if (nextGame != null && prevGame?.status != nextGame.status) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (nextGame.status == GameStatus.choosingDifficulty) {
                  context.replace('/difficulty', extra: {
                    'gameId': widget.gameId,
                    'roomCode': widget.roomCode,
                  });
                } else if (nextGame.status == GameStatus.voting) {
                  context.replace('/voting', extra: {
                    'gameId': widget.gameId,
                    'roomCode': widget.roomCode,
                  });
                } else if (nextGame.status == GameStatus.performing && !isMyTurn) {
                  context.replace('/waiting', extra: {
                    'gameId': widget.gameId,
                    'roomCode': widget.roomCode,
                  });
                } else if (nextGame.status == GameStatus.results) {
                  context.replace('/round-result', extra: {
                    'gameId': widget.gameId,
                    'roomCode': widget.roomCode,
                  });
                } else if (nextGame.status == GameStatus.finished) {
                  context.replace('/game-over', extra: widget.roomCode);
                }
              }
            });
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sosyal Risk'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                onPressed: () => ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: GradientContainer(
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
                            currentPlayerName,
                          )
                        : (roomAsync.value?.mode == GameMode.economy
                            ? _buildEconomyRedirect(game)
                            : _buildWheelView(game, isMyTurn, currentPlayerName, currentPlayer)),
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
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }

  /// Çark görünümü
  Widget _buildWheelView(GameEntity game, bool isMyTurn, String playerName, PlayerEntity? currentPlayer) {
    return Column(
      children: [
        const SizedBox(height: 24),
        if (currentPlayer != null)
          PlayerSpotlight(
            player: currentPlayer,
            isMe: isMyTurn,
          )
        else
          Text(
            isMyTurn ? 'Senin Sıran!' : '$playerName oynuyor',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.accent,
            ),
          ),
        const Spacer(),
        Text(
          '🎡 Çarkı Çevir!',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kategori şansa bağlı!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 24),
        SpinWheel(
          spinningTarget: game.spinningTarget,
          canSpin: isMyTurn,
          playerName: playerName,
          onSpinRequest: () {
            final randomCat = _categories[_random.nextInt(_categories.length)];
            ref.read(gameControllerProvider.notifier).setSpinningTarget(
                  gameId: widget.gameId,
                  target: randomCat,
                );
          },
          onSpinComplete: _onWheelResult,
        ),
        const Spacer(),
      ],
    );
  }

  /// Ekonomi modunda kategori seçim ekranına yönlendir
  Widget _buildEconomyRedirect(GameEntity game) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.replace('/economy-pick', extra: {
          'gameId': widget.gameId,
          'roomCode': widget.roomCode,
        });
      }
    });
    return const Center(child: CircularProgressIndicator());
  }

  /// Görev görünümü — çark döndü, görev gösterildi
  Widget _buildTaskView(int passStreak, TaskEntity task, RoomVisibility visibility, bool isMyTurn, String playerName) {
    final isClosed = visibility == RoomVisibility.closed && !_contentRevealed;
    return Column(
      children: [
        const Spacer(),

        // Seçilen kategori badge
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                '🎡 ${task.category}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        Text(
          isClosed ? '🔒 Kapalı Mod' : (isMyTurn ? '🎯 Görevin:' : '🎯 $playerName\'in Görevi:'),
          style: AppTextStyles.headlineMedium.copyWith(
            color: isClosed ? Colors.white54 : AppColors.accent,
          ),
        ),
        const SizedBox(height: 24),

        ScaleTransition(
          scale: _cardAnimation,
          child: GameCard(
            category: task.category,
            content: isClosed
                ? '❓ İçeriği görmek için aç'
                : task.content,
            multiplier: task.multiplier,
          ),
        ),

        const Spacer(),

        if (isClosed && isMyTurn) ...[
          // Kapalı modda — önce içeriği aç
          PrimaryButton(
            label: 'Görevi Aç 🔓',
            icon: Icons.lock_open_rounded,
            onPressed: () => setState(() => _contentRevealed = true),
          ),
        ] else if (isMyTurn) ...[
          // Açık mod veya içerik açıldıktan sonra
          PrimaryButton(
            label: 'Görevi Kabul Et',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
          ),
          const SizedBox(height: 12),
          DangerButton(
            label: 'Pas Geç (Ceza: -${50 * (passStreak + 1)} puan)',
            icon: Icons.close_rounded,
            outlined: true,
            onPressed: _passTask,
            isLoading: _isPassing,
          ),
        ] else ...[
          Text(
            '$playerName\'ın karar vermesi bekleniyor...',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

