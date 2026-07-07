import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import 'widgets/player_spotlight.dart';
import 'widgets/spectator_strip.dart';
import 'widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/task_translations/task_translation_map.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/utils/toast_utils.dart';

/// Gösteri (Performing) Ekranı — Parti Temalı
class PerformingScreen extends ConsumerStatefulWidget {
  const PerformingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<PerformingScreen> createState() => _PerformingScreenState();
}

class _PerformingScreenState extends ConsumerState<PerformingScreen> {
  bool _isProceeding = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTicker;
  Duration _elapsed = Duration.zero;

  Future<void> _proceedToVoting() async {
    setState(() => _isProceeding = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .proceedToVoting(widget.gameId);
      if (mounted) {
        context.replace(
          '/voting',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
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
      if (mounted) setState(() => _isProceeding = false);
    }
  }

  void _toggleStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopwatchTicker?.cancel();
      setState(() => _elapsed = _stopwatch.elapsed);
      return;
    }
    _stopwatch.start();
    _stopwatchTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed = _stopwatch.elapsed);
    });
    setState(() => _elapsed = _stopwatch.elapsed);
  }

  void _resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _stopwatchTicker?.cancel();
    if (mounted) {
      setState(() => _elapsed = Duration.zero);
    } else {
      _elapsed = Duration.zero;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Widget _buildCornerStopwatch(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(_elapsed),
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              fontSize: isCompact ? 12 : 16,
            ),
          ),
          SizedBox(width: isCompact ? 4 : 8),
          IconButton(
            onPressed: _toggleStopwatch,
            visualDensity: VisualDensity.compact,
            constraints: BoxConstraints.tightFor(
              width: isCompact ? 24 : 30,
              height: isCompact ? 24 : 30,
            ),
            padding: EdgeInsets.zero,
            iconSize: isCompact ? 14 : 18,
            icon: Icon(
              _stopwatch.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.accent,
            ),
          ),
          IconButton(
            onPressed: _elapsed == Duration.zero ? null : _resetStopwatch,
            visualDensity: VisualDensity.compact,
            constraints: BoxConstraints.tightFor(
              width: isCompact ? 24 : 30,
              height: isCompact ? 24 : 30,
            ),
            padding: EdgeInsets.zero,
            iconSize: isCompact ? 14 : 18,
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopwatchTicker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(watchGameProvider(widget.gameId), (previous, next) {
      if (!mounted) return;
      final game = next.value;
      if (game == null) return;
      final prevStatus = previous?.value?.status;
      final prevTaskId = previous?.value?.currentTask?.id;
      final nextTaskId = game.currentTask?.id;

      if (prevTaskId != nextTaskId) {
        _resetStopwatch();
      }

      if (game.status == GameStatus.results && prevStatus != GameStatus.results) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(
              '/round-result',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });
        return;
      }
      if (game.status == GameStatus.finished && prevStatus != GameStatus.finished) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/game-over', extra: widget.roomCode);
        });
        return;
      }
      if (game.status == GameStatus.voting &&
          previous?.value?.status != GameStatus.voting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(
              '/voting',
              extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
            );
          }
        });
      }
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final user = ref.watch(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: ExitRoomButton(roomCode: widget.roomCode),
        actions: [
          if (roomAsync.value != null && gameAsync.value != null)
            TurnCounterBadge(
              currentRound: gameAsync.value!.currentRound,
              endConditionType: roomAsync.value!.endConditionType,
              endConditionValue: roomAsync.value!.endConditionValue,
            ),
        ],
      ),
      body: gameAsync.when(
        data: (game) {
          final l = AppLocalizations.of(context)!;
          if (game == null) {
            return TheaterLoadingScreen(message: l.waitingForPlayerCapital);
          }

          if (game.status == GameStatus.results) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go(
                  '/round-result',
                  extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
                );
              }
            });
            return TheaterLoadingScreen(message: l.calculatingScore);
          }
          if (game.status == GameStatus.voting) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go(
                  '/voting',
                  extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
                );
              }
            });
            return TheaterLoadingScreen(message: l.partyStarting);
          }
          if (game.status == GameStatus.finished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/game-over', extra: widget.roomCode);
            });
            return TheaterLoadingScreen(message: l.partyOver);
          }

          final isMyTurn = game.currentPlayerId == user?.uid;
          final task = game.currentTask;
          final isClosed = roomAsync.value?.visibility == RoomVisibility.closed;
          final players = playersAsync.value ?? [];
          final currentPlayer = players
              .where((p) => p.id == game.currentPlayerId)
              .firstOrNull;

          final size = MediaQuery.sizeOf(context);
          final isTiny = size.height <= 680;   // iPhone SE = 667px
          final veryShort = size.height <= 640;
          final isCompact = size.width <= 360 || isTiny;

          // vertical spacing that collapses on tiny screens
          final vGap = isTiny ? 6.0 : (veryShort ? 8.0 : 16.0);
          final hPad = isCompact ? 16.0 : 24.0;
          final cardVPad = isTiny ? 8.0 : (veryShort ? 12.0 : 20.0);
          final cardHPad = isTiny ? 14.0 : (veryShort ? 16.0 : 24.0);
          final headerVPad = isTiny ? 8.0 : (veryShort ? 10.0 : 16.0);
          final contentGap = isTiny ? 6.0 : (veryShort ? 8.0 : 16.0);

          return Stack(
            children: [
              Column(
                children: [
                  // ── Top padding ──
                  SizedBox(height: isTiny ? 4 : vGap),
                  // ── Player spotlight ──
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: ResponsiveWrapper(
                      maxWidth: 600,
                      padding: EdgeInsets.zero,
                      child: currentPlayer != null
                          ? PlayerSpotlight(
                              player: currentPlayer,
                              isMe: isMyTurn,
                              compact: isCompact,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(height: vGap),
                  // ── Task card – takes all remaining space ──
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: ResponsiveWrapper(
                        maxWidth: 600,
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // header
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: headerVPad),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.taskStarted,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.accent,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w900,
                                    fontSize: isTiny ? 14 : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // body – Expanded so it fills leftover height
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: cardHPad,
                                    vertical: cardVPad,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isMyTurn
                                            ? AppLocalizations.of(context)!.contentLabel
                                            : AppLocalizations.of(context)!.displayedContentLabel,
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: contentGap),
                                      Expanded(
                                        child: Center(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              isClosed && !isMyTurn
                                                  ? AppLocalizations.of(context)!.hiddenContentLabel
                                                  : (TaskTranslationMap.getTranslation(
                                                      task?.id ?? '',
                                                      task?.content ?? AppLocalizations.of(context)!.taskNoRole,
                                                      LocaleProvider.of(context).languageCode,
                                                    )),
                                              style: AppTextStyles.headlineMedium
                                                  .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: isTiny ? 16 : null,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: contentGap),
                                      if (isMyTurn) ...[
                                        Text(
                                          AppLocalizations.of(context)!.finishTaskInstruction,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            color: Colors.white54,
                                            fontStyle: FontStyle.italic,
                                            fontSize: isTiny ? 11 : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: contentGap),
                                        StageButton(
                                          label: AppLocalizations.of(context)!.finishTaskButton,
                                          icon: Icons.how_to_vote_rounded,
                                          backgroundColor: AppColors.primary,
                                          textColor: Colors.white,
                                          borderColor: AppColors.accent,
                                          onPressed: _proceedToVoting,
                                          isLoading: _isProceeding,
                                          compact: isCompact,
                                        ),
                                      ] else ...[
                                        const AppLoadingIndicator(size: 28),
                                        SizedBox(height: contentGap),
                                        Text(
                                          AppLocalizations.of(context)!.waitingForPerformance,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            color: Colors.white54,
                                            fontStyle: FontStyle.italic,
                                            fontSize: isTiny ? 11 : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Spectator strip ──
                  if (players.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: isTiny ? 4 : vGap,
                        bottom: isTiny ? 8 : (veryShort ? 12 : 20),
                      ),
                      child: SpectatorStrip(
                        players: players,
                        currentPlayerId: game.currentPlayerId,
                        myPlayerId: user?.uid,
                        compact: isCompact,
                      ),
                    ),
                ],
              ),
              // ── Corner stopwatch ──
              Positioned(
                right: 12,
                top: 10,
                child: SafeArea(
                  bottom: false,
                  child: _buildCornerStopwatch(isCompact),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          backgroundColor: Colors.transparent,
          body: TheaterLoadingScreen(message: AppLocalizations.of(context)!.waitingForPlayerCapital),
        ),
        error: (e, _) {
          final l = AppLocalizations.of(context)!;
          return Center(
            child: AsyncErrorView(
              message: l.loadFailed,
              detail: ErrorMessageUtils.formatUserError(e, l),
              secondaryLabel: l.goHome,
              onRetry: () => ref.invalidate(watchGameProvider(widget.gameId)),
              onSecondary: () => context.go('/home'),
            ),
          );
        },
      ),
    ),
    );
  }
}
