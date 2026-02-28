import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Bekleme ekranı — Diğer oyuncuların oylama/görev tamamlamasını bekle.
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock veri
    const activePlayerName = 'Oyuncu 2';

    return Scaffold(
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Pulse animasyonlu ikon
            ScaleTransition(
              scale: _pulseAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
                child: const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.accent,
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Bekleniyor...',
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$activePlayerName görevini yapıyor',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Küçük bilgi kartı
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.white38, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Görev bitince oylama başlayacak',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
