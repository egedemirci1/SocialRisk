part of 'home_screen.dart';

extension _HomeScreenBuilders on _HomeScreenState {
  Widget _buildActivePartyBanner(
    BuildContext context,
    WidgetRef ref,
    String roomCode,
    RoomEntity room,
    GameEntity? game,
  ) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _resumeActiveParty(context, room, game),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.continueParty,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.activePartySubtitle(roomCode),
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resumeActiveParty(
    BuildContext context,
    RoomEntity room,
    GameEntity? game,
  ) {
    final route = GameRouteResolver.resolveRoute(room, gameStatus: game?.status);
    final extra = GameRouteResolver.extraForRoom(room, gameStatus: game?.status);
    context.go(route, extra: extra);
  }

  Widget? _buildActivePartySection(BuildContext context, WidgetRef ref, User? user) {
    if (user == null) return null;

    final roomCode = ref.watch(currentRoomTrackerProvider);
    if (roomCode == null || roomCode.isEmpty) return null;

    final room = ref.watch(watchRoomProvider(roomCode)).value;
    final players = ref.watch(watchPlayersProvider(roomCode)).value;

    if (room == null || room.hostLeftSignal == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentRoomTrackerProvider.notifier).updateRoom(null);
      });
      return null;
    }

    final isMember = players?.any((p) => p.id == user.uid) ?? false;
    if (!isMember) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentRoomTrackerProvider.notifier).updateRoom(null);
      });
      return null;
    }

    if (room.status == GameStatus.finished) return null;

    final gameId = room.gameId;
    final gameAsync = (gameId != null && gameId.isNotEmpty)
        ? ref.watch(watchGameProvider(gameId))
        : const AsyncValue<GameEntity?>.data(null);
    if (gameId != null && gameId.isNotEmpty && gameAsync.isLoading) {
      return null;
    }
    final game = gameAsync.value;

    if (game?.status == GameStatus.finished) return null;

    return _buildActivePartyBanner(context, ref, roomCode, room, game);
  }

  Widget _buildWelcome(
    BuildContext context,
    String playerName,
    UserEntity? profile,
    List<CosmeticItemEntity> cosmetics,
    String? uid,
  ) {
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: PlayerAvatar(
              uid: uid ?? '',
              displayName: playerName,
              radius: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: AppTextStyles.displayLarge.copyWith(color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            shadows: const [
              Shadow(offset: Offset(-1.5, -1.5), color: Colors.black87),
              Shadow(offset: Offset(1.5, -1.5), color: Colors.black87),
              Shadow(offset: Offset(1.5, 1.5), color: Colors.black87),
              Shadow(offset: Offset(-1.5, 1.5), color: Colors.black87),
              Shadow(offset: Offset(0, 6), color: Colors.black54, blurRadius: 8),
            ],),
          textAlign: TextAlign.center,
        ),
        if (activeTitleItem != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AppColors.accentGradient.begin,
                end: AppColors.accentGradient.end,
                colors: AppColors.accentGradient.colors
                    .map((c) => c.withValues(alpha: 0.15))
                    .toList(),
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              activeTitleItem.name,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User? user) {
    final l = AppLocalizations.of(context)!; // Added for l10n
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageButton(
          label: l.newParty, // Changed from 'Yeni Parti Başlat'
          icon: Icons.add_circle_outline_rounded,
          backgroundColor: AppColors.primary,
          textColor: AppColors.background,
          borderColor: Colors.transparent,
          onPressed: () => context.push('/create-room'),
        ),
        const SizedBox(height: 16),
        StageButton(
          label: l.joinParty, // Changed from 'Partiye Katıl'
          icon: Icons.login_rounded,
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          borderColor: Colors.transparent,
          onPressed: () => context.push('/join-room'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StageButton(
                label: l.store, // Changed from 'Mağaza'
                icon: Icons.shopping_bag_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StageButton(
                label: l.content,
                icon: Icons.menu_book_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/custom-deck'),
              ),
            ),
          ],
        ),
        if (isAdmin(user?.uid)) ...[
          const SizedBox(height: 24),
          StageButton(
            label: l.adminPanel,
            icon: Icons.admin_panel_settings_rounded,
            backgroundColor: const Color(0xFF1A1A1A),
            textColor: Colors.amber,
            borderColor: Colors.amber.withValues(alpha: 0.5),
            onPressed: () => context.push('/admin'),
          ),
        ],
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user?.isAnonymous == true) {
      final l = AppLocalizations.of(context)!;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                l.attention,
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            l.logoutWarning,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                foregroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.no, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteAndExit, style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        final l2 = AppLocalizations.of(context)!;
        ToastUtils.showSuccess(context, l2.logoutSuccess);
        await Future.delayed(const Duration(milliseconds: 600));
        if (context.mounted) context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        final l2 = AppLocalizations.of(context)!;
        ToastUtils.showError(context, l2.logoutError(ErrorMessageUtils.formatUserError(e, l2)));
      }
    }
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/profile'),
          child: Text(
            l.profile,
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,),
          ),
        ),
        Container(
          height: 16,
          width: 1,
          color: Colors.white24,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        TextButton(
          onPressed: () => _showSettingsSheet(context, ref),
          child: Text(
            l.menu,
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,),
          ),
        ),
      ],
    );
  }
}