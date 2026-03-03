import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';

/// Gişe ve Kulis (Mağaza) Ekranı — Tiyatro Temalı
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int _selectedTab = 0; // 0: Roller, 1: Maskeler, 2: Senaryolar

  Future<void> _buyItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
  ) async {
    try {
      await ref
          .read(economyControllerProvider.notifier)
          .buyCosmetic(uid: uid, cosmeticId: item.id, price: item.price);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} artık gardırobunuzda!',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hata: ${e.toString().replaceAll('Exception: ', '')}',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
        ),
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
        title: Text(
          'Mağaza',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 2,
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
          _buildWalletIndicator(userProfileAsync),
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
                'Hata: $err',
                style: GoogleFonts.playfairDisplay(color: AppColors.primary),
              ),
            ),
            data: (items) {
              final profile = userProfileAsync.value;
              final owned = profile?.ownedCosmetics ?? [];
              final roleItems = items.where((i) => i.type == 'title').toList();
              final maskItems = items.where((i) => i.type == 'frame').toList();

              return Column(
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
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (isAnonymous) _buildLockedOverlay(),
        ],
      ),
    );
  }

  Widget _buildWalletIndicator(AsyncValue<dynamic> userProfileAsync) {
    return Container(
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
            Icons.confirmation_number_rounded,
            color: AppColors.accent,
            size: 16,
          ),
          const SizedBox(width: 8),
          userProfileAsync.when(
            data: (profile) => Text(
              '${profile?.walletPoints ?? 0}',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontSize: 14,
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
    );
  }

  Widget _buildTabSelector() {
    final tabs = ['Roller', 'Maskeler', 'Senaryolar'];
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
                    style: GoogleFonts.playfairDisplay(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w500,
                      fontSize: 10,
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
  }) {
    List<CosmeticItemEntity> displayItems;
    String title;
    IconData icon;

    switch (_selectedTab) {
      case 0:
        displayItems = roleItems;
        title = 'Repertuar Rolleri';
        icon = Icons.theater_comedy_rounded;
        break;
      case 1:
        displayItems = maskItems;
        title = 'Antik Maskeler';
        icon = Icons.face_retouching_natural_rounded;
        break;
      default:
        displayItems = [
          const CosmeticItemEntity(
            id: 'scenario_18',
            name: 'Kapalı Gişe (+18)',
            description: 'Sadece yetişkin aktörler için dramatik bir senaryo.',
            imageUrl: '🔞',
            price: 1500,
            type: 'category',
          ),
          const CosmeticItemEntity(
            id: 'scenario_comedy',
            name: 'Fars Komedisi',
            description: 'Kahkaha garantili, hafif ve eğlenceli içerikler.',
            imageUrl: '🎭',
            price: 800,
            type: 'preset',
          ),
          const CosmeticItemEntity(
            id: 'scenario_tragedy',
            name: 'Antik Trajedi',
            description: 'Derin, karanlık ve sarsıcı bir performans içeriği.',
            imageUrl: '💀',
            price: 1200,
            type: 'category',
          ),
          const CosmeticItemEntity(
            id: 'scenario_romance',
            name: 'Aşkın Sahnesi',
            description: 'Romantik ve duygu dolu repliklerle dolu bir içerik.',
            imageUrl: '❤️',
            price: 900,
            type: 'preset',
          ),
          const CosmeticItemEntity(
            id: 'scenario_mystery',
            name: 'Gizemli Perde',
            description:
                'Gerilim ve gizem dolu, seyirciyi ekrana kitleyen sorular.',
            imageUrl: '🔍',
            price: 1100,
            type: 'category',
          ),
          const CosmeticItemEntity(
            id: 'scenario_sci_fi',
            name: 'Geleceğin Rolü',
            description: 'Fütüristik ve bilimkurgu temalı ilginç senaryolar.',
            imageUrl: '🚀',
            price: 1300,
            type: 'preset',
          ),
        ];
        title = 'Özel Senaryolar';
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
                'Henüz sergilenecek ürün yok.',
                style: GoogleFonts.libreBaskerville(
                  color: Colors.white24,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                color: AppColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white10, height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            final isOwned = owned.contains(item.id);
            return _buildItemCard(context, ref, uid, item, isOwned);
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
    bool isOwned,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(item.imageUrl, style: const TextStyle(fontSize: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (isOwned)
                  Text(
                    'Gardırupta',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _buyItem(context, ref, uid, item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.confirmation_number_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.price}',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
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
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.accent, size: 64),
              const SizedBox(height: 24),
              Text(
                'Sahne Arkasına Geçin',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kostüm ve rolleri seçmek için bir aktör hesabı oluşturmalısınız.',
                textAlign: TextAlign.center,
                style: GoogleFonts.libreBaskerville(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              StageButton(
                label: 'Giriş Yap',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderColor: AppColors.accent,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
