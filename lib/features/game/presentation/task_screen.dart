import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/game_provider.dart';

/// Görev ekranı — Kategori, görev metni, Kabul/Pas butonları.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({
    super.key,
    required this.gameId,
    required this.roomCode,
  });

  final String gameId;
  final String roomCode;

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with SingleTickerProviderStateMixin {
  bool _isAccepting = false;
  bool _isPassing = false;

  late final AnimationController _cardController;
  late final Animation<double> _cardAnimation;

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
      await ref
          .read(gameControllerProvider.notifier)
          .acceptTask(widget.gameId);
      if (mounted) {
        context.push('/voting', extra: {
          'gameId': widget.gameId,
          'roomCode': widget.roomCode,
        });
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  Future<void> _passTask() async {
    setState(() => _isPassing = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      await ref.read(gameControllerProvider.notifier).passTask(
            gameId: widget.gameId,
            roomId: widget.roomCode,
            playerId: user.uid,
          );
      // Yeni görev animasyonunu sıfırla
      _cardController.reset();
      _cardController.forward();
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = game.currentTask;
        final user = ref.read(currentUserProvider);
        final isMyTurn = game.currentPlayerId == user?.uid;

        // Sıra sende değilse bekleme ekranına yönlendir
        if (!isMyTurn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.replace('/waiting', extra: {
                'gameId': widget.gameId,
                'roomCode': widget.roomCode,
              });
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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

                Text(
                  '🎯 Sıra Sende',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),

                ScaleTransition(
                  scale: _cardAnimation,
                  child: GameCard(
                    category: task?.category ?? '',
                    content: task?.content ?? '',
                    multiplier: task?.multiplier ?? 1,
                  ),
                ),

                const Spacer(),

                PrimaryButton(
                  label: 'Görevi Kabul Et',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _acceptTask,
                  isLoading: _isAccepting,
                ),
                const SizedBox(height: 12),
                DangerButton(
                  label: 'Pas Geç (Ceza: -${50 * (game.passStreak + 1)} puan)',
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
      },
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}
