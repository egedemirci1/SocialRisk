part of 'profile_screen.dart';

extension _ProfileScreenBuilders on _ProfileScreenState {
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _TabItem(
            title: l.actorTab,
            isSelected: _selectedTabIndex == 0,
            onTap: () => _setSelectedTab(0),
          ),
          _TabItem(
            title: l.wardrobeTab,
            isSelected: _selectedTabIndex == 1,
            onTap: () => _setSelectedTab(1),
          ),
          _TabItem(
            title: l.performanceTab,
            isSelected: _selectedTabIndex == 2,
            onTap: () => _setSelectedTab(2),
          ),
        ],
      ),
    );
  }

  Widget _buildActorTab(UserEntity user, AsyncValue<dynamic> userProfileAsync) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: PlayerAvatar(
                uid: user.uid,
                displayName: user.displayName,
                avatarUrl: user.avatarUrl,
                radius: 60,
              ),
            ),
            if (_isUploading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _isUploading
                      ? null
                      : () => _pickAndUploadImage(user.uid),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                user.displayName,
                style: AppTextStyles.displayLarge.copyWith(fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(offset: Offset(-1.5, -1.5), color: Colors.black87),
                    Shadow(offset: Offset(1.5, -1.5), color: Colors.black87),
                    Shadow(offset: Offset(1.5, 1.5), color: Colors.black87),
                    Shadow(offset: Offset(-1.5, 1.5), color: Colors.black87),
                    Shadow(offset: Offset(0, 6), color: Colors.black54, blurRadius: 8),
                  ],),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.accent, size: 22),
              onPressed: () => _updateDisplayName(user),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        userProfileAsync.when(
          data: (profile) {
            final activeTitleId = profile?.activeTitle;
            if (activeTitleId == null) return const SizedBox.shrink();

            return Consumer(
              builder: (context, ref, child) {
                final ownedItemsAsync = ref.watch(fetchCosmeticsProvider);
                return ownedItemsAsync.when(
                  data: (items) {
                    final activeTitleItem = items.cast<dynamic>().firstWhere(
                      (item) => item.id == activeTitleId,
                      orElse: () => null,
                    );
                    if (activeTitleItem == null) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AppColors.accentGradient.begin,
                            end: AppColors.accentGradient.end,
                            colors: AppColors.accentGradient.colors
                                .map((c) => c.withValues(alpha: 0.1))
                                .toList(),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          activeTitleItem.name,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  error: (_, __) => AsyncErrorView(
                    compact: true,
                    message: l.loadFailed,
                    onRetry: () => ref.invalidate(fetchCosmeticsProvider),
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 48),
        StageButton(
          label: l.store,
          icon: Icons.shopping_bag_rounded,
          backgroundColor: AppColors.surface,
          textColor: AppColors.accent,
          borderColor: AppColors.accent.withValues(alpha: 0.5),
          onPressed: () => context.push('/store'),
        ),
        const SizedBox(height: 24),
        _QuickStatsWidget(user: user),
      ],
    );
  }

  Widget _buildWardrobeTab(
    UserEntity user,
    AsyncValue<dynamic> userProfileAsync,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
        return cosmeticsAsync.when(
          data: (items) {
            final ownedIds = userProfileAsync.value?.ownedCosmetics ?? [];
            final ownedItems = items
                .where((i) => ownedIds.contains(i.id))
                .toList();
            final frameItems = ownedItems
                .where((i) => i.type == 'frame')
                .toList();
            final titleItems = ownedItems
                .where((i) => i.type == 'title')
                .toList();

            if (ownedItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.noItemsInWardrobe,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      StageButton(
                        label: l.store,
                        icon: Icons.shopping_bag_rounded,
                        backgroundColor: AppColors.surface,
                        textColor: AppColors.accent,
                        borderColor: AppColors.accent.withValues(alpha: 0.5),
                        onPressed: () => context.push('/store'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Çerçeveler bölümü
                if (frameItems.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.framesTab,
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: frameItems.map((item) {
                      final isEquipped =
                          userProfileAsync.value?.activeFrame == item.id;
                      return _buildCosmeticChip(
                        item,
                        isEquipped,
                        user.uid,
                        ref,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                ],
                // Ünvanlar bölümü
                if (titleItems.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.titlesTab,
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: titleItems.map((item) {
                      final isEquipped =
                          userProfileAsync.value?.activeTitle == item.id;
                      return _buildCosmeticChip(
                        item,
                        isEquipped,
                        user.uid,
                        ref,
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: AsyncErrorView(
              message: l.loadFailed,
              detail: ErrorMessageUtils.formatUserError(e, l),
              onRetry: () => ref.invalidate(fetchCosmeticsProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCosmeticChip(
    dynamic item,
    bool isEquipped,
    String uid,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () async {
        final l = AppLocalizations.of(context)!;
        try {
          final notifier = ref.read(economyControllerProvider.notifier);
          if (item.type == 'frame') {
            await notifier.setActiveFrame(
              uid: uid,
              cosmeticId: isEquipped ? null : item.id,
            );
          } else {
            await notifier.setActiveTitle(
              uid: uid,
              cosmeticId: isEquipped ? null : item.id,
            );
          }
          final state = ref.read(economyControllerProvider);
          if (state.hasError) throw state.error!;
        } catch (e) {
          if (context.mounted) {
            ToastUtils.showError(
              context,
              l.error(ErrorMessageUtils.formatUserError(e, l)),
            );
          }
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEquipped
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isEquipped ? AppColors.primary : Colors.white12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(item.imageUrl, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: AppTextStyles.labelSmall.copyWith(color: isEquipped ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isEquipped)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l.activeLabel,
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab(AsyncValue<dynamic> userProfileAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.statsTitle,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.w800,),
        ),
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        userProfileAsync.when(
          data: (profile) {
            final UserEntity? p = profile;
            return Column(
              children: [
                _StatRow(
                  icon: Icons.monetization_on_rounded,
                  label: l.balanceLabel,
                  value: '${p?.walletPoints ?? 0}',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.workspace_premium_rounded,
                  label: l.rankLabel,
                  value: (Localizations.localeOf(context).languageCode == 'tr')
                      ? (p?.calculatedRankTr ?? l.rankBeginner)
                      : (p?.calculatedRankEn ?? l.rankBeginner),
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.style_rounded,
                  label: l.collectionLabel,
                  value: l.itemsCount(p?.ownedCosmetics.length ?? 0),
                ),
                if (p != null) AchievementsWidget(user: p),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: AsyncErrorView(
              message: l.loadFailed,
              detail: ErrorMessageUtils.formatUserError(e, l),
              onRetry: () {
                final uid = ref.read(currentUserProvider)?.uid;
                if (uid != null) {
                  ref.invalidate(watchUserProfileProvider(uid));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
