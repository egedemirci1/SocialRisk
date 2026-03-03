import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../../shared/widgets/common/report_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../game/providers/game_provider.dart';
import '../../../shared/models/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../economy/providers/economy_provider.dart';
import '../../economy/domain/cosmetic_item_entity.dart';

/// Lobi ekranı — Oyuncu listesi, hazır/değil durumu, ve Başla butonu (Orta Çağ Temalı).
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  @override
  Widget build(BuildContext context) {
    // Navigate non-hosts automatically when game starts using listen
    ref.listen(watchRoomProvider(widget.roomCode), (previous, next) {
      if (!mounted) return;

      final room = next.value;
      if (room == null) return;

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Lobi',
          style: GoogleFonts.cinzelDecorative(
            fontWeight: FontWeight.w700,
            color: _textLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _accentGold),
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
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka Plan Resmi
          Image.asset(
            'assets/Loading-Screen-Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          // Karartma (Overlay)
          Container(color: _bgColor.withOpacity(0.85)),

          SafeArea(
            child: Column(
              children: [
                // Oda kodu banner
                _buildRoomCodeBanner(context),

                const SizedBox(height: 16),
                const _RotatingTooltips(),
                const SizedBox(height: 8),

                // Oyuncu listesi
                Expanded(
                  child: playersAsync.when(
                    data: (players) => ListView.builder(
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
                          score: player.score,
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
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _accentGold),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Hata: $e',
                        style: GoogleFonts.cinzel(color: _accentCrimson),
                      ),
                    ),
                  ),
                ),

                // Alt butonlar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: roomAsync.when(
                    data: (room) {
                      final isHost = room?.hostId == user?.uid;
                      final players = playersAsync.value ?? [];
                      final allReady =
                          players.isNotEmpty &&
                          players.every(
                            (p) => p.id == room?.hostId || p.isReady,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isHost) ...[
                            // Hazır butonu — host değil
                            _ReadyToggleButton(
                              roomCode: widget.roomCode,
                              playerId: user?.uid ?? '',
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (isHost) ...[
                            // Başla butonu — sadece host
                            MedievalButton(
                              label: 'Oyunu Başlat',
                              icon: Icons.play_arrow_rounded,
                              backgroundColor: (allReady && players.length >= 2)
                                  ? _accentCrimson
                                  : _cardColor,
                              textColor: (allReady && players.length >= 2)
                                  ? _textLight
                                  : Colors.white38,
                              borderColor: (allReady && players.length >= 2)
                                  ? _accentGold.withOpacity(0.6)
                                  : Colors.transparent,
                              onPressed: (allReady && players.length >= 2)
                                  ? () async {
                                      try {
                                        final playerIds = players
                                            .map((p) => p.id)
                                            .toList();

                                        // Repository'leri async gap öncesi yakala
                                        final roomRepo = ref.read(
                                          roomRepositoryProvider,
                                        );
                                        final gameRepo = ref.read(
                                          gameRepositoryProvider,
                                        );

                                        await roomRepo.updateRoomStatus(
                                          roomCode: widget.roomCode,
                                          status: GameStatus.playing,
                                        );
                                        final gameId = await gameRepo.startGame(
                                          roomId: widget.roomCode,
                                          playerIds: playerIds,
                                          mode: room?.mode ?? GameMode.classic,
                                        );

                                        // gameId'yi room belgesine yaz
                                        await FirebaseFirestore.instance
                                            .collection('rooms')
                                            .doc(widget.roomCode)
                                            .update({'gameId': gameId});

                                        if (context.mounted) {
                                          context.go(
                                            '/task',
                                            extra: {
                                              'gameId': gameId,
                                              'roomCode': widget.roomCode,
                                            },
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Hata: ${e.toString()}',
                                                style: GoogleFonts.cinzel(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: _accentCrimson,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : () {}, // Boş fonksiyon disabled durumu MedievalButton'da handle edilir
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allReady
                                  ? 'Tüm oyuncular hazır!'
                                  : 'Herkesin hazır olmasını bekle...',
                              style: GoogleFonts.cinzel(
                                color: allReady
                                    ? Colors.green.shade400
                                    : Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _accentGold),
                    ),
                    error: (e, _) => Text(
                      'Hata: $e',
                      style: GoogleFonts.cinzel(color: _accentCrimson),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentGold.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oda Kodu',
                    style: GoogleFonts.cinzel(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.roomCode,
                    style: GoogleFonts.cinzel(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _accentCrimson,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: _textLight),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kod kopyalandı!',
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blueGrey.shade800,
                    ),
                  );
                },
                tooltip: 'Kopyala',
              ),
            ],
          ),
        ),
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
    this.score = 0,
    this.cosmetics = const [],
    this.onLongPress,
  });

  final String playerId;
  final String name;
  final String? avatarUrl;
  final bool isReady;
  final bool isCurrentPlayer;
  final int score;
  final List<CosmeticItemEntity> cosmetics;
  final VoidCallback? onLongPress;

  // Tematik Renkler
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Oyuncunun canlı profilini izle — çerçeve ve ünvan her zaman güncel
    final profileAsync = ref.watch(watchUserProfileProvider(playerId));
    final profile = profileAsync.value;

    final liveFrame = profile?.activeFrame;
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCurrentPlayer
                ? _accentGold.withOpacity(0.15)
                : _cardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentPlayer
                  ? _accentGold.withOpacity(0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isCurrentPlayer
                ? [
                    BoxShadow(
                      color: _accentGold.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                PlayerAvatar(
                  displayName: name,
                  avatarUrl: avatarUrl,
                  score: score,
                  radius: 20,
                  frameId: liveFrame,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name + (isCurrentPlayer ? ' (Sen)' : ''),
                      style: GoogleFonts.cinzel(
                        color: isCurrentPlayer ? _textLight : Colors.white,
                        fontWeight: isCurrentPlayer
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (activeTitleItem != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _accentGold.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '${activeTitleItem.imageUrl} ${activeTitleItem.name}',
                            style: GoogleFonts.cinzel(
                              color: _accentGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Icon(
                  isReady
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isReady ? Colors.green.shade400 : Colors.white38,
                ),
              ],
            ),
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
    // Tematik Renkler
    const accentGold = Color(0xFFD4AF37); // Altın
    const accentCrimson = Color(0xFF5C1616); // Bordo
    const textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık

    final playersAsync = ref.watch(watchPlayersProvider(roomCode));
    final players = playersAsync.value ?? [];
    final me = players.cast<dynamic>().firstWhere(
      (p) => p.id == playerId,
      orElse: () => null,
    );
    final isReady = me?.isReady ?? false;

    return isReady
        ? MedievalButton(
            label: 'Hazır Değilim',
            icon: Icons.close_rounded,
            backgroundColor: Colors.black.withOpacity(0.6),
            textColor: Colors.white70,
            borderColor: Colors.redAccent.withOpacity(0.4),
            onPressed: () => ref
                .read(roomControllerProvider.notifier)
                .toggleReady(
                  roomCode: roomCode,
                  playerId: playerId,
                  isReady: false,
                ),
          )
        : MedievalButton(
            label: 'Hazırım!',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: accentCrimson,
            textColor: textLight,
            borderColor: accentGold.withOpacity(0.8),
            onPressed: () => ref
                .read(roomControllerProvider.notifier)
                .toggleReady(
                  roomCode: roomCode,
                  playerId: playerId,
                  isReady: true,
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
  final List<String> _tips = [
    '💡 İpucu: Pas geçmek sırayı bitirir ve puanını düşürür!',
    '💡 İpucu: Oylamada dürüst ol, arkadaşının kaderi sende.',
    '💡 İpucu: Çok fazla pas dersen eksi puanlara düşersin.',
    '💡 İpucu: Soru türüne göre puan kazancı değişir.',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _currentIndex = (_currentIndex + 1) % _tips.length);
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          _tips[_currentIndex],
          key: ValueKey<int>(_currentIndex),
          style: GoogleFonts.cinzel(
            color: Colors.redAccent.shade100,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
