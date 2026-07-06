import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../economy/domain/economy_exceptions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/utils/error_message_utils.dart';
import 'package:social_risk/l10n/app_localizations.dart';

part 'store_screen.builders.part.dart';

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
      final msg = ErrorMessageUtils.formatUserError(e, l);
      final isInsufficient = e is InsufficientBalanceException;
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
    final premiumService = ref.read(premiumPurchaseServiceProvider);
    premiumService.init();

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
            error: (err, stack) {
              final l = AppLocalizations.of(context)!;
              return Center(
                child: AsyncErrorView(
                  message: l.loadFailed,
                  detail: ErrorMessageUtils.formatUserError(err, l),
                  onRetry: () => ref.invalidate(fetchCosmeticsProvider),
                ),
              );
            },
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
                          isPremium: profile?.isPremium ?? false,
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

  void _setSelectedTab(int index) => setState(() => _selectedTab = index);
}