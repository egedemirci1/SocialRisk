part of 'admin_dashboard_screen.dart';

class _MaintenanceButtonData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _MaintenanceButtonData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}

class _TaskCard extends StatelessWidget {
  final TaskItemEntity task;
  final bool isSmallScreen;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isSmallScreen,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: isSmallScreen ? _buildSmallLayout(context) : _buildLargeLayout(context),
    );
  }

  Widget _buildSmallLayout(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          title: Text(
            task.content,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _buildBadge(
                  TaskTranslationMap.getCategoryTranslation(
                    task.category,
                    LocaleProvider.of(context).languageCode,
                  ),
                  AppColors.accent,
                ),
                const SizedBox(width: 8),
                _buildBadge(task.difficulty.toUpperCase(), Colors.white60),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LikeBadge(likes: task.likes, dislikes: task.dislikes, isSmall: true),
              const SizedBox(width: 8),
              Switch(
                value: task.isActive,
                activeThumbColor: AppColors.accent,
                onChanged: onToggleActive,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white70),
                  label: Text(l.adminEditButton, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, size: 16, color: AppColors.primary),
                  label: Text(l.adminDeleteButton, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeLayout(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        task.content,
        style: AppTextStyles.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _LikeBadge(likes: task.likes, dislikes: task.dislikes, isSmall: false),
            const SizedBox(width: 12),
            _buildBadge(
              TaskTranslationMap.getCategoryTranslation(
                task.category,
                LocaleProvider.of(context).languageCode,
              ),
              AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            ),
            const SizedBox(width: 8),
            _buildBadge(task.difficulty.toUpperCase(), Colors.white60, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: task.isActive,
            activeThumbColor: AppColors.accent,
            onChanged: onToggleActive,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.primary, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == AppColors.accent ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: padding != null ? 11 : 10,
          fontWeight: color == AppColors.accent ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}

class _LikeBadge extends StatelessWidget {
  final int likes;
  final int dislikes;
  final bool isSmall;

  const _LikeBadge({
    required this.likes,
    required this.dislikes,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.thumb_up_rounded, size: isSmall ? 12 : 14, color: Colors.green.shade400),
        const SizedBox(width: 2),
        Text(
          '$likes',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.green.shade400,
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: isSmall ? 4 : 8),
        Icon(Icons.thumb_down_rounded, size: isSmall ? 12 : 14, color: Colors.red.shade400),
        const SizedBox(width: 2),
        Text(
          '$dislikes',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.red.shade400,
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
