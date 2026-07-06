part of 'lobby_screen.dart';

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
      onPressed: isCoolingDown ? null : widget.onPressed,
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

