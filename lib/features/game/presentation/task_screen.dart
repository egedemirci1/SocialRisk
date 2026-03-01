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

        // Listen for task changes to animate the card
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

        // Durumuna göre yönlendir (Yalnızca Voting ve Performing için yönlendir)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (game.status == GameStatus.voting) {
              context.replace('/voting', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            } else if (game.status == GameStatus.performing && !isMyTurn) {
              context.replace('/waiting', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            } else if (game.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
            }
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(isMyTurn ? 'Senin Sıran!' : 'Arkadaşının Sırası'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                onPressed: () => ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: GradientContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: task != null
                ? _buildTaskView(
                    game.passStreak,
                    task,
                    roomAsync.value?.visibility ?? RoomVisibility.open,
                    isMyTurn,
                  )
                : _buildWheelView(game, isMyTurn),
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
  Widget _buildWheelView(GameEntity game, bool isMyTurn) {
    return Column(
      children: [
        const Spacer(),
        Text(
          isMyTurn ? '🎡 Çarkı Çevir!' : '🎡 Çark Çevriliyor...',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accent,
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

  /// Görev görünümü — çark döndü, görev gösterildi
  Widget _buildTaskView(int passStreak, TaskEntity task, RoomVisibility visibility, bool isMyTurn) {
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
          isClosed ? '🔒 Kapalı Mod' : (isMyTurn ? '🎯 Görevin:' : '🎯 Arkadaşının Görevi:'),
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
            'Arkadaşının karar vermesi bekleniyor...',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

