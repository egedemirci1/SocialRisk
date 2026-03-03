import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

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
            '${item.name} satın alındı!',
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
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
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _accentCrimson,
        ),
      );
    }
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
        content: Text(
          '${item.name} kuşandın.',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _accentGold)),
      );
    }

    final userProfileAsync = ref.watch(watchUserProfileProvider(user.uid));
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Mağaza',
          style: GoogleFonts.cinzelDecorative(
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _accentGold),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // Testing amaçlı para ekleme butonu
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: 'Test Parası Ekle',
                  onPressed: () async {
                    try {
                      await ref
                          .read(economyControllerProvider.notifier)
                          .addPointsToWallet(uid: user.uid, points: 10000);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Test parası eklendi! (+10,000)',
                            style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.green.shade800,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Hata: $e',
                            style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: _accentCrimson,
                        ),
                      );
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accentGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: _accentGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      userProfileAsync.when(
                        data: (profile) => Text(
                          profile?.walletPoints.toString() ?? '0',
                          style: GoogleFonts.cinzel(
                            color: _accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accentGold,
                          ),
                        ),
                        error: (e, stack) => Text(
                          '0',
                          style: GoogleFonts.cinzel(
                            color: _accentGold,
                            fontWeight: FontWeight.bold,
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
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka Plan Resmi
          Image.asset(
            'assets/Loading-Screen-Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          // Karartma (Overlay)
          Container(color: _bgColor.withOpacity(0.85)),

          SafeArea(
            child: cosmeticsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _accentGold),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Mağaza yüklenemedi: $err',
                  style: GoogleFonts.cinzel(
                    color: _accentCrimson,
                    fontSize: 16,
                  ),
                ),
              ),
              data: (items) {
                final profile = userProfileAsync.value;
                final owned = profile?.ownedCosmetics ?? [];
                final titleItems = items.where((i) => i.type == 'title').toList();
                final frameItems = items.where((i) => i.type == 'frame').toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ünvanlar Bölümü ──
                      _sectionHeader('Ünvanlar', Icons.military_tech_rounded),
                      const SizedBox(height: 10),
                      for (final item in titleItems)
                        _itemCard(context, ref, user.uid, item, owned, profile),

                      const SizedBox(height: 24),

                      // ── Çerçeveler Bölümü ──
                      _sectionHeader('Çerçeveler', Icons.filter_frames_rounded),
                      const SizedBox(height: 10),
                      for (final item in frameItems)
                        _itemCard(context, ref, user.uid, item, owned, profile),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Bölüm Başlığı ──
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: _accentGold, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cinzelDecorative(
              color: _accentGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: _accentGold.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kompakt Satır Kartı ──
  Widget _itemCard(
    BuildContext context,
    WidgetRef ref,
    String uid,
    CosmeticItemEntity item,
    List<String> owned,
    dynamic profile,
  ) {
    final isOwned = owned.contains(item.id);
    final itemColor = item.type == 'frame'
        ? const Color(0xFFC44536)
        : _accentGold;
    final isEquipped = profile != null &&
        ((item.type == 'frame' && profile.activeFrame == item.id) ||
            (item.type == 'title' && profile.activeTitle == item.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isEquipped
              ? _accentGold.withValues(alpha: 0.12)
              : _cardColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped
                ? _accentGold
                : itemColor.withValues(alpha: 0.2),
            width: isEquipped ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Emoji İkon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: itemColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: itemColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  item.imageUrl,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // İsim
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.cinzel(
                  color: _textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            // Buton
            if (isOwned)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped ? Colors.black38 : _accentCrimson,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: _accentGold.withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _equipItem(context, ref, uid, item),
                child: Text(
                  isEquipped ? 'Kuşanıldı' : 'Kuşan',
                  style: GoogleFonts.cinzel(
                    color: isEquipped ? Colors.white38 : _textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardColor,
                  foregroundColor: _accentGold,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: _accentGold.withValues(alpha: 0.4)),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _buyItem(context, ref, uid, item),
                icon: const Icon(
                  Icons.monetization_on_rounded,
                  size: 14,
                  color: _accentGold,
                ),
                label: Text(
                  item.price.toString(),
                  style: GoogleFonts.cinzel(
                    color: _textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
