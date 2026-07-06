part of 'lobby_screen.dart';

extension _LobbyScreenBuilders on _LobbyScreenState {
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
                          if (!mounted) return;
                          final ctx = this.context;
                          if (!ctx.mounted) return;
                          final l = AppLocalizations.of(ctx)!;
                          final msg = ErrorMessageUtils.formatUserError(e, l);
                          final display = e is AppException &&
                                  e.code == AppErrorCode.emoteCooldown
                              ? msg
                              : l.error(msg);
                          ToastUtils.showError(ctx, display);
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
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(layout.screenPadding, 8, layout.screenPadding, layout.bottomPadding),
      child: roomAsync.when(
        data: (room) {
          return playersAsync.when(
            data: (players) {
              final isHost = room?.hostId == user?.uid;
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
                          ? l.everyoneWaitingForYou
                          : l.waitForOthersToReady,
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
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (_, __) => AsyncErrorView(
              compact: true,
              message: l.loadFailed,
              onRetry: () => ref.invalidate(watchPlayersProvider(widget.roomCode)),
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
        error: (_, __) => AsyncErrorView(
          compact: true,
          message: l.loadFailed,
          onRetry: () => ref.invalidate(watchRoomProvider(widget.roomCode)),
        ),
      ),
    );
  }
}
