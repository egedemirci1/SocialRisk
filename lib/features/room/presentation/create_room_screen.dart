import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Sahne Kurma Ekranı — Tiyatro Temalı
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int _maxPlayers = 4;
  bool _isScoreMode = true; // true = Puan Hedefi, false = Tur Sayısı
  double _scoreTarget = 500;
  double _roundTarget = 5;
  bool _isCreating = false;
  bool _isOpenMode = true;
  final GamePreset _preset = GamePreset.classic;
  GameMode _selectedMode = GameMode.classic;
  bool _useCustomDeck = false;

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final endType = _isScoreMode
          ? EndConditionType.score
          : EndConditionType.rounds;
      final endValue = _isScoreMode
          ? _scoreTarget.toInt()
          : _roundTarget.toInt();

      final userProfile = await ref
          .read(userRepositoryProvider)
          .getUserProfile(user.uid);
      final repo = ref.read(roomRepositoryProvider);

      final roomCode = await repo.createRoom(
        hostId: user.uid,
        hostName: user.displayName ?? 'Yönetmen',
        endConditionType: endType,
        endConditionValue: endValue,
        visibility: _isOpenMode ? RoomVisibility.open : RoomVisibility.closed,
        preset: _preset,
        hostAvatarUrl: userProfile?.avatarUrl,
        mode: _selectedMode,
        useCustomDeck: _useCustomDeck,
      );

      if (mounted && roomCode.isNotEmpty) {
        context.push('/lobby', extra: roomCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Yeni Sahne Kur',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSection(
                        title: 'Koltuk Sayısı',
                        icon: Icons.chair_rounded,
                        child: _buildPlayerSlider(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSection(
                        title: 'Gösteri Türü',
                        icon: Icons.theater_comedy_rounded,
                        child: _buildGameMode(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSection(
                        title: 'Perde Kapanışı',
                        icon: Icons.curtains_closed_rounded,
                        child: _buildEndCondition(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSection(
                        title: 'Sahne Durumu',
                        icon: Icons.visibility_rounded,
                        child: _buildVisibilityMode(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'İçerik Seçimi',
                icon: Icons.menu_book_rounded,
                child: _buildContentSelector(),
              ),
              const SizedBox(height: 32),
              StageButton(
                label: 'Perdeyi Aç',
                icon: Icons.play_arrow_rounded,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderColor: AppColors.accent,
                onPressed: _createRoom,
                isLoading: _isCreating,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPlayerSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_maxPlayers Aktör',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 8),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.black38,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _maxPlayers.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              onChanged: (value) => setState(() => _maxPlayers = value.toInt()),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2',
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '8',
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndCondition() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Puan',
                isSelected: _isScoreMode,
                onTap: () => setState(() => _isScoreMode = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Tur',
                isSelected: !_isScoreMode,
                onTap: () => setState(() => _isScoreMode = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isScoreMode) ...[
          Text(
            '${_scoreTarget.toInt()} Puan',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 8),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: Colors.black38,
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _scoreTarget,
                min: 50,
                max: 500,
                divisions: 9,
                onChanged: (value) => setState(() => _scoreTarget = value),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '50',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '500',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Text(
            '${_roundTarget.toInt()} Tur',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 8),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: Colors.black38,
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _roundTarget,
                min: 3,
                max: 20,
                divisions: 17,
                onChanged: (value) => setState(() => _roundTarget = value),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '3',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '20',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGameMode() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Klasik',
                isSelected: _selectedMode == GameMode.classic,
                onTap: () => setState(() => _selectedMode = GameMode.classic),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Eko',
                isSelected: _selectedMode == GameMode.economy,
                onTap: () => setState(() => _selectedMode = GameMode.economy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedMode == GameMode.classic
              ? 'Tüm aktörlerle klasik tiyatro deneyimi.'
              : 'Ekonomi ve kaynak yönetimi odaklı performans.',
          style: GoogleFonts.libreBaskerville(
            color: Colors.white54,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVisibilityMode() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Açık',
                isSelected: _isOpenMode,
                onTap: () => setState(() => _isOpenMode = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Gizli',
                isSelected: !_isOpenMode,
                onTap: () => setState(() => _isOpenMode = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _isOpenMode
              ? 'Sahne tüm izleyicilere (oyunculara) açık.'
              : 'Sadece davetli aktörler sahneye çıkabilir.',
          style: GoogleFonts.libreBaskerville(
            color: Colors.white54,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContentSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _ToggleChip(
            label: 'Klasik İçerik',
            isSelected: !_useCustomDeck,
            onTap: () => setState(() => _useCustomDeck = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleChip(
            label: 'Özel Senaryo',
            isSelected: _useCustomDeck,
            onTap: () => setState(() => _useCustomDeck = true),
          ),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.3)
                : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.playfairDisplay(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
