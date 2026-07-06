part of 'admin_dashboard_screen.dart';

extension _AdminDashboardScreenBuilders on _AdminDashboardScreenState {
  Widget _buildInfoBanner(int total, int filtered, bool isSmall) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 12, isSmall ? 12 : 20, 8),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accent, size: isSmall ? 24 : 28),
            SizedBox(width: isSmall ? 8 : 12),
            Expanded(
              child: Text(
                l.adminTaskCountBanner(total, filtered),
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceButtons(bool isSmall, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final buttons = [
      _MaintenanceButtonData(
        label: l.adminMaintenanceCleanup,
        icon: Icons.cleaning_services_rounded,
        color: AppColors.primary,
        onPressed: () => _runMaintenanceCleanup(context, ref),
      ),
      _MaintenanceButtonData(
        label: l.adminRefreshTasks,
        icon: Icons.refresh_rounded,
        color: AppColors.accent,
        onPressed: () => _runSeedTasks(context, ref),
      ),
      _MaintenanceButtonData(
        label: l.adminDeleteOldRooms,
        icon: Icons.delete_forever_rounded,
        color: Colors.red.shade700,
        onPressed: () => _runForceCleanup(context, ref),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 8, isSmall ? 12 : 20, 8),
      child: isSmall
          ? Column(
              children: buttons
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildMaintenanceButton(b, true),
                      ))
                  .toList(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMaintenanceButton(buttons[0], false)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMaintenanceButton(buttons[1], false)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _buildMaintenanceButton(buttons[2], false),
                ),
              ],
            ),
    );
  }

  Widget _buildMaintenanceButton(_MaintenanceButtonData data, bool isSmall) {
    return ElevatedButton.icon(
      onPressed: data.onPressed,
      icon: Icon(data.icon, color: Colors.white, size: isSmall ? 18 : 20),
      label: Text(
        data.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: data.color,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 10 : 14,
          horizontal: isSmall ? 8 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFilters(List<String> categories, bool isSmall) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 8, isSmall ? 12 : 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.adminSortLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white70,
                  fontSize: isSmall ? 12 : 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SortOption>(
                      value: _sortOption,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: isSmall ? 12 : 14,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      onChanged: (value) {
                        if (value != null) _setSortOption(value);
                      },
                      items: [
                        DropdownMenuItem(
                          value: SortOption.newest,
                          child: Text(l.adminSortNewest, style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.mostLiked,
                          child: Text(l.adminSortMostLiked, style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.leastLiked,
                          child: Text(l.adminSortLeastLiked, style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.mostDisliked,
                          child: Text(l.adminSortMostDisliked, style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.adminCategoryFilterLabel,
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white70,
              fontSize: isSmall ? 12 : 14,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l.adminFilterAll),
                  selected: _selectedCategory == null,
                  onSelected: (_) => _setSelectedCategory(null),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: _selectedCategory == null ? Colors.black : Colors.white,
                    fontSize: isSmall ? 11 : 13,
                  ),
                ),
                ...categories.map((category) => FilterChip(
                  label: Text(TaskTranslationMap.getCategoryTranslation(
                    category,
                    LocaleProvider.of(context).languageCode,
                  )),
                  selected: _selectedCategory == category,
                  onSelected: (_) => _setSelectedCategory(category),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category ? Colors.black : Colors.white,
                    fontSize: isSmall ? 11 : 13,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskItemEntity> tasks, bool isSmall, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    if (tasks.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            l.adminNoMatchingTasks,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white24,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 20,
          vertical: 8,
        ),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(
            task: task,
            isSmallScreen: isSmall,
            onToggleActive: (val) {
              ref.read(adminControllerProvider.notifier).toggleTaskActiveStatus(task.id, val);
            },
            onEdit: () => context.push('/admin/task-editor', extra: task),
            onDelete: () => _deleteTask(context, ref, task),
          );
        },
      ),
    );
  }

  List<String> _getCategories(List<TaskItemEntity> tasks) {
    final categories = tasks.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<TaskItemEntity> _filterAndSortTasks(List<TaskItemEntity> tasks) {
    var filtered = _selectedCategory == null
        ? tasks
        : tasks.where((t) => t.category == _selectedCategory).toList();

    switch (_sortOption) {
      case SortOption.mostLiked:
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
      case SortOption.leastLiked:
        filtered.sort((a, b) => a.likes.compareTo(b.likes));
      case SortOption.mostDisliked:
        filtered.sort((a, b) => b.dislikes.compareTo(a.dislikes));
      case SortOption.newest:
        break;
    }

    return filtered;
  }

  Future<void> _runMaintenanceCleanup(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      context,
      title: l.adminMaintenanceCleanupTitle,
      content: l.adminMaintenanceCleanupBody,
      confirmText: l.adminRun,
      confirmColor: AppColors.primary,
    );
    if (confirm == true) {
      try {
        final result = await ref.read(adminControllerProvider.notifier).runMaintenanceCleanup();
        if (context.mounted) {
          ToastUtils.showSuccess(
            context,
            l.adminMaintenanceCleanupResult(
              result['roomsDeleted'] as int? ?? 0,
              result['gamesDeleted'] as int? ?? 0,
              result['usersDeleted'] as int? ?? 0,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showError(
            context,
            l.error(ErrorMessageUtils.formatUserError(e, l)),
          );
        }
      }
    }
  }

  Future<void> _runSeedTasks(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      context,
      title: l.adminRefreshTasksTitle,
      content: l.adminRefreshTasksBody,
      confirmText: l.adminRefresh,
      confirmColor: AppColors.accent,
    );
    if (confirm == true) {
      try {
        await ref.read(adminControllerProvider.notifier).seedTasks();
        if (context.mounted) {
          ToastUtils.showSuccess(context, l.adminTasksRefreshed);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showError(
            context,
            l.error(ErrorMessageUtils.formatUserError(e, l)),
          );
        }
      }
    }
  }

  Future<void> _runForceCleanup(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      context,
      title: l.adminForceCleanupTitle,
      content: l.adminForceCleanupBody,
      confirmText: l.adminDeleteConfirm,
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      try {
        final count = await ref.read(adminControllerProvider.notifier).forceCleanupOldPlayingRooms();
        if (context.mounted) {
          ToastUtils.showSuccess(context, l.adminForceCleanupResult(count));
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showError(
            context,
            l.error(ErrorMessageUtils.formatUserError(e, l)),
          );
        }
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref, TaskItemEntity task) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      context,
      title: l.adminDeleteTaskTitle,
      content: l.adminDeleteTaskBody,
      confirmText: l.adminDeleteConfirm,
      confirmColor: AppColors.primary,
    );
    if (confirm == true) {
      await ref.read(adminControllerProvider.notifier).deleteTask(task.id);
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    final l = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          content,
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.adminCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }
}
