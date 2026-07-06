part of 'custom_deck_editor_screen.dart';

extension _CustomDeckEditorBody on _CustomDeckEditorScreenState {
  Widget _buildEditorScreen() {
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) {
      return Scaffold(
        backgroundColor: _CustomDeckEditorScreenState._bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: _CustomDeckEditorScreenState._accentGold),
        ),
      );
    }

    final userAsync = ref.watch(watchUserProfileProvider(authUser.uid));

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: _CustomDeckEditorScreenState._bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: _CustomDeckEditorScreenState._accentGold),
        ),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: _CustomDeckEditorScreenState._bgColor,
        body: Center(
          child: AsyncErrorView(
            message: l.loadFailed,
            detail: ErrorMessageUtils.formatUserError(e, l),
            onRetry: () => ref.invalidate(
              watchUserProfileProvider(authUser.uid),
            ),
            secondaryLabel: l.goHome,
            onSecondary: () => context.pop(),
          ),
        ),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final premiumService = ref.read(premiumPurchaseServiceProvider);
        premiumService.init();

        if (!user.isPremium) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                l.myContentsTitle,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.accent),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 62),
                    const SizedBox(height: 16),
                    Text(
                      l.premiumRequiredTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.premiumRequiredDesc,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await premiumService.buyLifetimePremium();
                          if (!mounted) return;
                          ToastUtils.showSuccess(
                            context,
                            l.purchaseFlowStarted,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
                        }
                      },
                      icon: const Icon(Icons.lock_open_rounded),
                      label: Text(l.buyPremium),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await premiumService.restorePurchases();
                          if (!mounted) return;
                          ToastUtils.showSuccess(context, l.restoringPurchases);
                        } catch (e) {
                          if (!mounted) return;
                          ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
                        }
                      },
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(l.restorePurchases),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final customTasksAsync = ref.watch(watchCustomTasksProvider(user.uid));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              l.myContentsTitle,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 18,),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.accent,
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
                onPressed: () => _showTaskDialog(user),
                tooltip: l.createContent,
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0D0D1A),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
              // Accent glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Kategori Filtreleme (Chips) kaldırıldı
                    Expanded(
                      child: customTasksAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: _CustomDeckEditorScreenState._accentGold),
                        ),
                        error: (err, stack) => Center(
                          child: AsyncErrorView(
                            message: l.loadFailed,
                            detail: ErrorMessageUtils.formatUserError(err, l),
                            onRetry: () => ref.invalidate(
                              watchCustomTasksProvider(user.uid),
                            ),
                          ),
                        ),
                        data: (allTasks) {
                          final tasks = allTasks;

                          if (tasks.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_stories_outlined,
                                      color: AppColors.accent.withValues(alpha: 0.3),
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l.myContentsDescription,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l.myContentsUsage,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white38,
                                        fontSize: 13,
                                        height: 1.5,),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () => _showTaskDialog(user),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      ),
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(l.createContent, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                              bottom: 80,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];

                              return Stack(
                                children: [
                                  Card(
                                    color: _CustomDeckEditorScreenState._cardColor.withValues(alpha: 0.9),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.1,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Kalem / Tüy İkonu
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _CustomDeckEditorScreenState._accentGold.withValues(
                                                alpha: 0.1,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _CustomDeckEditorScreenState._accentGold.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.history_edu_rounded,
                                              color: _CustomDeckEditorScreenState._accentGold,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.content,
                                                  style: AppTextStyles.titleMedium.copyWith(color: _CustomDeckEditorScreenState._textLight,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.4,),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: _CustomDeckEditorScreenState._accentGold
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                          task.category == 'Özel' ? l.specialCategory : task.category,
                                                          style:
                                                              AppTextStyles.labelSmall.copyWith(color:
                                                                    _CustomDeckEditorScreenState._accentGold,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,),
                                                        ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.grey
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                          task.difficulty ==
                                                                  'easy'
                                                              ? l.easyDifficulty.toUpperCase()
                                                              : task.difficulty ==
                                                                    'medium'
                                                              ? l.mediumDifficulty.toUpperCase()
                                                              : l.hardDifficulty.toUpperCase(),
                                                        style:
                                                            AppTextStyles.labelSmall.copyWith(color: Colors
                                                                  .grey
                                                                  .shade400,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_note_rounded,
                                                  color: _CustomDeckEditorScreenState._accentGold,
                                                ),
                                                onPressed: () =>
                                                    _showTaskDialog(
                                                      user,
                                                      editingTask: task,
                                                    ),
                                                tooltip: l.editTooltip,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: _CustomDeckEditorScreenState._accentCrimson,
                                                ),
                                                onPressed: () => ref
                                                    .read(
                                                      customTaskControllerProvider
                                                          .notifier,
                                                    )
                                                    .deleteTask(
                                                      uid: user.uid,
                                                      taskId: task.id,
                                                    ),
                                                tooltip: l.deleteTooltip,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}