import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/danger_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';

/// Lobi ekranı — Oyuncu listesi, hazır/değil durumu, ve Başla butonu.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  // Mock veriler — Faz 4'te gerçek provider'larla değiştirilecek
  final String _roomCode = 'ABC123';
  final bool _isHost = true;
  bool _isReady = false;

  final List<_MockPlayer> _players = [
    _MockPlayer(name: 'Sen (Host)', isReady: true, isHost: true),
    _MockPlayer(name: 'Oyuncu 2', isReady: true, isHost: false),
    _MockPlayer(name: 'Oyuncu 3', isReady: false, isHost: false),
  ];

  bool get _allReady => _players.every((p) => p.isReady);

  void _toggleReady() {
    setState(() {
      _isReady = !_isReady;
      _players[0] = _MockPlayer(
        name: _players[0].name,
        isReady: _isReady,
        isHost: _players[0].isHost,
      );
    });
  }

  void _startGame() {
    // TODO: ref.read(gameProvider.notifier).startGame()
    debugPrint('Oyun başlatılıyor!');
  }

  void _leaveRoom() {
    // TODO: ref.read(roomProvider.notifier).leaveRoom()
    debugPrint('Odadan ayrılınıyor');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: _leaveRoom,
        ),
        actions: [
          // Oda kodu paylaşma
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Oda kodu kopyalandı: $_roomCode'),
                ),
              );
            },
          ),
        ],
      ),
      body: GradientContainer(
        child: Column(
          children: [
            // Oda kodu başlığı
            _buildRoomCodeBanner(),

            const SizedBox(height: 8),

            // Oyuncu sayısı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_players.length} / 8 oyuncu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                  const Spacer(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _allReady
                          ? AppColors.votePositive.withValues(alpha: 0.15)
                          : AppColors.passWarning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        _allReady ? 'Herkes hazır!' : 'Bekleniyor...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _allReady
                              ? AppColors.votePositive
                              : AppColors.passWarning,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Oyuncu listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  return _PlayerTile(player: _players[index]);
                },
              ),
            ),

            // Alt butonlar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isHost) ...[
                    PrimaryButton(
                      label: 'Oyunu Başlat',
                      icon: Icons.play_arrow_rounded,
                      onPressed: _allReady ? _startGame : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!_isHost) ...[
                    PrimaryButton(
                      label: _isReady ? 'Hazır ✓' : 'Hazırım!',
                      icon: _isReady
                          ? Icons.check_circle_rounded
                          : Icons.sports_esports_rounded,
                      onPressed: _toggleReady,
                    ),
                    const SizedBox(height: 12),
                  ],
                  DangerButton(
                    label: 'Odadan Ayrıl',
                    icon: Icons.exit_to_app_rounded,
                    outlined: true,
                    onPressed: _leaveRoom,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCodeBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.6),
              AppColors.surfaceElevated,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Oda Kodu: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white54,
                ),
              ),
              Text(
                _roomCode,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oyuncu listesi öğesi.
class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player});

  final _MockPlayer player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: player.isHost
              ? Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                ),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white38,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // İsim
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Oda Sahibi',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Hazır durumu
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: player.isReady
                      ? AppColors.votePositive.withValues(alpha: 0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  player.isReady ? 'Hazır' : 'Bekliyor',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: player.isReady
                        ? AppColors.votePositive
                        : Colors.white38,
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

/// Mock oyuncu verisi — Faz 4'te gerçek veriyle değiştirilecek.
class _MockPlayer {
  const _MockPlayer({
    required this.name,
    required this.isReady,
    required this.isHost,
  });

  final String name;
  final bool isReady;
  final bool isHost;
}
