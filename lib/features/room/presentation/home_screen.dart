import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../../core/constants/app_colors.dart';

/// Ana menü ekranı — Tiyatro Temalı
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null
        ? ref.watch(watchUserProfileProvider(user.uid))
        : const AsyncValue.loading();
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    final displayName = user?.displayName ?? 'Aktör';
    final profile = userProfileAsync.value;
    final cosmetics = cosmeticsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan ışıklandırması (Spotlight efekti gibi)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildWelcome(
                    context,
                    displayName,
                    profile,
                    cosmetics,
                    user?.uid,
                  ),
                  const Spacer(),
                  _buildActions(context, ref, user),
                  const Spacer(flex: 2),
                  _buildFooter(context, ref),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    String playerName,
    UserEntity? profile,
    List<CosmeticItemEntity> cosmetics,
    String? uid,
  ) {
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: PlayerAvatar(
              uid: uid ?? '',
              displayName: playerName,
              radius: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        if (activeTitleItem != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              activeTitleItem.name,
              style: GoogleFonts.playfairDisplay(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageButton(
          label: 'Yeni Sahne Kur',
          icon: Icons.add_circle_outline_rounded,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          borderColor: AppColors.accent,
          onPressed: () => context.push('/create-room'),
        ),
        const SizedBox(height: 12),
        StageButton(
          label: 'Gösteriye Katıl',
          icon: Icons.theater_comedy_rounded,
          backgroundColor: AppColors.surface,
          textColor: AppColors.accent,
          borderColor: AppColors.accent.withValues(alpha: 0.5),
          onPressed: () => context.push('/join-room'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StageButton(
                label: 'Mağaza',
                icon: Icons.confirmation_number_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StageButton(
                label: 'İçerik',
                icon: Icons.menu_book_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/custom-deck'),
              ),
            ),
          ],
        ),
        if (isAdmin(user?.uid)) ...[
          const SizedBox(height: 24),
          StageButton(
            label: 'Yönetmen Paneli',
            icon: Icons.admin_panel_settings_rounded,
            backgroundColor: const Color(0xFF1A1A1A),
            textColor: Colors.amber,
            borderColor: Colors.amber.withValues(alpha: 0.5),
            onPressed: () => context.push('/admin'),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) context.go('/');
      },
      icon: const Icon(Icons.logout_rounded, color: AppColors.accent, size: 20),
      label: Text(
        'Perdeyi Kapat',
        style: GoogleFonts.playfairDisplay(
          color: AppColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
