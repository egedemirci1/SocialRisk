import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/admin_provider.dart';

import '../../economy/providers/economy_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../economy/domain/cosmetic_item_entity.dart';

/// Ana menü ekranı — Oda Oluştur veya Odaya Katıl.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null ? ref.watch(watchUserProfileProvider(user.uid)) : const AsyncValue.loading();
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
    
    final displayName = user?.displayName ?? 'Oyuncu';
    final profile = userProfileAsync.value;
    final cosmetics = cosmeticsAsync.value ?? [];
    final avatarUrl = profile?.avatarUrl;
    final showImage = avatarUrl != null && avatarUrl.isNotEmpty;

    return Scaffold(
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildWelcome(context, displayName, avatarUrl, showImage, profile, cosmetics),
            const Spacer(),
            _buildActions(context, user),
            const Spacer(flex: 2),
            _buildFooter(context, ref),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, String playerName, String? avatarUrl, bool showImage, UserEntity? profile, List<CosmeticItemEntity> cosmetics) {
    Widget firstLetterWidget() => Text(
      playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: Colors.white54,
      ),
    );

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
              // Avatarerçeve render'ını HomeScreen'de de PlayerAvatar'a devredebiliriz 
              // ama şimdilik mevcut yapıyı koruyalım. (İstersen burayı da PlayerAvatar ile değiştirebiliriz)
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage: showImage ? NetworkImage(avatarUrl!) : null,
                child: !showImage ? firstLetterWidget() : null,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hoş geldin,',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
        ),
        if (activeTitleItem != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Text(
              '${activeTitleItem.imageUrl} ${activeTitleItem.name}',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.amber, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: 'Oda Oluştur',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () => context.push('/create-room'),
        ),
        const SizedBox(height: 16),
        _JoinRoomButton(
          onPressed: () => context.push('/join-room'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Mağaza',
                icon: Icons.storefront_rounded,
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(
                label: 'Desten',
                icon: Icons.style_rounded,
                onPressed: () => context.push('/custom-deck'),
              ),
            ),
          ],
        ),
        if (isAdmin(user?.uid)) ...[
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Admin Paneli',
            icon: Icons.admin_panel_settings_rounded,
            onPressed: () => context.push('/admin/dashboard'),
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
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Çıkış Yap'),
    );
  }
}

/// Odaya Katıl butonu — Outlined stil.
class _JoinRoomButton extends StatelessWidget {
  const _JoinRoomButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Odaya Katıl',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.accent.withValues(alpha: 0.2),
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Odaya Katıl',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
