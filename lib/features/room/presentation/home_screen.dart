import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';

/// Ana menü ekranı — Oda Oluştur veya Odaya Katıl.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.displayName ?? 'Oyuncu';

    return Scaffold(
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildWelcome(displayName),
            const Spacer(),
            _buildActions(context),
            const Spacer(flex: 2),
            _buildFooter(context, ref),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(String playerName) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white54,
                size: 40,
              ),
            ),
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
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.accent.withValues(alpha: 0.1),
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Odaya Katıl',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accent,
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
