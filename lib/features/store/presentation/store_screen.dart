import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  void _buyItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
  ) {
    ref
        .read(economyControllerProvider.notifier)
        .buyCosmetic(uid: uid, cosmeticId: item.id, price: item.price)
        .then((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} satın alındı!'),
              backgroundColor: AppColors.votePositive,
            ),
          );
        })
        .catchError((e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hata: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: AppColors.voteNegative,
            ),
          );
        });
  }

  void _equipItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
  ) {
    if (item.type == 'frame') {
      ref
          .read(economyControllerProvider.notifier)
          .setActiveFrame(uid: uid, cosmeticId: item.id);
    } else {
      ref
          .read(economyControllerProvider.notifier)
          .setActiveTitle(uid: uid, cosmeticId: item.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} kuşandın.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userProfileAsync = ref.watch(watchUserProfileProvider(user.uid));
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // Testing amaçlı para ekleme butonu
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.votePositive,
                  ),
                  tooltip: 'Test Parası Ekle',
                  onPressed: () {
                    ref
                        .read(economyControllerProvider.notifier)
                        .addPointsToWallet(uid: user.uid, points: 10000)
                        .then((_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test parası eklendi! (+10,000)'),
                              backgroundColor: AppColors.votePositive,
                            ),
                          );
                        });
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      userProfileAsync.when(
                        data: (profile) => Text(
                          profile?.walletPoints.toString() ?? '0',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.amber,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.amber,
                          ),
                        ),
                        error: (e, stack) => Text(
                          '0',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GradientContainer(
        child: cosmeticsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Mağaza yüklenemedi: $err',
              style: TextStyle(color: AppColors.voteNegative),
            ),
          ),
          data: (items) {
            final profile = userProfileAsync.value;
            final owned = profile?.ownedCosmetics ?? [];

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isOwned = owned.contains(item.id);
                // We fake color based on item.type for UI wow-factor if we don't have color in entity
                final itemColor = item.type == 'frame'
                    ? AppColors.fire
                    : Colors.amber;
                final isEquipped =
                    (item.type == 'frame' && profile?.activeFrame == item.id) ||
                    (item.type == 'title' && profile?.activeTitle == item.id);

                return Card(
                  color: isEquipped
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isEquipped
                          ? AppColors.primary
                          : itemColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: itemColor.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            item.imageUrl, // Assuming icon is temporarily stored in imageUrl like "🔥"
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item.type == 'frame' ? 'Çerçeve' : 'Unvan',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isOwned)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEquipped
                                ? Colors.white24
                                : AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () =>
                              _equipItem(context, ref, user.uid, item),
                          child: Text(
                            isEquipped ? 'Kuşanıldı' : 'Kuşan',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: itemColor.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () =>
                              _buyItem(context, ref, user.uid, item),
                          icon: const Icon(
                            Icons.monetization_on_rounded,
                            size: 16,
                          ),
                          label: Text(item.price.toString()),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
