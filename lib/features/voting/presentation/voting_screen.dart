import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../room/providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../providers/vote_provider.dart';
import '../domain/vote_repository.dart';
import '../../game/domain/game_entity.dart';
import '../../game/presentation/widgets/turn_counter_badge.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/score/scoreboard_bottom_sheet.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../economy/providers/economy_provider.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oyluyor (Parti Temalı).
class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key, required this.gameId, required this.roomCode});

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  static const Duration _voteDuration = Duration(seconds: 20);
  bool _isProcessing = false;
  bool _hasProcessed = false;
  bool _hasVoted = false;

  Future<void> _processResults({
    required String currentPlayerId,
    required int taskMultiplier,
    required int currentRound,
  }) async {
    if (_isProcessing || _hasProcessed) return;
    _hasProcessed = true;
    setState(() => _isProcessing = true);

    try {
      final voteCtrl = ref.read(voteControllerProvider.notifier);

      final results = await Future.wait([
        voteCtrl.applyTimedOutPenalties(
          gameId: widget.gameId,
          roomId: widget.roomCode,
          penalty: 10,
        ),
        voteCtrl.calculateAndApplyScore(
          gameId: widget.gameId,
          taskMultiplier: taskMultiplier,
        ),
      ]);
      final voteResult = results[1] as VoteResult;
      final earned = voteResult.totalScore;

      await ref.read(gameControllerProvider.notifier).applyScore(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: currentPlayerId,
            scoreToAdd: earned,
            audienceScore: voteResult.audienceScore,
            taskMultiplier: taskMultiplier,
          );

      // Oyları temizle (status değiştikten sonra, kritik yolda değil)
      voteCtrl.clearVotes(widget.gameId);

      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        _hasProcessed = false;
        setState(() => _isProcessing = false);
        ToastUtils.showError(context, 'Hata: $e');
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

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
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
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (game.status == GameStatus.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/game-over', extra: widget.roomCode);
          });
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final activePlayers = playersAsync.value ?? [];
        final performer = activePlayers
            .where((p) => p.id == game.currentPlayerId)
            .firstOrNull;
        final performerName = performer?.name ?? 'Oyuncu';

        final activePlayerIds = activePlayers.map((p) => p.id).toList();
        final allVoted =
            votesAsync.value != null &&
            activePlayerIds.isNotEmpty &&
            activePlayerIds.every(
              (id) =>
                  id == game.currentPlayerId ||
                  votesAsync.value!.containsKey(id),
            );

        final isHost = roomAsync.value?.hostId == user?.uid;
        final isMyTurn = game.currentPlayerId == user?.uid;

        if (allVoted && !_isProcessing && !_hasProcessed && isHost) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isProcessing && !_hasProcessed) {
              _processResults(
                currentPlayerId: game.currentPlayerId,
                taskMultiplier: game.currentTask?.multiplier ?? 1,
                currentRound: game.currentRound,
              );
            }
          });
        }

        final difficulty = game.currentTask?.difficulty ?? 'medium';
        Color glowColor;
        if (difficulty == 'hard') {
          glowColor = Colors.red.withValues(alpha: 0.15);
        } else if (difficulty == 'easy') {
          glowColor = Colors.green.withValues(alpha: 0.15);
        } else {
          glowColor = Colors.orange.withValues(alpha: 0.15);
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
                'ELEŞTİRİ & OYLAMA',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
            ),
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
                      const _VisualCountdownTimer(duration: _voteDuration),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Builder(
                            builder: (context) {
                              final sh = MediaQuery.sizeOf(context).height;
                              final isSmall = sh < 700;
                              final avatarR = isSmall ? 38.0 : 50.0;
                              return Column(
                                children: [
                                  SizedBox(height: isSmall ? 10 : 16),
                                  PlayerAvatar(
                                    uid: game.currentPlayerId,
                                    displayName: performerName,
                                    radius: avatarR,
                                  ),
                                  SizedBox(height: isSmall ? 10 : 16),
                                  Text(
                                    performerName.toUpperCase(),
                                    style: AppTextStyles.displayMedium.copyWith(
                                      color: Colors.white,
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
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${titleItem.imageUrl} ${titleItem.name}',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'performansını sergiledi:',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: isSmall ? 16 : 24),
                                  Container(
                                    padding: EdgeInsets.all(isSmall ? 16 : 24),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      '"${game.currentTask?.content ?? ""}"',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: isSmall ? 16 : 24),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      // Oylama / bekleme alanı her zaman altta görünsün
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).height < 700 ? 16 : 24,
                          MediaQuery.sizeOf(context).height < 700 ? 8 : 16,
                          MediaQuery.sizeOf(context).height < 700 ? 16 : 24,
                          MediaQuery.sizeOf(context).height < 700 ? 16 : 32,
                        ),
                        child: _isProcessing
                            ? _buildProcessingIndicator()
                            : isMyTurn
                                ? _buildWaitingForOthers()
                                : _hasVoted
                                    ? _buildVotedStatus()
                                    : VotingPanel(
                                        timeLimit: _voteDuration,
                                        onVote: (value, {timedOut = false}) {
                                          if (user == null) return;
                                          setState(() => _hasVoted = true);
                                          if (timedOut && mounted) {
                                            ToastUtils.showError(
                                              context,
                                              'S\u00fcre doldu. Oy vermedi\u011fin i\u00e7in -10 puan cezas\u0131 ald\u0131n.',
                                            );
                                          }
                                          ref
                                              .read(voteControllerProvider.notifier)
                                              .castVote(
                                                gameId: widget.gameId,
                                                voterId: user.uid,
                                                value: VoteValue.values.byName(value),
                                                timedOut: timedOut,
                                              );
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
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: TheaterLoadingScreen(message: 'Skor Hesaplanıyor...'),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(color: AppColors.accent),
        const SizedBox(height: 16),
        Text(
          'Oylar sayılıyor...',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.accent,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForOthers() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          'Diğer oyuncuların değerlendirmesi bekleniyor...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildVotedStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            'DEĞERLENDİRİLDİ',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualCountdownTimer extends StatefulWidget {
  final Duration duration;

  const _VisualCountdownTimer({required this.duration});

  @override
  State<_VisualCountdownTimer> createState() => _VisualCountdownTimerState();
}

class _VisualCountdownTimerState extends State<_VisualCountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
        vsync: this, duration: widget.duration);

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _progressController.forward();
    _progressController.addListener(() {
      final remaining =
          (1.0 - _progressController.value) * widget.duration.inSeconds;
      if (remaining <= 3.0 && !_shakeController.isAnimating) {
        _shakeController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _shakeController]),
      builder: (context, child) {
        final progress = 1.0 - _progressController.value;
        final remaining = progress * widget.duration.inSeconds;
        Color barColor;
        if (remaining > 10) {
          barColor = Colors.greenAccent;
        } else if (remaining > 5) {
          barColor = Colors.orangeAccent;
        } else {
          barColor = Colors.redAccent;
        }

        return Transform.translate(
          offset: Offset(remaining <= 3.0 ? _shakeAnimation.value : 0, 0),
          child: Container(
            height: 4,
            width: double.infinity,
            color: Colors.white12,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: remaining <= 3.0 ? 2 : 0,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingPsychologicalTexts extends StatefulWidget {
  @override
  State<_FloatingPsychologicalTexts> createState() =>
      _FloatingPsychologicalTextsState();
}

class _FloatingPsychologicalTextsState
    extends State<_FloatingPsychologicalTexts> with TickerProviderStateMixin {
  final List<String> _texts = [
    'Herkes senin kararını bekliyor...',
    'Zaman daralıyor!',
    'Hızlı karar ver...',
    'Acımasız ol!',
    'Gerilim tırmanıyor...',
  ];

  final Random _rng = Random();
  late Timer _timer;
  String _currentText = '';
  Alignment _currentAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _currentText = _texts[_rng.nextInt(_texts.length)];
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _currentText = _texts[_rng.nextInt(_texts.length)];
        _currentAlignment = Alignment(
          (_rng.nextDouble() * 1.6) - 0.8, // -0.8 to 0.8
          (_rng.nextDouble() * 1.6) - 0.8,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: Align(
        key: ValueKey<String>(_currentText),
        alignment: _currentAlignment,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _currentText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.15),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}



