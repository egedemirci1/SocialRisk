import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import 'widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/game_error_scaffold.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:social_risk/l10n/app_localizations.dart';

/// Bekleme ekranı — Parti Temalı
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;

      if (next.hasValue && next.value == null) {
        // Oyun silinmiş (muhtemelen host çıktığı için)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ToastUtils.showError(context, AppLocalizations.of(context)!.gameEndedOrHostLeft);
            context.go('/home');
          }
        });
        return;
      }

      final nextGame = next.value;
      if (nextGame != null && previous?.value?.status != nextGame.status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (nextGame.status == GameStatus.finished) {
              context.replace('/game-over', extra: widget.roomCode);
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
            } else if (nextGame.status == GameStatus.playing ||
                nextGame.status == GameStatus.choosingDifficulty) {
              // Tüm oyuncular task ekranına yönlendirilir
              context.replace(
                '/task',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            } else if (nextGame.status == GameStatus.performing) {
              context.replace(
                '/performing',
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
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
              message: AppLocalizations.of(context)!.preparingParty,
            ),
          );
        }

        final players = playersAsync.value ?? [];
        final currentPlayer = players
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;

        final isHost =
            roomAsync.value?.hostId == ref.read(currentUserProvider)?.uid;
        if (isHost &&
            currentPlayer == null &&
            game.status != GameStatus.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(gameControllerProvider.notifier).nextTurn(widget.gameId);
            }
          });
        }

        final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.leftPlayer;
        final sh = MediaQuery.sizeOf(context).height;
        final compact = sh < 700;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: ExitRoomButton(roomCode: widget.roomCode),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 32),
              child: Container(
                padding: EdgeInsets.all(compact ? 20 : 32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(compact ? 16 : 24),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: compact ? 64 : 100,
                        height: compact ? 64 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.celebration_rounded,
                            color: AppColors.accent,
                            size: compact ? 32 : 48,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 32),
                    Text(
                      AppLocalizations.of(context)!.waitingQueue,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        letterSpacing: 4,
                        fontSize: compact ? 16 : 20,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    Text(
                      game.status == GameStatus.performing
                          ? AppLocalizations.of(context)!.playerIsPerforming(playerName)
                          : AppLocalizations.of(context)!.playerIsDecidingRole(playerName),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: compact ? 24 : 48),
                    Container(
                      padding: EdgeInsets.all(compact ? 10 : 16),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.votingWillStartWhenTurnEnds,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: TheaterLoadingScreen(message: AppLocalizations.of(context)!.preparingParty),
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
