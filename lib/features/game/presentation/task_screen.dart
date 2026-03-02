import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/game/spin_wheel.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../domain/game_entity.dart';
import '../../room/domain/room_entity.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';

/// Görev ekranı — Çark → Kategori → Görev → Kabul/Pas (Orta Çağ Temalı).
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
  final List<String> _categories = const [
    'Cesaret',
    'İtiraf',
    'Taklit',
    'Sosyal Medya',
    'Fiziksel',
    'Bilgi',
  ];

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

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
      ref
          .read(gameControllerProvider.notifier)
          .assignTaskByCategory(gameId: widget.gameId, category: category);
    }
  }

  Future<void> _acceptTask() async {
    setState(() => _isAccepting = true);
    try {
      await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId);
      if (mounted) {
        context.push(
          '/performing',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
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
      await ref
          .read(gameControllerProvider.notifier)
          .passTask(
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
          return Scaffold(
            backgroundColor: _bgColor,
            body: Center(child: CircularProgressIndicator(color: _accentGold)),
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
            currentPlayer = players.firstWhere(
              (p) => p.id == game.currentPlayerId,
            );
            currentPlayerName = currentPlayer.name;
          } catch (_) {}
        }

        ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
          previous,
          next,
        ) {
          final prevTask = previous?.value?.currentTask;
          final nextTask = next.value?.currentTask;
          if (prevTask == null && nextTask != null) {
            setState(() {
              _contentRevealed = false;
            });
            _cardController.forward(from: 0.0);
          }
        });

        // If we arrive with a task already set (e.g. returning from difficulty
        // selection), ensure the card animation plays so the card is visible.
        if (task != null &&
            !_cardController.isAnimating &&
            _cardController.value == 0.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _cardController.forward(from: 0.0);
          });
        }

        // Navigate based on game status changes to prevent double routing
        ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
          previous,
          next,
        ) {
          if (!mounted) return;
          final nextGame = next.value;
          final prevGame = previous?.value;

          if (nextGame != null && prevGame?.status != nextGame.status) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (nextGame.status == GameStatus.choosingDifficulty) {
                  context.replace(
                    '/difficulty',
                    extra: {
                      'gameId': widget.gameId,
                      'roomCode': widget.roomCode,
                    },
                  );
                } else if (nextGame.status == GameStatus.voting) {
                  context.replace(
                    '/voting',
                    extra: {
                      'gameId': widget.gameId,
                      'roomCode': widget.roomCode,
                    },
                  );
                } else if (nextGame.status == GameStatus.performing &&
                    !isMyTurn) {
                  context.replace(
                    '/waiting',
                    extra: {
                      'gameId': widget.gameId,
                      'roomCode': widget.roomCode,
                    },
                  );
                } else if (nextGame.status == GameStatus.results) {
                  context.replace(
                    '/round-result',
                    extra: {
                      'gameId': widget.gameId,
                      'roomCode': widget.roomCode,
                    },
                  );
                } else if (nextGame.status == GameStatus.finished) {
                  context.replace('/game-over', extra: widget.roomCode);
                }
              }
            });
          }
        });

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            title: Text(
              'Sosyal Risk',
              style: GoogleFonts.cinzelDecorative(
                fontWeight: FontWeight.w700,
                color: _textLight,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded, color: _accentGold),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
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
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: task != null
                            ? _buildTaskView(
                                game.passStreak,
                                task,
                                roomAsync.value?.visibility ??
                                    RoomVisibility.open,
                                isMyTurn,
                                currentPlayerName,
                              )
                            : (roomAsync.value?.mode == GameMode.economy
                                  ? _buildEconomyRedirect(game)
                                  : _buildWheelView(
                                      game,
                                      isMyTurn,
                                      currentPlayerName,
                                      currentPlayer,
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
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _accentGold)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Text(
            'Hata: $e',
            style: GoogleFonts.cinzel(color: _accentCrimson),
          ),
        ),
      ),
    );
  }

  /// Çark görünümü
  Widget _buildWheelView(
    GameEntity game,
    bool isMyTurn,
    String playerName,
    PlayerEntity? currentPlayer,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        if (currentPlayer != null)
          PlayerSpotlight(player: currentPlayer, isMe: isMyTurn)
        else
          Text(
            isMyTurn ? 'Senin Sıran!' : '$playerName oynuyor',
            style: GoogleFonts.cinzel(
              color: _accentGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        const Spacer(),
        Text(
          '🎡 Çarkı Çevir!',
          style: GoogleFonts.cinzel(
            color: _textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kategori şansa bağlı!',
          style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        SpinWheel(
          spinningTarget: game.spinningTarget,
          canSpin: isMyTurn,
          playerName: playerName,
          onSpinRequest: () {
            final randomCat = _categories[_random.nextInt(_categories.length)];
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

  /// Ekonomi modunda kategori seçim ekranına yönlendir
  Widget _buildEconomyRedirect(GameEntity game) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.replace(
          '/economy-pick',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      }
    });
    return Center(child: CircularProgressIndicator(color: _accentGold));
  }

  /// Görev görünümü — çark döndü, görev gösterildi
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

        // Seçilen kategori badge
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentGold.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '🎡 ${task.category}',
                style: GoogleFonts.cinzel(
                  color: _accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        Text(
          isClosed
              ? '🔒 Kapalı Mod'
              : (isMyTurn ? '🎯 Görevin:' : '🎯 $playerName\'in Görevi:'),
          style: GoogleFonts.cinzelDecorative(
            color: isClosed ? Colors.white54 : _textLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        ScaleTransition(
          scale: _cardAnimation,
          child: GameCard(
            category: task.category,
            content: isClosed ? '❓ İçeriği görmek için aç' : task.content,
            multiplier: task.multiplier,
          ),
        ),

        // TODO: Update game_card.dart styling if needed in another pass.
        // I will do that as a separate task, as GameCard might be widely used.
        const Spacer(),

        if (isClosed && isMyTurn) ...[
          // Kapalı modda — önce içeriği aç
          MedievalButton(
            label: 'Görevi Aç 🔓',
            icon: Icons.lock_open_rounded,
            backgroundColor: _accentGold.withOpacity(0.2),
            textColor: _accentGold,
            borderColor: _accentGold,
            onPressed: () => setState(() => _contentRevealed = true),
          ),
        ] else if (isMyTurn) ...[
          // Açık mod veya içerik açıldıktan sonra
          MedievalButton(
            label: 'Görevi Kabul Et',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: _accentCrimson,
            textColor: _textLight,
            borderColor: _accentGold,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
          ),
          const SizedBox(height: 12),
          MedievalButton(
            label: 'Pas Geç (Ceza: -${50 * (passStreak + 1)} puan)',
            icon: Icons.close_rounded,
            backgroundColor: Colors.black.withOpacity(0.6),
            textColor: Colors.white70,
            borderColor: Colors.redAccent.withOpacity(0.4),
            onPressed: _passTask,
            isLoading: _isPassing,
          ),
        ] else ...[
          Text(
            '$playerName\'ın karar vermesi bekleniyor...',
            style: GoogleFonts.cinzel(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}
