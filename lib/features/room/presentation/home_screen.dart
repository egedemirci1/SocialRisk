import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/video_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../economy/domain/cosmetic_item_entity.dart';

/// Ana menü ekranı — Orta Çağ Temalı Oda Oluştur veya Odaya Katıl.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const overlayColor = Color(0xFF140D0B); // Koyu kahve/siyah tonu

    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null
        ? ref.watch(watchUserProfileProvider(user.uid))
        : const AsyncValue.loading();
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    final displayName = user?.displayName ?? 'Oyuncu';
    final profile = userProfileAsync.value;
    final cosmetics = cosmeticsAsync.value ?? [];
    final avatarUrl = profile?.avatarUrl;
    final showImage = avatarUrl != null && avatarUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: overlayColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Gradient (Fallback)
          const GradientContainer(child: SizedBox.shrink()),

          // 2. Video Background
          const VideoBackground(videoPath: 'assets/videos/Main-Screen.mp4'),

          // 2. Koyu Katman (Taverna atmosferi)
          Container(color: overlayColor.withOpacity(0.5)),

          // 3. İçerik
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildWelcome(
                    context,
                    displayName,
                    avatarUrl,
                    showImage,
                    profile,
                    cosmetics,
                    user?.uid,
                  ),
                  const Spacer(),
                  _buildActions(context, user),
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
    String? avatarUrl,
    bool showImage,
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
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              PlayerAvatar(
                displayName: playerName,
                avatarUrl: showImage ? avatarUrl : null,
                radius: 40,
                uid: uid,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF5C1616),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.history_edu_rounded,
                    color: Color(0xFFFDEFC2),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hoş geldin,',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFD4AF37).withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: GoogleFonts.cinzelDecorative(
            color: const Color(0xFFFDEFC2),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            shadows: [
              const Shadow(
                color: Colors.black87,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        if (activeTitleItem != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E140F).withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${activeTitleItem.imageUrl} ${activeTitleItem.name}',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, User? user) {
    // Ortak renkler
    const bgColor = Color(0xFF5C1616); // Crimson
    const textColor = Color(0xFFFDEFC2);
    final borderColor = const Color(0xFFD4AF37).withOpacity(0.6);

    const secondaryBg = Color(0xFF1E140F); // Koyu kahve

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MedievalButton(
          label: 'Oda Oluştur',
          icon: Icons.add_circle_outline_rounded,
          backgroundColor: bgColor,
          textColor: textColor,
          borderColor: borderColor,
          onPressed: () => context.push('/create-room'),
        ),
        const SizedBox(height: 16),
        MedievalButton(
          label: 'Odaya Katıl',
          icon: Icons.login_rounded,
          backgroundColor: secondaryBg,
          textColor: const Color(0xFFD4AF37), // Altın rengi metin
          borderColor: borderColor,
          onPressed: () => context.push('/join-room'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: MedievalButton(
                label: 'Mağaza',
                icon: Icons.storefront_rounded,
                backgroundColor: secondaryBg,
                textColor: const Color(0xFFD4AF37),
                borderColor: borderColor,
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MedievalButton(
                label: 'Desten',
                icon: Icons.style_rounded,
                backgroundColor: secondaryBg,
                textColor: const Color(0xFFD4AF37),
                borderColor: borderColor,
                onPressed: () => context.push('/custom-deck'),
              ),
            ),
          ],
        ),
        if (isAdmin(user?.uid)) ...[
          const SizedBox(height: 24),
          MedievalButton(
            label: 'Admin Paneli',
            icon: Icons.admin_panel_settings_rounded,
            backgroundColor: const Color(0xFF2C1E16), // Açık kahve
            textColor: Colors.amber,
            borderColor: Colors.amber.withOpacity(0.5),
            onPressed: () => context.push('/admin'),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return InteractiveButton(
      onTap: () async {
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) context.go('/');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.logout_rounded,
            size: 20,
            color: Color(0xFFD4AF37), // Altın rengi
          ),
          const SizedBox(width: 8),
          Text(
            'Çıkış Yap',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
