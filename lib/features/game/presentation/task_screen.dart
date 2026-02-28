import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/cards/game_card.dart';
import '../../../shared/widgets/game/spin_wheel.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/game_provider.dart';
import '../../../shared/models/enums.dart';

/// Görev ekranı — Çark → Kategori → Görev → Kabul/Pas.
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
  bool _wheelDone = false;
  bool _contentRevealed = false;
  String? _selectedCategory;

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
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _onWheelResult(String category) {
    setState(() {
      _selectedCategory = category;
      _wheelDone = true;
      _contentRevealed = false;
    });
    _cardController.forward();
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
      // Çarkı sıfırla — yeni görev için tekrar çevirmeli
      setState(() {
        _wheelDone = false;
        _selectedCategory = null;
        _contentRevealed = false;
      });
      _cardController.reset();
    } finally {
      if (mounted) setState(() => _isPassing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(watchGameProvider(widget.gameId));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));

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

        // Sıra sende değilse durumuna göre ilgili ekrana yönlendir
        if (!isMyTurn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (game.status == GameStatus.voting) {
                context.replace('/voting', extra: {
                  'gameId': widget.gameId,
                  'roomCode': widget.roomCode,
                });
              } else {
                context.replace('/waiting', extra: {
                  'gameId': widget.gameId,
                  'roomCode': widget.roomCode,
                });
              }
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
            child: _wheelDone
                ? _buildTaskView(
                    game.passStreak,
                    task,
                    roomAsync.value?.visibility ?? RoomVisibility.open,
                  )
                : _buildWheelView(),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }

  /// Çark görünümü — henüz kategori seçilmedi
  Widget _buildWheelView() {
    return Column(
      children: [
        const Spacer(),
        Text(
          '🎡 Çarkı Çevir!',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kategorin şansa bağlı!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 24),
        SpinWheel(onResult: _onWheelResult),
        const Spacer(),
      ],
    );
  }

  /// Görev görünümü — çark döndü, görev gösterildi
  Widget _buildTaskView(int passStreak, dynamic task, RoomVisibility visibility) {
    final isClosed = visibility == RoomVisibility.closed && !_contentRevealed;
    return Column(
      children: [
        const Spacer(),

        // Seçilen kategori badge
        if (_selectedCategory != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '🎡 $_selectedCategory',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        Text(
          isClosed ? '🔒 Kapalı Mod' : '🎯 Görevin:',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isClosed ? Colors.white54 : AppColors.accent,
          ),
        ),
        const SizedBox(height: 24),

        ScaleTransition(
          scale: _cardAnimation,
          child: GameCard(
            category: task?.category ?? _selectedCategory ?? '',
            content: isClosed
                ? '❓ İçeriği görmek için aç'
                : (task?.content ?? ''),
            multiplier: task?.multiplier ?? 1,
          ),
        ),

        const Spacer(),

        if (isClosed) ...[
          // Kapalı modda — önce içeriği aç
          PrimaryButton(
            label: 'Görevi Aç 🔓',
            icon: Icons.lock_open_rounded,
            onPressed: () => setState(() => _contentRevealed = true),
          ),
        ] else ...[
          // Açık mod veya içerik açıldıktan sonra
          PrimaryButton(
            label: 'Görevi Kabul Et',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _acceptTask,
            isLoading: _isAccepting,
          ),
          const SizedBox(height: 12),
          DangerButton(
            label: 'Pas Geç (Ceza: -${50 * (passStreak + 1)} puan)',
            icon: Icons.close_rounded,
            outlined: true,
            onPressed: _passTask,
            isLoading: _isPassing,
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

