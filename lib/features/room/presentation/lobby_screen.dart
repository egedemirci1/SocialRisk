import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/report_dialog.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../shared/models/enums.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/utils/toast_utils.dart';

/// Fuaye (Lobi) Ekranı — Parti Temalı
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _isStartingGame = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(watchRoomProvider(widget.roomCode), (previous, next) {
      if (!mounted) return;
      final room = next.value;
      if (room == null) {
        // Oda silinmiş (Muhtemelen host çıktığı için)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ToastUtils.showError(context, 'Ev sahibi odadan ayrıldığı için oda kapatıldı.');
            context.go('/home');
          }
        });
        return;
      }

      final user = ref.read(currentUserProvider);
      final isHost = room.hostId == user?.uid;

      if (!isHost && room.status == GameStatus.playing) {
        final gameId = room.gameId;
        if (gameId != null && gameId.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(
                '/task',
                extra: {'gameId': gameId, 'roomCode': widget.roomCode},
              );
            }
          });
        }
      }
    });

    final user = ref.watch(currentUserProvider);
    final playersAsync = ref.watch(watchPlayersProvider(widget.roomCode));
    final roomAsync = ref.watch(watchRoomProvider(widget.roomCode));
    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);
    final cosmetics = cosmeticsAsync.value ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Lobi',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.accent,
          ),
          onPressed: () async {
            if (user != null) {
              await ref
                  .read(roomControllerProvider.notifier)
                  .leaveRoom(roomCode: widget.roomCode, playerId: user.uid);
            }
            if (context.mounted) context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildRoomCodeBanner(context),
                const SizedBox(height: 16),
                const _RotatingTooltips(),
                const SizedBox(height: 16),
                Expanded(
                  child: playersAsync.when(
                    data: (players) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isMe = player.id == user?.uid;
                          return _PlayerTile(
                            playerId: player.id,
                            name: player.name,
                            avatarUrl: player.avatarUrl,
                            isReady: player.isReady,
                            isCurrentPlayer: isMe,
                            cosmetics: cosmetics,
                            onLongPress: isMe
                                ? null
                                : () {
                                    ReportDialog.show(
                                      context,
                                      ref,
                                      targetUserId: player.id,
                                      targetUserName: player.name,
                                      targetUserAvatar: player.avatarUrl ?? '',
                                    );
                                  },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Hata: $e',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildActionSection(
                  context,
                  ref,
                  user,
                  roomAsync,
                  playersAsync,
                  onStartGame: () async {
                    setState(() => _isStartingGame = true);
                    try {
                      final room = roomAsync.value;
                      final players = playersAsync.value ?? [];
                      final playerIds = players.map((p) => p.id).toList();
                      final gameId = await ref.read(roomRepositoryProvider).startGameInRoom(
                        roomCode: widget.roomCode,
                        playerIds: playerIds,
                        mode: room?.mode ?? GameMode.classic,
                        categories: room?.categories ?? [],
                      );
                      
                      if (!context.mounted) return;
                      context.go('/task', extra: {'gameId': gameId, 'roomCode': widget.roomCode});
                    } catch (e) {
                      if (!context.mounted) return;
                      ToastUtils.showError(context, 'Hata: $e');
                    } finally {
                      if (mounted) setState(() => _isStartingGame = false);
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isStartingGame)
            const Positioned.fill(
              child: TheaterLoadingScreen(message: 'Oyun Hazırlanıyor...'),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ODA KODU',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.roomCode,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.roomCode));
                ToastUtils.showSuccess(context, 'Kod kopyalandı!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    WidgetRef ref,
    User? user,
    AsyncValue<dynamic> roomAsync,
    AsyncValue<List<dynamic>> playersAsync, {
    Future<void> Function()? onStartGame,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: roomAsync.when(
        data: (room) {
          final isHost = room?.hostId == user?.uid;
          final players = playersAsync.value ?? [];
          final allReady =
              players.isNotEmpty &&
              players.every((p) => p.id == room?.hostId || p.isReady);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isHost)
                _ReadyToggleButton(
                  roomCode: widget.roomCode,
                  playerId: user?.uid ?? '',
                ),
              if (isHost) ...[
                _AnimatedHostStartButton(
                  isReady: allReady && players.length >= 2,
                  onPressed: () async {
                    if (onStartGame != null) await onStartGame();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  (allReady && players.length >= 2)
                      ? 'Haydi, herkes seni bekliyor!'
                      : 'Diğer oyuncuların hazırlanmasını bekleyin...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: (allReady && players.length >= 2) ? AppColors.accent : Colors.white30,
                    fontSize: 12,
                    fontWeight: (allReady && players.length >= 2) ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _PlayerTile extends ConsumerWidget {
  const _PlayerTile({
    required this.playerId,
    required this.name,
    this.avatarUrl,
    required this.isReady,
    required this.isCurrentPlayer,
    this.cosmetics = const [],
    this.onLongPress,
  });

  final String playerId;
  final String name;
  final String? avatarUrl;
  final bool isReady;
  final bool isCurrentPlayer;
  final List<CosmeticItemEntity> cosmetics;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(watchUserProfileProvider(playerId));
    final profile = profileAsync.value;
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentPlayer
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPlayer ? AppColors.accent : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              PlayerAvatar(uid: playerId, displayName: name, radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name + (isCurrentPlayer ? ' (Sen)' : ''),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (activeTitleItem != null)
                    Text(
                      activeTitleItem.name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isReady
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isReady ? 'HAZIR' : 'BEKLİYOR',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isReady ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyToggleButton extends ConsumerWidget {
  const _ReadyToggleButton({required this.roomCode, required this.playerId});

  final String roomCode;
  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final me = (playersAsync.value ?? [])
        .where((p) => p.id == playerId)
        .firstOrNull;
    final isReady = me?.isReady ?? false;

    return StageButton(
      label: isReady ? 'HENÜZ HAZIR DEĞİLİM' : 'PARTİYE HAZIRIM!',
      icon: isReady ? Icons.close_rounded : Icons.check_circle_outline_rounded,
      backgroundColor: isReady ? Colors.black26 : AppColors.primary,
      textColor: isReady ? Colors.white54 : Colors.white,
      borderColor: isReady ? Colors.white12 : AppColors.accent,
      onPressed: () => ref
          .read(roomControllerProvider.notifier)
          .toggleReady(
            roomCode: roomCode,
            playerId: playerId,
            isReady: !isReady,
          ),
    );
  }
}

class _RotatingTooltips extends StatefulWidget {
  const _RotatingTooltips();

  @override
  State<_RotatingTooltips> createState() => _RotatingTooltipsState();
}

class _RotatingTooltipsState extends State<_RotatingTooltips> {
  int _currentIndex = 0;
  late final Timer _timer;
  final List<String> _tips = [
    '🎉 Parti başlasın! Hazır mısın?',
    '😎 Kimse mükemmel doğmaz, en iyi hamleni yap!',
    '🔥 Diğer oyuncuların oyları kaderini belirleyecek.',
    '👀 Cesur taklitler ve zor seçimler seni bekliyor.',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _tips.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Text(
        _tips[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.accent,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AnimatedHostStartButton extends StatefulWidget {
  final bool isReady;
  final VoidCallback onPressed;

  const _AnimatedHostStartButton({
    required this.isReady,
    required this.onPressed,
  });

  @override
  State<_AnimatedHostStartButton> createState() => _AnimatedHostStartButtonState();
}

class _AnimatedHostStartButtonState extends State<_AnimatedHostStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
      TweenSequenceItem(
          tween: ConstantTween(0.0), weight: 10), // pause between shakes
    ]).animate(_controller);

    if (widget.isReady) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedHostStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) {
      _controller.repeat();
    } else if (!widget.isReady && oldWidget.isReady) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isReady) {
      return StageButton(
        label: 'OYUNU BAŞLAT',
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.surface,
        textColor: Colors.white30,
        borderColor: Colors.white10,
        onPressed: () {},
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                )
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          ),
        );
      },
      child: StageButton(
        label: 'OYUNU BAŞLAT',
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        borderColor: AppColors.accent,
        onPressed: widget.onPressed,
      ),
    );
  }
}
