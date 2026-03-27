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
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../profile/presentation/widgets/achievements_widget.dart';

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

  AppLocalizations get l => AppLocalizations.of(context)!;

  Future<void> _updateDisplayName(UserEntity user) async {
    final controller = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l.updateDisplayNameTitle,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
        ),
        content: TextField(
          controller: controller,
          maxLength: 16,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l.newDisplayNameLabel,
            labelStyle: const TextStyle(color: Colors.white70),
            counterStyle: const TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.update),
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
        if (mounted) ToastUtils.showSuccess(context, l.profileUpdated);
      } else {
        ToastUtils.showError(context, l.invalidNameLong);
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
            l.editProfileTitle,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: 1.0,
              fontSize: 16,
            ),
          ),
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
                  l.error(err.toString()),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (userProfile) {
                // Auth'tan gelen ismi tercih et (Firestore'da 'Misafir' olabilir)
                final authName = user.displayName ?? l.playerDefaultName;
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
                return ResponsiveWrapper(
                  maxWidth: 600,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: _buildTabBar(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_selectedTabIndex == 0)
                                _buildActorTab(profile, userProfileAsync),
                              if (_selectedTabIndex == 1)
                                _buildWardrobeTab(profile, userProfileAsync),
                              if (_selectedTabIndex == 2)
                                _buildPerformanceTab(userProfileAsync),
                            ],
                          ),
                        ),
                      ),
                    ],
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
            title: l.actorTab,
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          _TabItem(
            title: l.wardrobeTab,
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          _TabItem(
            title: l.performanceTab,
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
          Expanded(
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

class _QuickStatsWidget extends StatelessWidget {
  final UserEntity user;
  const _QuickStatsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final gamesPlayed = user.stats['games_played'] ?? 0;
    final gamesWon = user.stats['games_won'] ?? 0;
    final winRate = gamesPlayed > 0 ? (gamesWon / gamesPlayed * 100).round() : 0;
    final totalPoints = user.walletPoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                l.quickStatsTitle,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.casino_rounded, '$gamesPlayed', l.gameLabel),
              _buildStatItem(Icons.trending_up_rounded, '$winRate%', l.winLabel),
              _buildStatItem(Icons.star_rounded, '$totalPoints', l.pointsLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
