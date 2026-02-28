import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Görev ekranı — Kategori, görev metni, Kabul/Pas butonları.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with SingleTickerProviderStateMixin {
  bool _isAccepting = false;
  bool _isPassing = false;

  late final AnimationController _cardController;
  late final Animation<double> _cardAnimation;

  // Mock veri — provider bağlandığında değişecek
  final _mockTask = const _MockTask(
    category: 'Cesaret',
    content: 'Telefondaki son aramanı herkese göster.',
    multiplier: 2,
  );

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _acceptTask() async {
    setState(() => _isAccepting = true);
    try {
      // TODO: ref.read(gameControllerProvider.notifier).acceptTask(gameId)
      debugPrint('Görev kabul edildi');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      // TODO: ref.read(gameControllerProvider.notifier).passTask(...)
      debugPrint('Görev pas geçildi');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senin Sıran!'),
        automaticallyImplyLeading: false,
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),

            // Aktif oyuncu bilgisi
            Text(
              '🎯 Sıra Sende',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),

            // Görev kartı (animasyonlu)
            ScaleTransition(
              scale: _cardAnimation,
              child: GameCard(
                category: _mockTask.category,
                content: _mockTask.content,
                multiplier: _mockTask.multiplier,
              ),
            ),

            const Spacer(),

            // Aksiyon butonları
            PrimaryButton(
              label: 'Görevi Kabul Et',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _acceptTask,
              isLoading: _isAccepting,
            ),
            const SizedBox(height: 12),
            DangerButton(
              label: 'Pas Geç (-50 puan)',
              icon: Icons.close_rounded,
              outlined: true,
              onPressed: _passTask,
              isLoading: _isPassing,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MockTask {
  const _MockTask({
    required this.category,
    required this.content,
    required this.multiplier,
  });
  final String category;
  final String content;
  final int multiplier;
}
