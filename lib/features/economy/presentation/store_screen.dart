import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletPoints = 1500; // E22 sonrası UserEntity'den çekilecek

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza & Cüzdan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$walletPoints',
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GradientContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kozmetikler',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Placeholder Avatar Frames
              _SectionTitle('Çerçeveler'),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _StoreItemCard(
                      icon: Icons.local_fire_department_rounded,
                      name: 'Alev Çerçeve',
                      price: 2500,
                      color: AppColors.fire,
                      isOwned: false,
                    ),
                    _StoreItemCard(
                      icon: Icons.ac_unit_rounded,
                      name: 'Buz Kristalleri',
                      price: 1500,
                      color: AppColors.ice,
                      isOwned: true,
                    ),
                    _StoreItemCard(
                      icon: Icons.star_rounded,
                      name: 'Yıldız Tozu',
                      price: 5000,
                      color: AppColors.accent,
                      isOwned: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _SectionTitle('Rozetler & Ünvanlar'),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _StoreItemCard(
                      icon: Icons.emoji_events_rounded,
                      name: 'Şampiyon',
                      price: 10000,
                      color: Colors.amber,
                      isOwned: false,
                    ),
                    _StoreItemCard(
                      icon: Icons.cruelty_free_rounded,
                      name: 'Barışçıl',
                      price: 800,
                      color: Colors.pinkAccent,
                      isOwned: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.arrow_right_rounded, color: AppColors.primary),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  const _StoreItemCard({
    required this.icon,
    required this.name,
    required this.price,
    required this.color,
    required this.isOwned,
  });

  final IconData icon;
  final String name;
  final int price;
  final Color color;
  final bool isOwned;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned ? AppColors.votePositive.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (isOwned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.votePositive.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sahipsin',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.votePositive, fontSize: 10),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppColors.accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$price',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
