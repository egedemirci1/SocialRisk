import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';
import '../../game/domain/game_entity.dart';
import '../../economy/providers/economy_provider.dart';
import '../../game/presentation/widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/common/game_error_scaffold.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../core/data/task_translations/task_translation_map.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';

part 'voting_screen.builders.part.dart';
part 'voting_screen.widgets.part.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor (Parti Temalı).
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key, required this.gameId, required this.roomCode});

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  bool _isProcessing = false;
  bool _hasProcessed = false;
  bool _hasVoted = false;
  Timer? _finalizeFallbackTimer;

  Duration get _voteDuration => GameConstants.voteDuration;

  @override
  void initState() {
    super.initState();
    _finalizeFallbackTimer = Timer(_voteDuration + const Duration(seconds: 3), () {
      if (mounted) _tryFinalizeWhenReady();
    });
  }

  @override
  void dispose() {
    _finalizeFallbackTimer?.cancel();
    super.dispose();
  }

  void _tryFinalizeWhenReady() {
    if (_isProcessing || _hasProcessed || !mounted) return;

    final game = ref.read(watchGameProvider(widget.gameId)).value;
    if (game == null || game.status != GameStatus.voting) return;

    final votes = ref.read(watchVotesProvider(widget.gameId)).value;
    final players = ref.read(watchPlayersProvider(widget.roomCode)).value ?? [];
    final activePlayerIds = players.map((p) => p.id).toList();
    if (activePlayerIds.isEmpty) return;

    final allVoted = votes != null &&
        activePlayerIds.every(
          (id) => id == game.currentPlayerId || votes.containsKey(id),
        );

    if (allVoted) {
      _processResults();
    }
  }

  Future<void> _processResults() async {
    if (_isProcessing || _hasProcessed) return;
    _hasProcessed = true;
    setState(() => _isProcessing = true);

    try {
      final voteCtrl = ref.read(voteControllerProvider.notifier);
      await voteCtrl.finalizeVotingRound(gameId: widget.gameId);

      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        _hasProcessed = false;
        setState(() => _isProcessing = false);
        final l = AppLocalizations.of(context)!;
        ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final user = ref.watch(currentUserProvider);
    final votesAsync = ref.watch(watchVotesProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!mounted) return;
      final prevStatus = previous?.value?.status;
      final currentStatus = next.value?.status;
      if (currentStatus == GameStatus.results && prevStatus != GameStatus.results) {
        context.go(
          '/round-result',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      } else if (currentStatus == GameStatus.finished && prevStatus != GameStatus.finished) {
        context.go('/game-over', extra: widget.roomCode);
      }
    });

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: gameAsync.when(
      data: (game) {
        final l = AppLocalizations.of(context)!;
        if (game == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TheaterLoadingScreen(message: l.calculatingScore),
          );
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
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TheaterLoadingScreen(message: l.calculatingScore),
          );
        } else if (game.status == GameStatus.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/game-over', extra: widget.roomCode);
          });
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TheaterLoadingScreen(message: l.partyOver),
          );
        }

        final activePlayers = playersAsync.value ?? [];
        final performer = activePlayers
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final performerName = performer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

        final activePlayerIds = activePlayers.map((p) => p.id).toList();
        final allVoted =
            votesAsync.value != null &&
            activePlayerIds.isNotEmpty &&
            activePlayerIds.every(
              (id) =>
                  id == game.currentPlayerId ||
                  votesAsync.value!.containsKey(id),
            );

        final isMyTurn = game.currentPlayerId == user?.uid;

        if (allVoted && !_isProcessing && !_hasProcessed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isProcessing && !_hasProcessed) {
              _processResults();
            }
          });
        }

        final difficulty = game.currentTask?.difficulty ?? 'medium';
        Color glowColor;
        if (difficulty == 'hard') {
          glowColor = AppColors.error.withValues(alpha: 0.15);
        } else if (difficulty == 'easy') {
          glowColor = AppColors.votePositive.withValues(alpha: 0.15);
        } else {
          glowColor = AppColors.voteNeutral.withValues(alpha: 0.15);
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                glowColor,
                AppColors.background,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppLocalizations.of(context)!.votingTitle,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.accent,
                  fontSize: 34, // Increased from 26
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5, // Slightly reduced for better fit
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Transform.scale(
              scale: 0.85, // Scale down the exit button
              child: ExitRoomButton(roomCode: widget.roomCode),
            ),
            actions: [
              if (roomAsync.value != null)
                TurnCounterBadge(
                  currentRound: game.currentRound,
                  endConditionType: roomAsync.value!.endConditionType,
                  endConditionValue: roomAsync.value!.endConditionValue,
                ),
              IconButton(
                visualDensity: VisualDensity.compact, // Make it more compact
                icon: const Icon(
                  Icons.leaderboard_rounded,
                  color: AppColors.accent,
                  size: 22, // Slightly smaller
                ),
                onPressed: () =>
                    ScoreboardBottomSheet.show(context, widget.roomCode),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _FloatingPsychologicalTexts(),
                ),
                ResponsiveWrapper(
                  maxWidth: 600,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _VisualCountdownTimer(
                        duration: _voteDuration,
                        onElapsed: _tryFinalizeWhenReady,
                      ),
                      
                      // 1. FIXED HEADER: Avatar and Name
                      Builder(
                        builder: (context) {
                          final sh = MediaQuery.sizeOf(context).height;
                          final isSmall = sh < 700;
                          final avatarR = isSmall ? 32.0 : 40.0; // Reduced radius for better space
                          return Padding(
                            padding: EdgeInsets.only(top: isSmall ? 8 : 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlayerAvatar(
                                  uid: game.currentPlayerId,
                                  displayName: performerName,
                                  radius: avatarR,
                                ),
                                SizedBox(height: isSmall ? 4 : 8),
                                Text(
                                  performerName.toUpperCase(),
                                  style: AppTextStyles.displayMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: isSmall ? 20 : 24,
                                    letterSpacing: 2,
                                  ),
                                ),
                                // Ünvan gösterimi
                                Builder(
                                  builder: (context) {
                                    final profile = ref
                                        .watch(
                                          watchUserProfileProvider(game.currentPlayerId),
                                        )
                                        .value;
                                    if (profile?.activeTitle == null) {
                                      return const SizedBox.shrink();
                                    }
                                    final cosmetics =
                                        ref.watch(fetchCosmeticsProvider).value ?? [];
                                    final titleItem = cosmetics
                                        .where((c) => c.id == profile!.activeTitle)
                                        .firstOrNull;
                                    if (titleItem == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${titleItem.imageUrl} ${titleItem.name}',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.accent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.playerPerformed,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white54,
                                    fontSize: isSmall ? 11 : 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // 2. CENTERED CONTENT: Challenge text
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      TaskTranslationMap.getTranslation(
                                        game.currentTask?.id ?? '',
                                        game.currentTask?.content ?? "",
                                        LocaleProvider.of(context).languageCode,
                                      ),
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        fontSize: MediaQuery.sizeOf(context).height < 700 ? 18 : 22,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 3. FIXED FOOTER: Voting Panel
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          MediaQuery.sizeOf(context).height < 700 ? 12 : 24,
                        ),
                        child: _isProcessing
                            ? _buildProcessingIndicator()
                            : isMyTurn
                                ? _buildWaitingForOthers()
                                : _hasVoted
                                    ? _buildVotedStatus()
                                    : VotingPanel(
                                        timeLimit: _voteDuration,
                                        onVote: (value, {timedOut = false}) async {
                                          if (user == null) return;
                                          setState(() => _hasVoted = true);
                                          if (timedOut && mounted) {
                                            ToastUtils.showError(
                                              context,
                                              AppLocalizations.of(context)!.voteTimeoutPenalty,
                                            );
                                          }
                                          try {
                                            await ref
                                                .read(voteControllerProvider.notifier)
                                                .castVote(
                                                  gameId: widget.gameId,
                                                  voterId: user.uid,
                                                  value: VoteValue.values.byName(value),
                                                  timedOut: timedOut,
                                                );
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() => _hasVoted = false);
                                              final l = AppLocalizations.of(context)!;
                                              ToastUtils.showError(
                                                context,
                                                l.error(ErrorMessageUtils.formatUserError(e, l)),
                                              );
                                            }
                                          }
                                        },
                                      ),
                      ),
                    ],
                  ),
                ),
      ],
    ),
  ),
));
      },
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: TheaterLoadingScreen(message: AppLocalizations.of(context)!.calculatingScore),
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