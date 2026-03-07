import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/domain/user_entity.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

/// Test override: null ise gerçek ImagePicker kullanılır; override ile () async => null verilerek iptal simüle edilir.
final pickImageFromGalleryProvider = Provider<Future<XFile?> Function()?>((ref) => null);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTabIndex = 0; // 0: Profil, 1: Gardırop, 2: Performans
  bool _isUploading = false;

  Future<void> _updateDisplayName(UserEntity user) async {
    final controller = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Oyuncu Adını Güncelle',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
        ),
        content: TextField(
          controller: controller,
          maxLength: 24,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Yeni Oyuncu Adı',
            labelStyle: TextStyle(color: Colors.white70),
            counterStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('GÜNCELLE'),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      final name = newName.trim();
      final nameRegex = RegExp(r'^[a-zA-Z0-9ığüşöçİĞÜŞÖÇ ]+$');
      
      if (name.length >= 3 && nameRegex.hasMatch(name)) {
        final updatedUser = user.copyWith(displayName: name);
        await ref
            .read(userControllerProvider.notifier)
            .updateUserProfile(updatedUser);
        if (mounted) ToastUtils.showSuccess(context, 'Profil güncellendi!');
      } else {
        ToastUtils.showError(context, 'Lütfen geçerli bir isim giriniz! (En az 3 karakter, sadece harf ve sayı)');
      }
    }
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final pick = ref.read(pickImageFromGalleryProvider);
    final image = pick != null
        ? await pick()
        : await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 512,
            maxHeight: 512,
            imageQuality: 70,
          );

    if (image != null) {
      if (!mounted) return;
      setState(() => _isUploading = true);

      try {
        // Zaten ImagePicker tarafından küçültüldüğü için doğrudan byteları alıp yükleyebiliriz
        // Ağır çalışan pure-dart ImageCompressor'ı devreden çıkardık
        final rawBytes = await image.readAsBytes();

        final url = await ref
            .read(userControllerProvider.notifier)
            .uploadAvatar(uid, rawBytes);

        if (url != null && mounted) {
          await ref
              .read(userControllerProvider.notifier)
              .updateAvatarUrl(uid, url);
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, 'Hata: ${e.toString()}');
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(
      watchUserProfileProvider(user?.uid ?? ''),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profilinizi Düzenleyin',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 1.0,),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : userProfileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Hata: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (userProfile) {
                // Auth'tan gelen ismi tercih et (Firestore'da 'Misafir' olabilir)
                final authName = user.displayName ?? 'Oyuncu';
                UserEntity profile;
                if (userProfile == null) {
                  profile = UserEntity(
                    uid: user.uid,
                    displayName: authName,
                    avatarUrl: user.photoURL,
                  );
                } else {
                  // Firestore'daki isim 'Misafir' ise Auth ismini kullan
                  final effectiveName = (userProfile.displayName == 'Misafir')
                      ? authName
                      : userProfile.displayName;
                  profile = userProfile.copyWith(displayName: effectiveName);
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildTabBar(),
                        const SizedBox(height: 32),
                        if (_selectedTabIndex == 0)
                          _buildActorTab(profile, userProfileAsync),
                        if (_selectedTabIndex == 1)
                          _buildWardrobeTab(profile, userProfileAsync),
                        if (_selectedTabIndex == 2)
                          _buildPerformanceTab(userProfileAsync),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

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
            title: 'Profil',
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          _TabItem(
            title: 'Eşyalar',
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          _TabItem(
            title: 'Performans',
            isSelected: _selectedTabIndex == 2,
            onTap: () => setState(() => _selectedTabIndex = 2),
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
          children: [
            Expanded(
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
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 48),
        StageButton(
          label: 'Mağaza',
          icon: Icons.confirmation_number_rounded,
          backgroundColor: AppColors.surface,
          textColor: AppColors.accent,
          borderColor: AppColors.accent.withValues(alpha: 0.5),
          onPressed: () => context.push('/store'),
        ),
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
                  child: Text(
                    'Henüz bir eşyanız yok.\nMağazadaki harika içeriklere göz atmak ister misiniz?',
                    style: AppTextStyles.titleSmall.copyWith(color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,),
                    textAlign: TextAlign.center,
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
                        'Çerçeveler',
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
                        'Ünvanlar',
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
          error: (e, _) =>
              Text('Hata: $e', style: const TextStyle(color: Colors.red)),
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
      onTap: () {
        final notifier = ref.read(economyControllerProvider.notifier);
        if (item.type == 'frame') {
          notifier.setActiveFrame(
            uid: uid,
            cosmeticId: isEquipped ? null : item.id,
          );
        } else {
          notifier.setActiveTitle(
            uid: uid,
            cosmeticId: isEquipped ? null : item.id,
          );
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
                    'Aktif',
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
          'İstatistikler',
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
                  label: 'Bakiye',
                  value: '${p?.walletPoints ?? 0}',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Rütbe',
                  value: p?.rank ?? 'Çırak',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.style_rounded,
                  label: 'Koleksiyon',
                  value: '${p?.ownedCosmetics.length ?? 0} ürün',
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) =>
              Text('Hata: $e', style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white54,
                fontSize: 13,),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(color: isSelected ? AppColors.background : Colors.white54,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13,),
            ),
          ),
        ),
      ),
    );
  }
}
