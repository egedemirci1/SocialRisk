import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/report_dialog.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/widgets/guards/room_exit_guard.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../economy/providers/economy_provider.dart';
import '../domain/room_entity.dart';
import '../providers/room_provider.dart';

part 'lobby_screen.builders.part.dart';
part 'lobby_screen.widgets.part.dart';
part 'lobby_screen.widgets_actions.part.dart';

const List<String> _lobbyEmotes = [
  '\u{1F602}',
  '\u{1F622}',
  '\u{1F525}',
  '\u{2764}\u{FE0F}',
  '\u{2753}',
  '\u{1F389}',
  '\u{1F483}',
  '\u{1F60E}',
];
const Duration _lobbyEmoteCooldown = Duration(seconds: 3);

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _isStartingGame = false;
  bool _isJoiningGame = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(watchRoomProvider(widget.roomCode), (previous, next) {
      if (!mounted) return;
      final room = next.value;

      // Host left signal check - show toaster and navigate home
      if (room?.hostLeftSignal == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ToastUtils.showError(
              context,
              AppLocalizations.of(context)!.roomClosedHostLeft,
            );
            context.go('/home');
          }
        });
        return;
      }

      if (room == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ToastUtils.showError(context, AppLocalizations.of(context)!.roomClosedHostLeft);
            context.go('/home');
          }
        });
        return;
      }

      final user = ref.read(currentUserProvider);
      final isHost = room.hostId == user?.uid;

      if (!isHost && room.status == GameStatus.playing) {
        final gameId = room.gameId;
        if (gameId != null && gameId.isNotEmpty) {
          if (!_isJoiningGame && mounted) {
            setState(() => _isJoiningGame = true);
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/task', extra: {'gameId': gameId, 'roomCode': widget.roomCode});
            }
          });
        }
      }
    });

    final user = ref.watch(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
    final cosmetics = cosmeticsAsync.value ?? [];
    final room = roomAsync.value;
    final layout = _LobbyLayoutMetrics.from(context);
    final l = AppLocalizations.of(context)!;

    return RoomExitPopScope(
      roomCode: widget.roomCode,
      mode: LeaveRoomMode.lobby,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.lobby,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Tooltip(
          message: l.leavePartyTitle,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.accent),
            onPressed: () => showLeaveRoomDialog(
              context,
              ref,
              widget.roomCode,
              mode: LeaveRoomMode.lobby,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ResponsiveWrapper(
              maxWidth: 600,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildRoomCodeBanner(context, room, playersAsync.value?.length ?? 0, layout),

                  SizedBox(height: layout.sectionGap),
                  _RotatingTooltips(compact: layout.isCompact),
                  SizedBox(height: layout.sectionGap),
                  Expanded(
                    child: playersAsync.when(
                      data: (players) {
                        final roomEmotes = room?.lobbyEmotes ?? const <String, LobbyEmoteEntity>{};
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            final isMe = player.id == user?.uid;
                            final lobbyEmote = roomEmotes[player.id];
                            return _PlayerTile(
                              playerId: player.id,
                              name: player.name,
                              avatarUrl: player.avatarUrl,
                              isReady: player.isReady,
                              isCurrentPlayer: isMe,
                              lobbyEmote: lobbyEmote?.emote,
                              lobbyEmoteExpiresAt: lobbyEmote?.expiresAt,
                              cosmetics: cosmetics,
                              onLongPress: isMe
                                  ? null
                                  : () {
                                      ReportDialog.show(
                                        context,
                                        ref,
                                        targetUserId: player.id,
                                        targetUserName: player.name,
                                        targetUserAvatar: player.avatarUrl ?? '',
                                      );
                                    },
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                      error: (e, _) {
                        final l = AppLocalizations.of(context)!;
                        return Center(
                          child: AsyncErrorView(
                            message: l.loadFailed,
                            detail: ErrorMessageUtils.formatUserError(e, l),
                            onRetry: () => ref.invalidate(
                              watchPlayersProvider(widget.roomCode),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildEmoteBar(context, ref, user, room, layout),
                  SizedBox(height: layout.tightGap),
                  _buildActionSection(
                    context,
                    ref,
                    user,
                    roomAsync,
                    playersAsync,
                    layout: layout,
                    onStartGame: () async {
                      setState(() => _isStartingGame = true);
                      try {
                        final room = roomAsync.value;
                        final players = playersAsync.value ?? [];
                        final playerIds = players.map((p) => p.id).toList();
                        final gameId = await ref.read(roomRepositoryProvider).startGameInRoom(
                              roomCode: widget.roomCode,
                              playerIds: playerIds,
                              mode: room?.mode ?? GameMode.classic,
                              categories: room?.categories ?? [],
                            );

                        if (!context.mounted) return;
                        context.go('/task', extra: {'gameId': gameId, 'roomCode': widget.roomCode});
                      } catch (e) {
                        if (!context.mounted) return;
                        final l = AppLocalizations.of(context)!;
                        ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
                      } finally {
                        if (mounted) setState(() => _isStartingGame = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isStartingGame || _isJoiningGame)
            Positioned.fill(
              child: AbsorbPointer(
                child: TheaterLoadingScreen(
                  message: AppLocalizations.of(context)!.preparingGame,
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
