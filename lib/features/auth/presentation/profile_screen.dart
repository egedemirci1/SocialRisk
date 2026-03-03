import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/image_compressor.dart';
import '../../economy/providers/economy_provider.dart';
import '../../../shared/widgets/common/player_avatar.dart';

/// Profil ekranı — Avatar yükleme, isim değiştirme.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isUploading = false;
  bool _avatarLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(currentUserProvider)?.updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İsim güncellendi!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final rawBytes = await image.readAsBytes();

      // Max 10MB dosya boyutu kontrolü
      const maxUploadSize = 10 * 1024 * 1024; // 10 MB
      if (rawBytes.lengthInBytes > maxUploadSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya boyutu çok büyük (Max: 10MB)')),
          );
          setState(() => _isUploading = false);
        }
        return;
      }

      // Sıkıştır: max 256px, max 1MB
      final bytes = ImageCompressor.compress(rawBytes);
      debugPrint(
        'Avatar sıkıştırma: ${rawBytes.lengthInBytes ~/ 1024}KB → ${bytes.lengthInBytes ~/ 1024}KB',
      );

      final downloadUrl = await ref
          .read(userControllerProvider.notifier)
          .uploadAvatar(user.uid, bytes);

      debugPrint('Avatar upload URL: $downloadUrl');

      if (downloadUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf yüklenemedi, tekrar deneyin.'),
            ),
          );
        }
        return;
      }

      // Force refresh: clear image cache and invalidate user profile provider
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      _avatarLoadFailed = false;
      ref.invalidate(watchUserProfileProvider(user.uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.accent,
              ),
              title: const Text(
                'Galeriden Seç',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.accent,
              ),
              title: const Text(
                'Fotoğraf Çek',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current user for basic info (auth)
    final user = ref.watch(currentUserProvider);
    // User profile from firestore for avatar updates
    final userProfileAsync = user != null
        ? ref.watch(watchUserProfileProvider(user.uid))
        : const AsyncValue<dynamic>.loading();

    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
    final cosmetics = cosmeticsAsync.value ?? [];

    final displayName = user?.displayName ?? 'Oyuncu';
    // Only use Firestore avatarUrl (Google photoURL may 429)
    final avatarUrl = userProfileAsync.value?.avatarUrl;
    final showImage =
        avatarUrl != null && avatarUrl.isNotEmpty && !_avatarLoadFailed;
        
    final activeTitleItem = userProfileAsync.value?.activeTitle != null
        ? cosmetics.where((c) => c.id == userProfileAsync.value!.activeTitle).firstOrNull
        : null;

    // İlk açılışta mevcut ismi doldur
    if (_nameController.text.isEmpty) {
      _nameController.text = displayName;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF140D0B),
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.cinzelDecorative(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFDEFC2),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Loading-Screen-Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          Container(color: const Color(0xFF140D0B).withValues(alpha: 0.85)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _isUploading ? null : _showImageSourceSheet,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            PlayerAvatar(
                              displayName: displayName,
                              avatarUrl: showImage ? avatarUrl : null,
                              radius: 60,
                              uid: user?.uid,
                            ),
                            if (_isUploading)
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                        if (!_isUploading)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 3,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    displayName,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.uid ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white24,
                      fontSize: 11,
                    ),
                  ),

                  if (activeTitleItem != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E140F).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '${activeTitleItem.imageUrl} ${activeTitleItem.name}',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // İsim değiştirme
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Görünen İsim',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'İsminizi girin',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Kaydet',
                    icon: Icons.save_rounded,
                    onPressed: _updateDisplayName,
                    isLoading: _isSaving,
                  ),

                  const SizedBox(height: 40),

                  // İstatistikler (placeholder)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.emoji_events_rounded,
                            label: 'Toplam Puan',
                            value: '0',
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          _StatRow(
                            icon: Icons.videogame_asset_rounded,
                            label: 'Oyun Sayısı',
                            value: '0',
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          _StatRow(
                            icon: Icons.star_rounded,
                            label: 'Seviye',
                            value: 'Yeni',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Kozmetiklerim Bölümü
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kozmetiklerim',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
                        return cosmeticsAsync.when(
                          data: (items) {
                            final ownedIds = userProfileAsync.value?.ownedCosmetics ?? [];
                            final ownedItems = items.where((i) => ownedIds.contains(i.id)).toList();

                            if (ownedItems.isEmpty) {
                              return const Text(
                                'Henüz kozmetik ürününüz yok. Mağazaya göz atın!',
                                style: TextStyle(color: Colors.white38),
                              );
                            }

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ownedItems.map((item) {
                                final isEquipped = (item.type == 'frame' && userProfileAsync.value?.activeFrame == item.id) ||
                                                   (item.type == 'title' && userProfileAsync.value?.activeTitle == item.id);
                                return GestureDetector(
                                  onTap: () {
                                    if (user == null) return;
                                    if (item.type == 'frame') {
                                      if (userProfileAsync.value?.activeFrame == item.id) {
                                        ref.read(economyControllerProvider.notifier).setActiveFrame(uid: user.uid, cosmeticId: null);
                                      } else {
                                        ref.read(economyControllerProvider.notifier).setActiveFrame(uid: user.uid, cosmeticId: item.id);
                                      }
                                    } else {
                                      if (userProfileAsync.value?.activeTitle == item.id) {
                                        ref.read(economyControllerProvider.notifier).setActiveTitle(uid: user.uid, cosmeticId: null);
                                      } else {
                                        ref.read(economyControllerProvider.notifier).setActiveTitle(uid: user.uid, cosmeticId: item.id);
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 90,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isEquipped ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                                      border: Border.all(color: isEquipped ? AppColors.accent : Colors.white12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(item.imageUrl, style: const TextStyle(fontSize: 28)),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            color: isEquipped ? Colors.white : Colors.white70,
                                            fontSize: 10,
                                            fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isEquipped)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              'Kuşanıldı',
                                              style: TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const CircularProgressIndicator(color: AppColors.accent),
                          error: (e, _) => Text('Hata: $e', style: const TextStyle(color: Colors.red)),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mağaza Butonu
                  PrimaryButton(
                    label: 'Mağaza & Cüzdan',
                    icon: Icons.storefront_rounded,
                    onPressed: () => context.push('/store'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
