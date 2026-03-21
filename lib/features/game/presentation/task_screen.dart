import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/game/spin_wheel.dart' hide AnimatedBuilder;
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../core/audio/audio_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/domain/room_entity.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';
import 'widgets/turn_counter_badge.dart';

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
    // Oyun başladığında menü loop'unu durdur.
    ref.read(audioServiceProvider).stopMusic();
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
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid == null) return;
      await ref.read(gameControllerProvider.notifier).passTask(
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
    final layout = _TaskLayoutMetrics.from(context);
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      final prev = previous?.value;
      final nextGame = next.value;
      if (prev?.currentTask == null && nextGame?.currentTask != null) {
        if (mounted) {
          setState(() => _contentRevealed = false);
          _cardController.forward(from: 0.0);
        }
      }
      if (nextGame != null && prev?.status != nextGame.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (nextGame.status == GameStatus.choosingDifficulty) {
            context.replace(
              '/difficulty',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (nextGame.status == GameStatus.performing) {
            context.replace(
              '/performing',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (nextGame.status == GameStatus.voting) {
            context.replace(
              '/voting',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (nextGame.status == GameStatus.results) {
            context.replace(
              '/round-result',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          } else if (nextGame.status == GameStatus.finished) {
            context.replace('/game-over', extra: widget.roomCode);
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
        final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
        final players = playersAsync.value ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final playerName = currentPlayer?.name ?? 'Oyuncu';

        if (task != null &&
            !_cardController.isAnimating &&
            _cardController.value == 0.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _cardController.forward(from: 0.0);
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
          body: ResponsiveWrapper(
            padding: EdgeInsets.zero,
            child: SafeArea(
              top: false,
              bottom: true,
              minimum: EdgeInsets.symmetric(
                horizontal: layout.horizontalPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = min(
                    max(constraints.maxWidth * 0.78, 320.0),
                    460.0,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: contentWidth,
                            child: task != null
                                ? _buildTaskView(
                                    game: game,
                                    passStreak: game.passStreak,
                                    task: task,
                                    visibility: roomAsync.value?.visibility ??
                                        RoomVisibility.open,
                                    isMyTurn: isMyTurn,
                                    playerName: playerName,
                                    layout: layout,
                                  )
                                : (roomAsync.value?.mode == GameMode.economy
                                    ? _buildEconomyRedirect(
                                        game: game,
                                        categories:
                                            roomAsync.value?.categories ?? const [],
                                        isMyTurn: isMyTurn,
                                        myUserId: user?.uid,
                                      )
                                    : _buildWheelView(
                                        isMyTurn: isMyTurn,
                                        playerName: playerName,
                                        currentPlayer: currentPlayer,
                                        categories:
                                            roomAsync.value?.categories ?? const [],
                                        layout: layout,
                                        contentWidth: contentWidth,
                                      )),
                          ),
                        ),
                      ),
                      if (players.isNotEmpty)
                        SizedBox(
                          width: contentWidth,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: layout.spectatorTopSpacing,
                              bottom: layout.bottomSpacing,
                            ),
                            child: SpectatorStrip(
                              players: players,
                              currentPlayerId: game.currentPlayerId,
                              myPlayerId: user?.uid,
                              compact: layout.isCompact,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
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
    required _TaskLayoutMetrics layout,
    String? subtitle,
    bool showSubtitle = true,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        layout.titleCardHorizontalPadding,
        layout.titleCardVerticalPadding,
        layout.titleCardHorizontalPadding,
        layout.titleCardBottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.96),
            AppColors.surface.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(layout.titleCardRadius),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.badgeHorizontalPadding,
              vertical: layout.badgeVerticalPadding,
            ),
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
                letterSpacing: 1.1,
                fontSize: layout.badgeFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: layout.titleGap),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: layout.titleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null && showSubtitle) ...[
            SizedBox(height: layout.subtitleGap),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
                fontSize: layout.subtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWheelView({
    required bool isMyTurn,
    required String playerName,
    required dynamic currentPlayer,
    required List<String> categories,
    required _TaskLayoutMetrics layout,
    required double contentWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final isVeryShort = screenHeight <= 686 || availableHeight < 610;
        final isDense = isVeryShort || availableHeight < 650;
        final topGap = isVeryShort
            ? 2.0
            : max(4.0, availableHeight * 0.012);
        final sectionGap = isVeryShort
            ? 4.0
            : max(6.0, availableHeight * 0.014);
        final wheelGap = isVeryShort
            ? 6.0
            : max(8.0, availableHeight * 0.018);
        final bottomGap = isVeryShort
            ? 0.0
            : max(2.0, availableHeight * 0.006);
        final contentHeight =
            max(0.0, availableHeight - topGap - sectionGap - wheelGap - bottomGap);
        final playerHeight =
            currentPlayer != null ? contentHeight * (isVeryShort ? 0.21 : 0.25) : 0.0;
        final titleHeight = contentHeight * (isVeryShort ? 0.18 : 0.23);
        final wheelHeight = max(0.0, contentHeight - playerHeight - titleHeight);
        final wheelSize = min(
          layout.wheelSize,
          max(isVeryShort ? 148.0 : 160.0, wheelHeight * (isDense ? 0.86 : 0.8)),
        );

        return Column(
          children: [
            SizedBox(height: topGap),
            if (currentPlayer != null)
              SizedBox(
                height: playerHeight,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: contentWidth * (isVeryShort ? 0.56 : 0.62),
                      child: PlayerSpotlight(
                        player: currentPlayer,
                        isMe: isMyTurn,
                        compact: layout.isCompact || isDense,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: sectionGap),
            SizedBox(
              height: titleHeight,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: contentWidth,
                    child: _buildTopTitleCard(
                      badge: 'PARTI BASLIYOR',
                                  title: 'Görevini Belirle',
                                  subtitle: 'Görevini almak için çarkı çevir...',
                      showSubtitle: !isVeryShort,
                      layout: layout,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: wheelGap),
            SizedBox(
              height: wheelHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: SpinWheel(
                  spinningTarget: ref
                      .watch(watchGameProvider(widget.gameId))
                      .value
                      ?.spinningTarget,
                  canSpin: isMyTurn,
                  playerName: playerName,
                  categories: categories,
                  compact: layout.isCompact || isDense,
                  maxWheelSize: wheelSize,
                  onSpinRequest: () {
                    if (categories.isEmpty) return;
                    // Web: ses jest zincirinde kalmalı; Firestore dönüşünde çalınca engellenir.
                    ref.read(audioServiceProvider).playSfx(AppSfx.wheelSpinStart);
                    final randomCat = categories[_random.nextInt(categories.length)];
                    ref.read(gameControllerProvider.notifier).setSpinningTarget(
                          gameId: widget.gameId,
                          target: randomCat,
                        );
                  },
                  onSpinComplete: _onWheelResult,
                ),
              ),
            ),
            SizedBox(height: bottomGap),
          ],
        );
      },
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

  Widget _buildTaskView({
    required GameEntity game,
    required int passStreak,
    required dynamic task,
    required RoomVisibility visibility,
    required bool isMyTurn,
    required String playerName,
    required _TaskLayoutMetrics layout,
  }) {
    final isClosed = visibility == RoomVisibility.closed && !_contentRevealed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewHeight = constraints.maxHeight;
        final topGap = max(4.0, viewHeight * 0.01);
        final headerHeight = layout.isCompact ? 54.0 : 62.0;
        final innerGap = layout.isCompact ? 10.0 : 14.0;
        final actionHeight = isClosed && isMyTurn
            ? (layout.isCompact ? 54.0 : 60.0)
            : (isMyTurn ? (layout.isCompact ? 110.0 : 124.0) : 26.0);
        final contentHeight = max(
          0.0,
          viewHeight -
              topGap -
              headerHeight -
              (layout.taskCardPadding * 2) -
              actionHeight -
              (innerGap * 4),
        );
        final categoryHeight = layout.isCompact ? 34.0 : 38.0;
        final titleHeight = max(74.0, contentHeight * 0.2);
        final cardHeight = max(
          150.0,
          contentHeight - categoryHeight - titleHeight,
        );

        final int cardPoints = game.mode == GameMode.economy
            ? (((game.hotCategory == task.category
                            ? 12
                            : (game.categoryMarketValues[task.category] ?? 10)) *
                        task.multiplier)
                    .toInt())
            : (10 * task.multiplier).toInt();

        return Column(
          children: [
            SizedBox(height: topGap),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(layout.titleCardRadius),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.15),
                  ),
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
                      padding: EdgeInsets.symmetric(
                        vertical: layout.headerVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'PARTI BASLIYOR',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(layout.taskCardPadding),
                        child: Column(
                          children: [
                            SizedBox(
                              height: categoryHeight,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: layout.categoryBadgeHorizontalPadding,
                                      vertical: layout.categoryBadgeVerticalPadding,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: AppColors.accentGradient.begin,
                                        end: AppColors.accentGradient.end,
                                        colors: AppColors.accentGradient.colors
                                            .map((c) => c.withValues(alpha: 0.15))
                                            .toList(),
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      'Kategori: ${task.category}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: layout.badgeFontSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            SizedBox(
                              height: titleHeight,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: layout.contentWidth * 0.8,
                                    child: _buildTopTitleCard(
                          badge: isClosed ? 'GİZLİ TUR' : 'GÖREV',
                                      title: isClosed
                                  ? 'Sıradaki Görev Gizli'
                                          : (isMyTurn
                                      ? 'İçeriğin Burada:'
                                              : '$playerName İçeriği:'),
                                      layout: layout,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            Expanded(
                              child: Center(
                                child: ScaleTransition(
                                  scale: _cardAnimation,
                                  child: SizedBox(
                                    height: cardHeight,
                                    child: GameCard(
                                      category: task.category,
                                      content: isClosed
                                  ? 'Mevcut görevi görmek için kartı aç...'
                                          : task.content,
                                      points: cardPoints,
                                      compact: layout.isCompact,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: innerGap),
                            SizedBox(
                              height: actionHeight,
                              child: _buildTaskActionSection(
                                isClosed: isClosed,
                                isMyTurn: isMyTurn,
                                playerName: playerName,
                                passStreak: passStreak,
                                layout: layout,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskActionSection({
    required bool isClosed,
    required bool isMyTurn,
    required String playerName,
    required int passStreak,
    required _TaskLayoutMetrics layout,
  }) {
    if (isClosed && isMyTurn) {
      return Center(
        child: StageButton(
                                label: 'Görevi Aç',
          backgroundColor: AppColors.accent,
          textColor: Colors.black,
          borderColor: AppColors.accent,
          onPressed: () => setState(() => _contentRevealed = true),
          compact: layout.isCompact,
        ),
      );
    }

    if (isMyTurn) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StageButton(
                        label: 'Görevi Başlat',
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            borderColor: AppColors.accent,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
            compact: layout.isCompact,
          ),
          SizedBox(height: layout.passButtonGap),
          _AnimatedPassButton(
            passStreak: passStreak,
            isPassing: _isPassing,
            onPass: _passTask,
            compact: layout.isCompact,
          ),
        ],
      );
    }

    return Center(
      child: Text(
        '$playerName İçeriği okuyor...',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white30,
          fontStyle: FontStyle.italic,
          fontSize: layout.subtitleFontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AnimatedPassButton extends StatefulWidget {
  const _AnimatedPassButton({
    required this.passStreak,
    required this.isPassing,
    required this.onPass,
    required this.compact,
  });

  final int passStreak;
  final bool isPassing;
  final VoidCallback onPass;
  final bool compact;

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
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
          foregroundColor: _isWarningSelected
              ? Colors.redAccent
              : Colors.red.withValues(alpha: 0.7),
          side: BorderSide(
            color: _isWarningSelected ? Colors.redAccent : Colors.white24,
            width: _isWarningSelected ? 2 : 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 18 : 24,
            vertical: widget.compact ? 10 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isWarningSelected
              ? 'EMIN MISIN? (-50 Puan)'
                    : 'Görevi Reddet (-50 Puan)',
          style: AppTextStyles.labelSmall.copyWith(
            color: _isWarningSelected ? Colors.redAccent : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: widget.compact ? 10 : 12,
          ),
        ),
      ),
    );
  }
}

class _TaskLayoutMetrics {
  const _TaskLayoutMetrics({
    required this.isCompact,
    required this.horizontalPadding,
    required this.contentWidth,
    required this.wheelViewHeight,
    required this.taskViewHeight,
    required this.topSpacing,
    required this.wheelGap,
    required this.sectionGap,
    required this.bottomSpacing,
    required this.spectatorTopSpacing,
    required this.titleCardHorizontalPadding,
    required this.titleCardVerticalPadding,
    required this.titleCardBottomPadding,
    required this.titleCardRadius,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.badgeFontSize,
    required this.titleGap,
    required this.titleFontSize,
    required this.subtitleGap,
    required this.subtitleFontSize,
    required this.headerVerticalPadding,
    required this.taskCardPadding,
    required this.categoryBadgeHorizontalPadding,
    required this.categoryBadgeVerticalPadding,
    required this.buttonGap,
    required this.passButtonGap,
    required this.wheelSize,
    required this.spectatorAreaHeight,
    required this.gameCardHeight,
  });

  final bool isCompact;
  final double horizontalPadding;
  final double contentWidth;
  final double wheelViewHeight;
  final double taskViewHeight;
  final double topSpacing;
  final double wheelGap;
  final double sectionGap;
  final double bottomSpacing;
  final double spectatorTopSpacing;
  final double titleCardHorizontalPadding;
  final double titleCardVerticalPadding;
  final double titleCardBottomPadding;
  final double titleCardRadius;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double badgeFontSize;
  final double titleGap;
  final double titleFontSize;
  final double subtitleGap;
  final double subtitleFontSize;
  final double headerVerticalPadding;
  final double taskCardPadding;
  final double categoryBadgeHorizontalPadding;
  final double categoryBadgeVerticalPadding;
  final double buttonGap;
  final double passButtonGap;
  final double wheelSize;
  final double spectatorAreaHeight;
  final double gameCardHeight;

  factory _TaskLayoutMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 400 || size.height < 820;
    final isShort = size.height < 760;

    return _TaskLayoutMetrics(
      isCompact: isCompact,
      horizontalPadding: isCompact ? 14 : 24,
      contentWidth: isCompact ? 340 : 380,
      wheelViewHeight: isShort ? 590 : (isCompact ? 640 : 700),
      taskViewHeight: isShort ? 660 : (isCompact ? 710 : 790),
      topSpacing: isShort ? 10 : (isCompact ? 14 : 24),
      wheelGap: isShort ? 18 : (isCompact ? 24 : 44),
      sectionGap: isShort ? 10 : (isCompact ? 14 : 26),
      bottomSpacing: isShort ? 8 : (isCompact ? 12 : 24),
      spectatorTopSpacing: isShort ? 4 : 8,
      titleCardHorizontalPadding: isShort ? 14 : (isCompact ? 18 : 22),
      titleCardVerticalPadding: isShort ? 14 : (isCompact ? 18 : 22),
      titleCardBottomPadding: isShort ? 12 : (isCompact ? 16 : 20),
      titleCardRadius: isCompact ? 18 : 20,
      badgeHorizontalPadding: isShort ? 10 : (isCompact ? 12 : 14),
      badgeVerticalPadding: isShort ? 5 : (isCompact ? 6 : 7),
      badgeFontSize: isShort ? 9 : (isCompact ? 10 : 12),
      titleGap: isShort ? 8 : (isCompact ? 12 : 16),
      titleFontSize: isShort ? 16 : (isCompact ? 18 : 20),
      subtitleGap: isShort ? 6 : (isCompact ? 8 : 10),
      subtitleFontSize: isShort ? 11.5 : (isCompact ? 13 : 14),
      headerVerticalPadding: isShort ? 10 : (isCompact ? 12 : 16),
      taskCardPadding: isShort ? 16 : (isCompact ? 18 : 24),
      categoryBadgeHorizontalPadding: isShort ? 10 : (isCompact ? 12 : 16),
      categoryBadgeVerticalPadding: isShort ? 5 : (isCompact ? 6 : 8),
      buttonGap: isShort ? 16 : (isCompact ? 20 : 32),
      passButtonGap: isShort ? 8 : (isCompact ? 10 : 12),
      wheelSize: isShort ? 260 : (isCompact ? 270 : 280),
      spectatorAreaHeight: isShort ? 78 : (isCompact ? 90 : 110),
      gameCardHeight: (size.height * (isShort ? 0.36 : 0.34))
          .clamp(220.0, isCompact ? 290.0 : 340.0)
          .toDouble(),
    );
  }
}



