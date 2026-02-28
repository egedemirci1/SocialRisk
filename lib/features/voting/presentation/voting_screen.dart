import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/voting/voting_panel.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Oylama ekranı — Diğer oyuncular aktif oyuncuyu oylıyor.
class VotingScreen extends ConsumerWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock veri
    const performerName = 'Oyuncu 1';
    const taskContent = 'Telefondaki son aramanı herkese göster.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oylama'),
        automaticallyImplyLeading: false,
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),

            // Kimin oylandığı
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
              ),
              child: const SizedBox(
                width: 72,
                height: 72,
                child: Center(
                  child: Icon(Icons.person_rounded,
                      color: Colors.white54, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              performerName,
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'görevini tamamladı:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 12),

            // Görevi özetle
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '"$taskContent"',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(),

            // Oylama paneli
            VotingPanel(
              onVote: (value) {
                // TODO: ref.read(voteControllerProvider.notifier).castVote(...)
                debugPrint('Oy verildi: $value');
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
