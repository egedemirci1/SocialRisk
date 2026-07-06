part of 'store_screen.dart';

extension _StoreScreenBuilders on _StoreScreenState {
  Widget _buildWalletIndicator(
    AsyncValue<dynamic> userProfileAsync,
    String uid,
  ) {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cüzdan göstergesi
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              userProfileAsync.when(
                data: (profile) => Text(
                  '${profile?.walletPoints ?? 0}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
                error: (_, __) => GestureDetector(
                  onTap: () => ref.invalidate(watchUserProfileProvider(uid)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.walletUnavailable,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    final l = AppLocalizations.of(context)!;
    final tabs = [l.titlesTab, l.framesTab, l.scenariosTab];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setSelectedTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required WidgetRef ref,
    required String uid,
    required List<String> owned,
    required List<CosmeticItemEntity> roleItems,
    required List<CosmeticItemEntity> maskItems,
    required bool isPremium,
    required bool isAnonymous,
    required AsyncValue<List<CosmeticItemEntity>> cosmeticsAsync,
  }) {
    final l = AppLocalizations.of(context)!;
    List<CosmeticItemEntity> displayItems;
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedTab) {
      case 0:
        displayItems = roleItems;
        title = l.titlesTab;
        subtitle = l.titlesTabSubtitle;
        icon = Icons.badge_rounded;
        break;
      case 1:
        displayItems = maskItems;
        title = l.framesTab;
        subtitle = l.framesTabSubtitle;
        icon = Icons.face_retouching_natural_rounded;
        break;
      default:
        if (cosmeticsAsync.hasError) {
          return AsyncErrorView(
            message: l.loadFailed,
            onRetry: () => ref.invalidate(fetchCosmeticsProvider),
          );
        }
        if (cosmeticsAsync.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        displayItems = cosmeticsAsync.value
                ?.where((c) => c.type == 'category')
                .toList() ??
            [];
        title = l.scenariosTab;
        subtitle = l.scenariosTabSubtitle;
        icon = Icons.menu_book_rounded;
    }

    if (displayItems.isEmpty) {
      final emptyMessage = _selectedTab == 2
          ? l.scenariosComingSoon
          : l.noItems;
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Icon(
                _selectedTab == 2
                    ? Icons.auto_stories_outlined
                    : Icons.inventory_2_outlined,
                color: Colors.white10,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white10, height: 24),
        ...displayItems.map((item) {
          final isOwned = owned.contains(item.id);
          return _buildCompactItem(
            context,
            ref,
            uid,
            item,
            isOwned,
            isPremium: isPremium,
          );
        }),
      ],
    );

    if (_selectedTab == 2) {
      return content;
    }

    return content;
  }

  Widget _buildCompactItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
    bool isOwned,
    {required bool isPremium}
  ) {
    final isPremiumScenario = item.type == 'category';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (isOwned)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: -2,
            ),
        ],
      ),
      child: Row(
        children: [
          // Emoji/Icon Container with Glass effect
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: _buildStoreItemIcon(item.imageUrl),
          ),
          const SizedBox(width: 16),
          // İsim + Açıklama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'tr' ? item.name : item.nameEn,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Localizations.localeOf(context).languageCode == 'tr' ? item.description : item.descriptionEn,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Fiyat veya Sahiplik durumu
          if (isOwned)
            Container(
              width: 85,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.ownedLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
          else if (isPremiumScenario && !isPremium)
            GestureDetector(
              onTap: () async {
                final premiumService = ref.read(premiumPurchaseServiceProvider);
                try {
                  await premiumService.buyLifetimePremium();
                  if (!context.mounted) return;
                  ToastUtils.showSuccess(context, AppLocalizations.of(context)!.purchaseFlowStarted);
                } catch (e) {
                  if (!context.mounted) return;
                  final l = AppLocalizations.of(context)!;
                  ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
                }
              },
              child: Container(
                width: 92,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.premiumLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _buyItem(context, ref, uid, item),
              child: Container(
                width: 85,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.price}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreItemIcon(String imageUrl) {
    final isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white38,
            size: 24,
          ),
        ),
      );
    }
    return Text(imageUrl, style: const TextStyle(fontSize: 26));
  }
}