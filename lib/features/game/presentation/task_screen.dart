import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/data/task_translations/task_translation_map.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/widgets/common/game_error_scaffold.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/game/spin_wheel.dart' hide AnimatedBuilder;
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../core/audio/audio_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';
import 'widgets/turn_counter_badge.dart';

part 'task_screen.builders.part.dart';
part 'task_screen.builders_actions.part.dart';
part 'task_screen.widgets.part.dart';

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

  void _setAutoPickingSingleCategory(bool value) {
    setState(() => _isAutoPickingSingleCategory = value);
  }

  void _setAutoPickFailed(bool value) {
    setState(() => _autoPickFailed = value);
  }

  void _revealContent() {
    setState(() => _contentRevealed = true);
  }

  void _onWheelResult(String category) {
    final game = ref.read(watchGameProvider(widget.gameId)).value;
    final currentUser = ref.read(currentUserProvider);
    final currentPlayerId = game?.currentPlayerId;
    final currentUserId = currentUser?.uid;
    
    if (currentPlayerId == currentUserId) {
      ref
          .read(gameControllerProvider.notifier)
          .assignTaskByCategory(gameId: widget.gameId, category: category);
    }
  }

  Future<void> _acceptTask() async {
    setState(() => _isAccepting = true);
    try {
      await ref.read(gameControllerProvider.notifier).acceptTask(widget.gameId);
      
      // Economy modunda kabul ettikten sonra next turn yap
      if (mounted) {
        final game = ref.read(watchGameProvider(widget.gameId)).value;
        if (game != null && game.categoryPickOrder.isEmpty) {
          await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
        }
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ToastUtils.showError(
          context,
          l.error(ErrorMessageUtils.formatUserError(e, l)),
        );
      }
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
      
      // Economy modunda reddettikten sonra next turn yap
      if (mounted) {
        final game = ref.read(watchGameProvider(widget.gameId)).value;
        if (game != null && game.categoryPickOrder.isEmpty) {
          await ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
        }
        setState(() => _contentRevealed = false);
        _cardController.reset();
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ToastUtils.showError(
          context,
          l.error(ErrorMessageUtils.formatUserError(e, l)),
        );
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

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TheaterLoadingScreen(
              message: AppLocalizations.of(context)!.partyStarting,
            ),
          );
        }

        final task = game.currentTask;
        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;
        final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
        final players = playersAsync.value ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

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
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(message: AppLocalizations.of(context)!.partyStarting),
      ),
      error: (e, _) {
        final l = AppLocalizations.of(context)!;
        return GameErrorScaffold(
          roomCode: widget.roomCode,
          message: l.loadFailed,
          detail: ErrorMessageUtils.formatUserError(e, l),
          goHomeLabel: l.goHome,
          onRetry: () => ref.invalidate(watchGameProvider(widget.gameId)),
          onGoHome: () => context.go('/home'),
        );
      },
    ),
    );
  }
}
