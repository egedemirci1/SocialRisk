import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';

/// Profil ekranı — Avatar yükleme, isim değiştirme.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

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
      await ref
          .read(currentUserProvider)
          ?.updateDisplayName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İsim güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.displayName ?? 'Oyuncu';
    final avatarUrl = user?.photoURL;

    // İlk açılışta mevcut ismi doldur
    if (_nameController.text.isEmpty) {
      _nameController.text = displayName;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white54,
                            ),
                          )
                        : null,
                  ),
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
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: Colors.white38),
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
                          value: '0'),
                      const Divider(color: Colors.white12, height: 24),
                      _StatRow(
                          icon: Icons.videogame_asset_rounded,
                          label: 'Oyun Sayısı',
                          value: '0'),
                      const Divider(color: Colors.white12, height: 24),
                      _StatRow(
                          icon: Icons.star_rounded,
                          label: 'Seviye',
                          value: 'Yeni'),
                    ],
                  ),
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
