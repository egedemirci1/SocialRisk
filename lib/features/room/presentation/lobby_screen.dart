import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/task_translations/task_translation_map.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/report_dialog.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../economy/providers/economy_provider.dart';
import '../domain/room_entity.dart';
import '../providers/room_provider.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../core/audio/audio_service.dart';

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

  @override
  void initState() {
    super.initState();
    ref.read(audioServiceProvider).playMenuLoop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(watchRoomProvider(widget.roomCode), (previous, next) {
      if (!mounted) return;
      final room = next.value;
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

    return Scaffold(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.accent),
          onPressed: () async {
            if (user != null) {
              await ref.read(roomControllerProvider.notifier).leaveRoom(
                    roomCode: widget.roomCode,
                    playerId: user.uid,
                  );
            }
            if (context.mounted) context.pop();
          },
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
                      error: (e, _) => Center(
                        child: Text(
                          AppLocalizations.of(context)!.error(e.toString()),
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
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
                        ToastUtils.showError(context, AppLocalizations.of(context)!.error(e.toString()));
                      } finally {
                        if (mounted) setState(() => _isStartingGame = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isStartingGame)
            Positioned.fill(
              child: TheaterLoadingScreen(message: AppLocalizations.of(context)!.preparingGame),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeBanner(
    BuildContext context,
    RoomEntity? room,
    int playerCount,
    _LobbyLayoutMetrics layout,
  ) {
    final l = AppLocalizations.of(context)!;
    final modeName = room?.mode == GameMode.economy ? l.marketModeCapital : l.wheelModeCapital;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.roomCode.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    widget.roomCode,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        modeName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$playerCount/8',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.copy_rounded, color: AppColors.accent, size: 24),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.roomCode));
                    ToastUtils.showSuccess(context, l.codeCopied);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmoteBar(
    BuildContext context,
    WidgetRef ref,
    User? user,
    RoomEntity? room,
    _LobbyLayoutMetrics layout,
  ) {
    final activeEmote = user == null ? null : room?.lobbyEmotes[user.uid];
    final cooldownUntil = activeEmote?.sentAt.add(_lobbyEmoteCooldown);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
      child: _LobbyCooldownButton(
        cooldownUntil: cooldownUntil,
        onPressed: user == null ? null : () => _showEmotePicker(context, ref, user.uid),
      ),
    );
  }

  Future<void> _showEmotePicker(
    BuildContext context,
    WidgetRef ref,
    String playerId,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                AppLocalizations.of(context)!.chooseAnEmote,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _lobbyEmotes.map((emote) {
                    return _EmoteChoiceChip(
                      emote: emote,
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(roomControllerProvider.notifier).sendLobbyEmote(
                                roomCode: widget.roomCode,
                                playerId: playerId,
                                emote: emote,
                              );
                        } catch (e) {
                          final message = e.toString();
                          if (message.contains('Cooldown:')) {
                            final seconds = message.split('Cooldown:').last.replaceAll('Exception: ', '');
                            if (mounted) {
                              final ctx = this.context;
                              if (ctx.mounted) {
                                ToastUtils.showError(ctx, AppLocalizations.of(ctx)!.sendEmoteCooldown(int.tryParse(seconds) ?? 0));
                              }
                          }
                            return;
                          }
                          if (mounted) {
                            final ctx = this.context;
                            if (ctx.mounted) {
                              ToastUtils.showError(ctx, AppLocalizations.of(ctx)!.error(e.toString()));
                            }
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    WidgetRef ref,
    User? user,
    AsyncValue<dynamic> roomAsync,
    AsyncValue<List<dynamic>> playersAsync, {
    required _LobbyLayoutMetrics layout,
    Future<void> Function()? onStartGame,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(layout.screenPadding, 8, layout.screenPadding, layout.bottomPadding),
      child: roomAsync.when(
        data: (room) {
          final isHost = room?.hostId == user?.uid;
          final players = playersAsync.value ?? [];
          final allReady = players.isNotEmpty &&
              players.every((p) => p.id == room?.hostId || p.isReady);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isHost)
                _ReadyToggleButton(
                  roomCode: widget.roomCode,
                  playerId: user?.uid ?? '',
                ),
              if (isHost) ...[
                _AnimatedHostStartButton(
                  isReady: allReady && players.length >= 2,
                  onPressed: () async {
                    if (onStartGame != null) await onStartGame();
                  },
                ),
                SizedBox(height: layout.tightGap),
                Text(
                  (allReady && players.length >= 2)
                      ? AppLocalizations.of(context)!.everyoneWaitingForYou
                      : AppLocalizations.of(context)!.waitForOthersToReady,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: (allReady && players.length >= 2)
                        ? AppColors.accent
                        : Colors.white30,
                    fontSize: layout.isCompact ? 11 : 12,
                    fontWeight: (allReady && players.length >= 2)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _LobbyLayoutMetrics {
  const _LobbyLayoutMetrics({
    required this.isCompact,
    required this.screenPadding,
    required this.sectionGap,
    required this.tightGap,
    required this.bottomPadding,
    required this.bannerPadding,
    required this.bannerRadius,
    required this.inlineGap,
    required this.textGap,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.badgeFontSize,
    required this.badgeIconSize,
    required this.copyIconSize,
    required this.codeFontSize,
    required this.codeLetterSpacing,
  });

  final bool isCompact;
  final double screenPadding;
  final double sectionGap;
  final double tightGap;
  final double bottomPadding;
  final double bannerPadding;
  final double bannerRadius;
  final double inlineGap;
  final double textGap;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double badgeFontSize;
  final double badgeIconSize;
  final double copyIconSize;
  final double codeFontSize;
  final double codeLetterSpacing;

  factory _LobbyLayoutMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 390 || size.height < 780;

    return _LobbyLayoutMetrics(
      isCompact: isCompact,
      screenPadding: isCompact ? 14 : 20,
      sectionGap: isCompact ? 12 : 16,
      tightGap: isCompact ? 10 : 12,
      bottomPadding: isCompact ? 20 : 32,
      bannerPadding: isCompact ? 12 : 16,
      bannerRadius: isCompact ? 10 : 12,
      inlineGap: isCompact ? 6 : 8,
      textGap: isCompact ? 4 : 6,
      badgeHorizontalPadding: isCompact ? 6 : 8,
      badgeVerticalPadding: isCompact ? 3 : 4,
      badgeFontSize: isCompact ? 9 : 10,
      badgeIconSize: isCompact ? 12 : 14,
      copyIconSize: isCompact ? 20 : 24,
      codeFontSize: isCompact ? 22 : 24,
      codeLetterSpacing: isCompact ? 2.5 : 4,
    );
  }
}
class _PlayerTile extends ConsumerWidget {
  const _PlayerTile({
    required this.playerId,
    required this.name,
    this.avatarUrl,
    required this.isReady,
    required this.isCurrentPlayer,
    this.lobbyEmote,
    this.lobbyEmoteExpiresAt,
    this.cosmetics = const [],
    this.onLongPress,
  });

  final String playerId;
  final String name;
  final String? avatarUrl;
  final bool isReady;
  final bool isCurrentPlayer;
  final String? lobbyEmote;
  final DateTime? lobbyEmoteExpiresAt;
  final List<CosmeticItemEntity> cosmetics;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(watchUserProfileProvider(playerId));
    final profile = profileAsync.value;
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;
    final tilePadding = isSmallScreen ? 8.0 : 12.0;
    final tileVerticalMargin = isSmallScreen ? 3.0 : 6.0;
    final avatarRadius = isSmallScreen ? 16.0 : 20.0;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tileVerticalMargin),
        child: Container(
          padding: EdgeInsets.all(tilePadding),
          decoration: BoxDecoration(
            color: isCurrentPlayer
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPlayer ? AppColors.accent : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PlayerAvatar(uid: playerId, displayName: name, radius: avatarRadius),
                  if (lobbyEmote != null && lobbyEmoteExpiresAt != null)
                    Positioned(
                      top: -10,
                      right: -16,
                      child: _LobbyEmoteBubble(
                        emote: lobbyEmote!,
                        expiresAt: lobbyEmoteExpiresAt!,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name + (isCurrentPlayer ? AppLocalizations.of(context)!.youSuffix : ''),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isSmallScreen ? 14 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activeTitleItem != null)
                      Text(
                        activeTitleItem.name.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isReady
                      ? Colors.green.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isReady ? AppLocalizations.of(context)!.ready : AppLocalizations.of(context)!.notReady,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isReady ? Colors.green : AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LobbyCooldownButton extends StatefulWidget {
  const _LobbyCooldownButton({
    required this.cooldownUntil,
    required this.onPressed,
  });

  final DateTime? cooldownUntil;
  final VoidCallback? onPressed;

  @override
  State<_LobbyCooldownButton> createState() => _LobbyCooldownButtonState();
}

class _LobbyCooldownButtonState extends State<_LobbyCooldownButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _LobbyCooldownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cooldownUntil != widget.cooldownUntil) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    final cooldownUntil = widget.cooldownUntil;
    if (cooldownUntil == null || !cooldownUntil.isAfter(DateTime.now())) {
      if (mounted) setState(() {});
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (!cooldownUntil.isAfter(DateTime.now())) {
        timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cooldownUntil = widget.cooldownUntil;
    final remaining = cooldownUntil == null
        ? Duration.zero
        : cooldownUntil.difference(DateTime.now());
    final isCoolingDown = remaining > Duration.zero;

    final compact = MediaQuery.sizeOf(context).width < 390;

    return StageButton(
      label: isCoolingDown
          ? AppLocalizations.of(context)!.sendEmoteCooldown(remaining.inSeconds + 1)
          : AppLocalizations.of(context)!.sendEmote,
      icon: isCoolingDown ? Icons.hourglass_bottom_rounded : Icons.emoji_emotions_outlined,
      backgroundColor: isCoolingDown ? Colors.black26 : AppColors.surface,
      textColor: isCoolingDown ? Colors.white54 : AppColors.accent,
      borderColor: isCoolingDown ? Colors.white12 : AppColors.accent.withValues(alpha: 0.3),
      onPressed: isCoolingDown ? () {} : (widget.onPressed ?? () {}),
      compact: compact,
    );
  }
}

class _LobbyEmoteBubble extends StatefulWidget {
  const _LobbyEmoteBubble({
    required this.emote,
    required this.expiresAt,
  });

  final String emote;
  final DateTime expiresAt;

  @override
  State<_LobbyEmoteBubble> createState() => _LobbyEmoteBubbleState();
}

class _LobbyEmoteBubbleState extends State<_LobbyEmoteBubble> {
  Timer? _hideTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void didUpdateWidget(covariant _LobbyEmoteBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt || oldWidget.emote != widget.emote) {
      _isVisible = true;
      _scheduleHide();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    final remaining = widget.expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      if (mounted) setState(() => _isVisible = false);
      return;
    }
    _hideTimer = Timer(remaining, () {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isVisible ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(widget.emote, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _EmoteChoiceChip extends StatelessWidget {
  const _EmoteChoiceChip({
    required this.emote,
    required this.onTap,
  });

  final String emote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Center(child: Text(emote, style: const TextStyle(fontSize: 28))),
      ),
    );
  }
}

class _ReadyToggleButton extends ConsumerWidget {
  const _ReadyToggleButton({required this.roomCode, required this.playerId});

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final me = (playersAsync.value ?? []).where((p) => p.id == playerId).firstOrNull;
    final isReady = me?.isReady ?? false;

    final compact = MediaQuery.sizeOf(context).width < 390;

    return StageButton(
      label: isReady ? AppLocalizations.of(context)!.readyForParty : AppLocalizations.of(context)!.notReadyYet,
      icon: isReady ? Icons.check_circle_outline_rounded : Icons.close_rounded,
      backgroundColor: isReady ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
      textColor: isReady ? Colors.white : AppColors.primary,
      borderColor: isReady ? AppColors.accent : AppColors.primary.withValues(alpha: 0.4),
      onPressed: () => ref.read(roomControllerProvider.notifier).toggleReady(
            roomCode: roomCode,
            playerId: playerId,
            isReady: !isReady,
          ),
      compact: compact,
    );
  }
}

class _RotatingTooltips extends StatefulWidget {
  const _RotatingTooltips({required this.compact});

  final bool compact;

  @override
  State<_RotatingTooltips> createState() => _RotatingTooltipsState();
}

class _RotatingTooltipsState extends State<_RotatingTooltips> {
  int _currentIndex = 0;
  late final Timer _timer;
  List<String> get _tips => [
    AppLocalizations.of(context)!.lobbyTip1,
    AppLocalizations.of(context)!.lobbyTip2,
    AppLocalizations.of(context)!.lobbyTip3,
    AppLocalizations.of(context)!.lobbyTip4,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _tips.length);
      }
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
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(_currentIndex),
        padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 16, vertical: widget.compact ? 6 : 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MediaQuery.sizeOf(context).width < 390 ? 14 : 16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Text(
          _tips[_currentIndex],
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.accent,
            fontSize: widget.compact ? 11 : 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AnimatedHostStartButton extends StatefulWidget {
  final bool isReady;
  final VoidCallback onPressed;

  const _AnimatedHostStartButton({
    required this.isReady,
    required this.onPressed,
  });

  @override
  State<_AnimatedHostStartButton> createState() => _AnimatedHostStartButtonState();
}

class _AnimatedHostStartButtonState extends State<_AnimatedHostStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
    ]).animate(_controller);

    if (widget.isReady) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedHostStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      _controller.repeat();
    } else if (!widget.isReady && oldWidget.isReady) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isReady) {
      final compact = MediaQuery.sizeOf(context).width < 390;

      return StageButton(
        label: AppLocalizations.of(context)!.startGame,
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.surface,
        textColor: Colors.white30,
        borderColor: Colors.white10,
        onPressed: () {},
        compact: compact,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
              borderRadius: BorderRadius.circular(MediaQuery.sizeOf(context).width < 390 ? 14 : 16),
            ),
            child: child,
          ),
        );
      },
      child: StageButton(
        label: AppLocalizations.of(context)!.startGame,
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        borderColor: AppColors.accent,
        onPressed: widget.onPressed,
        compact: MediaQuery.sizeOf(context).width < 390,
      ),
    );
  }
}














