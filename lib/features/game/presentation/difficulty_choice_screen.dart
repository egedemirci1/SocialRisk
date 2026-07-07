import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/task_translations/task_translation_map.dart';
import '../../../core/providers/locale_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/game_route_resolver.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/common/game_error_scaffold.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/app_loading_indicator.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../../shared/widgets/buttons/exit_room_button.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../domain/game_entity.dart';
import '../providers/game_provider.dart';

part 'difficulty_choice_screen.builders.part.dart';
part 'difficulty_choice_screen.widgets.part.dart';

class DifficultyChoiceScreen extends ConsumerStatefulWidget {
  const DifficultyChoiceScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<DifficultyChoiceScreen> createState() =>
      _DifficultyChoiceScreenState();
}

class _DifficultyChoiceScreenState
    extends ConsumerState<DifficultyChoiceScreen> {
  bool _isLoading = false;
  bool _hasRedirected = false;

  String _toTurkishUpper(String value) {
    return value
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ş', 'Ş')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ü', 'Ü')
        .replaceAll('ö', 'Ö')
        .replaceAll('ç', 'Ç')
        .toUpperCase();
  }

  Future<void> _selectDifficulty(String difficulty) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(gameControllerProvider.notifier)
          .chooseDifficulty(gameId: widget.gameId, difficulty: difficulty);
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomMode =
        ref.read(watchRoomProvider(widget.roomCode)).value?.mode ??
        GameMode.classic;

    ref.listen(watchGameProvider(widget.gameId), (prev, next) {
      if (!mounted || _hasRedirected) return;
      final game = next.value;
      if (game == null) return;
      if (game.status == GameStatus.choosingDifficulty) {
        return;
      }

      _hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = GameRouteResolver.routeForGameStatus(
          game.status,
          mode: roomMode,
          gameId: widget.gameId,
          roomCode: widget.roomCode,
        );
        if (route == null) return;
        if (route == '/game-over') {
          context.go(route, extra: widget.roomCode);
        } else {
          context.replace(
            route,
            extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
          );
        }
      });
    });

    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      child: gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text(AppLocalizations.of(context)!.gameNotFound)),
          );
        }

        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;
        final players = roomAsync.value?.players ?? [];
        final currentPlayer =
            players.where((p) => p.id == game.currentPlayerId).firstOrNull;
        final playerName = currentPlayer?.name ?? AppLocalizations.of(context)!.playerDefaultName;

        if (game.status != GameStatus.choosingDifficulty && !_hasRedirected) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final route = GameRouteResolver.routeForGameStatus(
                game.status,
                mode: roomMode,
                gameId: widget.gameId,
                roomCode: widget.roomCode,
              );
              if (route == null) return;
              if (route == '/game-over') {
                context.go(route, extra: widget.roomCode);
                return;
              }
              context.replace(
                route,
                extra: {'gameId': widget.gameId, 'roomCode': widget.roomCode},
              );
            }
          });
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: TheaterLoadingScreen(
              message: AppLocalizations.of(context)!.partyStarting,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: ExitRoomButton(roomCode: widget.roomCode),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            minimum: const EdgeInsets.only(bottom: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _DifficultyLayoutMetrics.from(constraints);

                return Center(
                  child: SizedBox(
                    width: layout.contentWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: layout.topGap),
                          SizedBox(
                            height: layout.categoryHeight,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layout.categoryHorizontalPadding,
                                    vertical: layout.categoryVerticalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      layout.categoryRadius,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.4),
                                    ),
                                  ),
                                    child: Text(
                                      AppLocalizations.of(context)!.categoryVariable(
                                        game.selectedCategory != null
                                            ? TaskTranslationMap.getCategoryTranslation(
                                                game.selectedCategory!,
                                                LocaleProvider.of(context).languageCode,
                                              ).toUpperCase()
                                            : "?",
                                      ),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: layout.categoryLetterSpacing,
                                      fontSize: layout.categoryFontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: layout.sectionGap),
                          Expanded(
                            child: isMyTurn
                                ? _buildChooserLayout(game, layout)
                                : _buildWaitingLayout(playerName, layout),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(
          message: AppLocalizations.of(context)!.difficulty,
        ),
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