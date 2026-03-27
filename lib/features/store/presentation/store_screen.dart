import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../economy/domain/economy_exceptions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import 'package:social_risk/l10n/app_localizations.dart';

/// Mağaza Ekranı — Parti Temalı
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _selectedTab = 0; // 0: Ünvanlar, 1: Çerçeveler, 2: Senaryolar

  Future<void> _buyItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
  ) async {
    try {
      final l = AppLocalizations.of(context)!;
      await ref
          .read(economyControllerProvider.notifier)
          .buyCosmetic(uid: uid, cosmeticId: item.id, price: item.price);
      if (!context.mounted) return;
      
      final isTr = Localizations.localeOf(context).languageCode == 'tr';
      final itemName = isTr ? item.name : item.nameEn;
      
      ToastUtils.showSuccess(context, l.itemPurchased(itemName));
    } catch (e) {
      if (!context.mounted) return;
      final l = AppLocalizations.of(context)!;
      final msg = e.toString().replaceAll('Exception: ', '');
      final lowerMsg = msg.toLowerCase();
      final isInsufficient =
          e is InsufficientBalanceException ||
          lowerMsg.contains('yetersiz bakiye') ||
          lowerMsg.contains('insufficient balance');
      ToastUtils.showError(
        context,
        isInsufficient ? l.insufficientBalance : l.buyError(msg),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAnonymous = user.isAnonymous;
    final userProfileAsync = ref.watch(watchUserProfileProvider(user.uid));
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            AppLocalizations.of(context)!.store,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.accent,
              letterSpacing: 2,
              fontSize: 18,
            ),
          ),
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
          _buildWalletIndicator(userProfileAsync, user.uid),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          cosmeticsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            error: (err, stack) => Center(
              child: Text(
                AppLocalizations.of(context)!.buyError(err.toString()),
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
              ),
            ),
            data: (items) {
              final profile = userProfileAsync.value;
              final owned = profile?.ownedCosmetics ?? [];
              final roleItems = items.where((i) => i.type == 'title').toList()
                ..sort((a, b) => a.price.compareTo(b.price));
              final maskItems = items.where((i) => i.type == 'frame').toList()
                ..sort((a, b) => a.price.compareTo(b.price));

              return ResponsiveWrapper(
                maxWidth: 600,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildTabSelector(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: _buildTabContent(
                          context: context,
                          ref: ref,
                          uid: user.uid,
                          owned: owned,
                          roleItems: roleItems,
                          maskItems: maskItems,
                          isAnonymous: isAnonymous,
                          cosmeticsAsync: cosmeticsAsync,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIndicator(
    AsyncValue<dynamic> userProfileAsync,
    String uid,
  ) {
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
                error: (_, _) =>
                    const Text('0', style: TextStyle(color: AppColors.accent)),
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
              onTap: () => setState(() => _selectedTab = index),
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
    required bool isAnonymous,
    required AsyncValue<List<CosmeticItemEntity>> cosmeticsAsync,
  }) {
    final l = AppLocalizations.of(context)!;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    List<CosmeticItemEntity> displayItems;
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedTab) {
      case 0:
        displayItems = roleItems;
        title = l.titlesTab;
        subtitle = isTr 
            ? 'Oyun içinde adınızın altında görünen özel etiketler.'
            : 'Custom labels that appear under your name in-game.';
        icon = Icons.badge_rounded;
        break;
      case 1:
        displayItems = maskItems;
        title = l.framesTab;
        subtitle = isTr
            ? 'Profil fotoğrafınızın etrafında parlayan özel efektler.'
            : 'Special effects glowing around your profile picture.';
        icon = Icons.face_retouching_natural_rounded;
        break;
      default:
        // Senaryo öğelerini göster
        displayItems = cosmeticsAsync.when(
          data: (items) => items.where((c) => c.type == 'category').toList(),
          loading: () => [],
          error: (_, __) => [],
        );
        title = l.scenariosTab;
        subtitle = isTr
            ? 'Oyundaki görev havuzunu belirleyen tema paketleri.'
            : 'Theme packs that determine the task pool in the game.';
        icon = Icons.menu_book_rounded;
    }

    if (displayItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white10,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noItems,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white24,
                ),
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
          return _buildCompactItem(context, ref, uid, item, isOwned);
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
  ) {
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
            child: Text(item.imageUrl, style: const TextStyle(fontSize: 26)),
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
}

