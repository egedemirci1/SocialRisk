part of 'round_result_screen.dart';

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 16,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: compact ? 16 : 18,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends ConsumerWidget {
  const _LeaderboardTile({
    required this.player,
    required this.rank,
    required this.isTarget,
    required this.compact,
  });

  final dynamic player;
  final int rank;
  final bool isTarget;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(watchUserProfileProvider(player.id)).value;
    final cosmetics = ref.watch(fetchCosmeticsProvider).value ?? [];
    final titleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 6 : 8),
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: isTarget ? AppColors.accent.withValues(alpha: 0.05) : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTarget
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Rank badge — fixed width; clip avoids overlap on narrow screens
          SizedBox(
            width: compact ? 36 : 44,
            child: Text(
              '#$rank',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10 : 12,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          PlayerAvatar(uid: player.id, displayName: player.name, radius: compact ? 13 : 15),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (titleItem != null)
                  Text(
                    '${titleItem.imageUrl} ${titleItem.name}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 9 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${player.score}',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFeedbackSection extends ConsumerStatefulWidget {
  const _TaskFeedbackSection({
    required this.taskId,
    required this.taskContent,
    required this.compact,
  });

  final String taskId;
  final String taskContent;
  final bool compact;

  @override
  ConsumerState<_TaskFeedbackSection> createState() => _TaskFeedbackSectionState();
}

class _TaskFeedbackSectionState extends ConsumerState<_TaskFeedbackSection> {
  bool? _givenFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.evaluateScenario,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: widget.compact ? 10 : 12,
            ),
          ),
          SizedBox(height: widget.compact ? 10 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeedbackButton(
                icon: Icons.thumb_up_rounded,
                label: AppLocalizations.of(context)!.goodUpper,
                isActive: _givenFeedback == true,
                color: Colors.green,
                onTap: () => _submit(true),
                compact: widget.compact,
              ),
              SizedBox(width: widget.compact ? 10 : 12),
              _FeedbackButton(
                icon: Icons.thumb_down_rounded,
                label: AppLocalizations.of(context)!.badUpper,
                isActive: _givenFeedback == false,
                color: AppColors.primary,
                onTap: () => _submit(false),
                compact: widget.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(bool like) {
    if (_givenFeedback != null) return;
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;
    setState(() => _givenFeedback = like);
    ref.read(taskControllerProvider.notifier).submitFeedback(
          taskId: widget.taskId,
          userId: userId,
          isLike: like,
        );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? color : Colors.white38, size: compact ? 14 : 16),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? color : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundResultMetrics {
  const _RoundResultMetrics({
    required this.isCompact,
    required this.isTiny,
    required this.screenPadding,
    required this.contentWidth,
    required this.sectionGap,
    required this.bottomGap,
    required this.cardPadding,
    required this.listPadding,
    required this.cardRadius,
    required this.headerIconSize,
    required this.headerEmojiSize,
    required this.headerTitleSize,
    required this.bodyFontSize,
    required this.labelFontSize,
    required this.textGap,
    required this.smallGap,
    required this.dividerHeight,
  });

  final bool isCompact;
  final bool isTiny;
  final double screenPadding;
  final double contentWidth;
  final double sectionGap;
  final double bottomGap;
  final double cardPadding;
  final double listPadding;
  final double cardRadius;
  final double headerIconSize;
  final double headerEmojiSize;
  final double headerTitleSize;
  final double bodyFontSize;
  final double labelFontSize;
  final double textGap;
  final double smallGap;
  final double dividerHeight;

  factory _RoundResultMetrics.from(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // iPhone SE = 375x667. Trigger compact much earlier.
    final isCompact = size.width < 400 || size.height < 700;
    // Super compact for truly tiny screens
    final isTiny = size.height < 680;

    return _RoundResultMetrics(
      isCompact: isCompact,
      isTiny: isTiny,
      screenPadding: isCompact ? 12 : 24,
      contentWidth: isCompact ? size.width - 24 : 380,
      sectionGap: isTiny ? 8 : (isCompact ? 10 : 20),
      bottomGap: isTiny ? 10 : (isCompact ? 14 : 28),
      cardPadding: isTiny ? 10 : (isCompact ? 12 : 20),
      listPadding: isTiny ? 8 : (isCompact ? 10 : 14),
      cardRadius: isCompact ? 8 : 12,
      headerIconSize: isTiny ? 40 : (isCompact ? 52 : 72),
      headerEmojiSize: isCompact ? 24 : 40,
      headerTitleSize: isTiny ? 16 : (isCompact ? 18 : 24),
      bodyFontSize: isTiny ? 11 : (isCompact ? 12 : 14),
      labelFontSize: isTiny ? 9 : (isCompact ? 10 : 12),
      textGap: isTiny ? 6 : (isCompact ? 8 : 14),
      smallGap: isTiny ? 3 : (isCompact ? 4 : 8),
      dividerHeight: isTiny ? 14 : (isCompact ? 16 : 22),
    );
  }
}