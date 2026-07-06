import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/utils/error_message_utils.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/buttons/leave_room_button.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/social_risk_logo.dart';
import '../../admin/providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';

part 'round_result_screen.builders.part.dart';
part 'round_result_screen.widgets.part.dart';

class RoundResultScreen extends ConsumerStatefulWidget {
  const RoundResultScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends ConsumerState<RoundResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _voteOutcomeSfxPlayed = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      ref.read(audioServiceProvider).playSfx(AppSfx.roundResultShow);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  /// `lastRoundMood`: dislike → failed; like / neutral → success (aynı dosya).
  void _tryPlayVoteOutcomeSfx(GameEntity game) {
    if (_voteOutcomeSfxPlayed) return;
    final mood = game.lastRoundMood;
    if (mood == null) return;
    _voteOutcomeSfxPlayed = true;
    final audio = ref.read(audioServiceProvider);
    if (mood == 'dislike') {
      audio.playSfx(AppSfx.voteResultDislike);
    } else {
      audio.playSfx(AppSfx.voteResultLike);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final metrics = _RoundResultMetrics.from(context);
    final currentUser = ref.watch(currentUserProvider);

    ref.listen<AsyncValue<GameEntity?>>(watchGameProvider(widget.gameId), (
      previous,
      next,
    ) {
      if (!context.mounted) return;
      next.whenData((game) {
        if (game != null) {
          _tryPlayVoteOutcomeSfx(game);
        }
      });

      final prevStatus = previous?.value?.status;
      final currentStatus = next.value?.status;

      if (currentStatus == GameStatus.playing ||
          currentStatus == GameStatus.choosingDifficulty) {
        context.go(
          '/task',
          extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
        );
      } else if (currentStatus == GameStatus.finished &&
          prevStatus != GameStatus.finished) {
        context.go('/game-over', extra: widget.roomCode);
      }
    });

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: LeaveRoomButton(roomCode: widget.roomCode),
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return TheaterLoadingScreen(
              message: AppLocalizations.of(context)!.calculatingScore,
            );
          }

          _tryPlayVoteOutcomeSfx(game);

          final earnedScore = game.lastRoundScore ?? 0;
          final audienceScore = game.lastRoundAudienceScore ?? 0;
          final multiplier = game.lastRoundMultiplier ?? 1;
          final isPass = multiplier == 0;
          final isGameOver = game.status == GameStatus.finished;
          final players = playersAsync.value ?? [];
          final currentPlayer = players
              .where((p) => p.id == (game.lastRoundPlayerId ?? game.currentPlayerId))
              .firstOrNull;
          final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

          return SafeArea(
            child: ResponsiveWrapper(
              padding: EdgeInsets.symmetric(horizontal: metrics.screenPadding),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildResultHeader(game, earnedScore, isPass, playerName, metrics),
                    SizedBox(height: metrics.sectionGap),
                    _buildScoreCard(audienceScore, earnedScore, multiplier, isPass, game.lastRoundMood, metrics),
                    SizedBox(height: metrics.sectionGap),
                    _buildLeaderboard(players, game, metrics, currentUser?.uid),
                    SizedBox(height: metrics.sectionGap),
                    if (game.currentTask != null)
                      _TaskFeedbackSection(
                        taskId: game.currentTask!.id,
                        taskContent: game.currentTask!.content,
                        compact: metrics.isCompact,
                      ),
                    SizedBox(height: metrics.bottomGap),
                    _buildActionButtons(isGameOver, game, metrics),
                    SizedBox(height: metrics.isCompact ? 16 : 32),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => TheaterLoadingScreen(
          message: AppLocalizations.of(context)!.calculatingScore,
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
      floatingActionButton: _buildConfetti(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ),
    );
  }
}