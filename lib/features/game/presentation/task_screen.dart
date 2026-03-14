import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/game/spin_wheel.dart' hide AnimatedBuilder;
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
  bool _isAutoPickingSingleCategory = false;
  bool _autoPickFailed = false;

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
      if (mounted) {
        setState(() => _contentRevealed = false);
        _cardController.reset();
      }
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      final prev = previous?.value;
      final nextG = next.value;
      if (prev?.currentTask == null && nextG?.currentTask != null) {
        if (mounted) {
          setState(() => _contentRevealed = false);
          _cardController.forward(from: 0.0);
        }
      }
      if (nextG != null && prev?.status != nextG.status) {
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

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
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

        if (task != null &&
            !_cardController.isAnimating &&
            _cardController.value == 0.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _cardController.forward(from: 0.0);
          });
        }

        if (game.status == GameStatus.choosingDifficulty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace(
                '/difficulty',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
        } else if (game.status == GameStatus.voting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace(
                '/voting',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
        } else if (game.status == GameStatus.performing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace(
                '/performing',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
        } else if (game.status == GameStatus.results) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace(
                '/round-result',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
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
                                      game,
                                      game.passStreak,
                                      task,
                                      roomAsync.value?.visibility ?? RoomVisibility.open,
                                      isMyTurn,
                                      playerName,
                                    )
                                  : (roomAsync.value?.mode == GameMode.economy
                                        ? _buildEconomyRedirect(
                                            game: game,
                                            categories: roomAsync.value?.categories ?? const [],
                                            isMyTurn: isMyTurn,
                                            myUserId: user?.uid,
                                          )
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


  Widget _buildTopTitleCard({
    required String badge,
    required String title,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surface.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              badge,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
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
        _buildTopTitleCard(
          badge: 'PARTİ BAŞLIYOR',
          title: '🎡 Görevini Belirle',
          subtitle: 'Sıran gelmeden önce görevini seç...',
        ),
        const SizedBox(height: 44),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEconomyRedirect({
    required GameEntity game,
    required List<String> categories,
    required bool isMyTurn,
    required String? myUserId,
  }) {
    final isSingleCategory = categories.length == 1;

    if (isSingleCategory) {
      final selectedCategory = categories.first;
      final canAutoPick =
          isMyTurn &&
          myUserId != null &&
          !_isAutoPickingSingleCategory &&
          !_autoPickFailed &&
          game.currentTask == null &&
          game.selectedCategory == null &&
          game.status == GameStatus.playing;

      if (canAutoPick) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted || _isAutoPickingSingleCategory) return;
          setState(() => _isAutoPickingSingleCategory = true);
          try {
            await ref.read(gameControllerProvider.notifier).pickCategoryEconomy(
                  gameId: widget.gameId,
                  playerId: myUserId,
                  category: selectedCategory,
                );
          } catch (_) {
            if (mounted) setState(() => _autoPickFailed = true);
          } finally {
            if (mounted) {
              setState(() => _isAutoPickingSingleCategory = false);
            }
          }
        });
      }

      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.replace(
        '/economy-pick',
        extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
      );
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildTaskView(
    GameEntity game,
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
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  'PARTİ BAŞLIYOR',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AppColors.accentGradient.begin,
                          end: AppColors.accentGradient.end,
                          colors: AppColors.accentGradient.colors
                              .map((c) => c.withValues(alpha: 0.15))
                              .toList(),
                        ),
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

                    const SizedBox(height: 26),
                    _buildTopTitleCard(
                      badge: isClosed ? 'GİZLİ TUR' : 'GÖREV',
                      title: isClosed
                          ? 'Sıradaki Görev Gizli'
                          : (isMyTurn ? 'İçeriğin Burada:' : '${playerName} içeriği:'),
                    ),
                    const SizedBox(height: 26),
                    ScaleTransition(
                      scale: _cardAnimation,
                      child: GameCard(
                        category: task.category,
                        content: isClosed
                            ? 'Mevcut görevi görmek için kartı aç...'
                            : task.content,
                        points: (game.mode == GameMode.economy 
                                  ? (game.categoryMarketValues[task.category] ?? 10) 
                                  : 10) * task.multiplier,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                        label: 'Görevi Başlat',
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        borderColor: AppColors.accent,
                        onPressed: _acceptTask,
                        isLoading: _isAccepting,
                      ),
                      const SizedBox(height: 12),
                      _AnimatedPassButton(
                        passStreak: passStreak,
                        isPassing: _isPassing,
                        onPass: _passTask,
                      ),
                    ] else
                      Text(
                        '$playerName içeriği okuyor...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white30,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

class _AnimatedPassButton extends StatefulWidget {
  final int passStreak;
  final bool isPassing;
  final VoidCallback onPass;

  const _AnimatedPassButton({
    required this.passStreak,
    required this.isPassing,
    required this.onPass,
  });

  @override
  State<_AnimatedPassButton> createState() => _AnimatedPassButtonState();
}

class _AnimatedPassButtonState extends State<_AnimatedPassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;
  bool _isWarningSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isPassing) return;
    
    if (!_isWarningSelected) {
      HapticFeedback.mediumImpact();
      setState(() => _isWarningSelected = true);
      _controller.forward(from: 0.0);
    } else {
      HapticFeedback.heavyImpact();
      widget.onPass();
      setState(() => _isWarningSelected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: OutlinedButton(
        onPressed: widget.isPassing ? null : _handlePress,
        style: OutlinedButton.styleFrom(
          foregroundColor: _isWarningSelected ? Colors.redAccent : Colors.red.withValues(alpha: 0.7),
          side: BorderSide(
            color: _isWarningSelected ? Colors.redAccent : Colors.white24,
            width: _isWarningSelected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _isWarningSelected ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Text(
          _isWarningSelected
              ? 'EMİN MİSİN? (-${50 * (widget.passStreak + 1)} Puan)'
              : 'Görevi Reddet (-${50 * (widget.passStreak + 1)} Puan)',
          style: AppTextStyles.labelSmall.copyWith(
            color: _isWarningSelected ? Colors.redAccent : Colors.white70,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

