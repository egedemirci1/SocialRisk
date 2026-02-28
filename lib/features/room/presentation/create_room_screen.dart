import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/room_provider.dart';

/// Oda oluşturma ekranı — Oyuncu kapasitesi, bitiş koşulu ayarları.
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int _maxPlayers = 4;
  bool _isScoreMode = true; // true = Puan Hedefi, false = Tur Sayısı
  double _scoreTarget = 5000;
  double _roundTarget = 10;
  bool _isCreating = false;

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

      // Repository'yi async gap öncesi yakala — provider dispose olsa bile
      // repo referansı hâlâ geçerli kalır.
      final repo = ref.read(roomRepositoryProvider);
      final roomCode = await repo.createRoom(
        hostId: user.uid,
        hostName: user.displayName ?? 'Host',
        endConditionType: endType,
        endConditionValue: endValue,
        visibility: RoomVisibility.open, // Default as open (Faz 7 frontend part will make it selectable)
      );

      if (mounted && roomCode.isNotEmpty) {
        context.push('/lobby', extra: roomCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oda Oluştur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Oyuncu Kapasitesi
              _buildSection(
                title: 'Oyuncu Kapasitesi',
                icon: Icons.people_outline_rounded,
                child: _buildPlayerSlider(),
              ),

              const SizedBox(height: 24),

              // Bitiş Koşulu
              _buildSection(
                title: 'Bitiş Koşulu',
                icon: Icons.flag_outlined,
                child: _buildEndCondition(),
              ),

              const SizedBox(height: 24),

              // Oyun Modu (Şimdilik sabit Klasik)
              _buildSection(
                title: 'Oyun Modu',
                icon: Icons.casino_outlined,
                child: _buildGameMode(),
              ),

              const SizedBox(height: 40),

              // Oluştur Butonu
              PrimaryButton(
                label: 'Odayı Oluştur',
                icon: Icons.rocket_launch_rounded,
                onPressed: _createRoom,
                isLoading: _isCreating,
              ),

              const SizedBox(height: 32),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_maxPlayers',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'oyuncu',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceElevated,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _maxPlayers.toDouble(),
            min: 2,
            max: 8,
            divisions: 6,
            label: '$_maxPlayers',
            onChanged: (value) {
              setState(() => _maxPlayers = value.toInt());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('2', style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white38,
            )),
            Text('8', style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white38,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildEndCondition() {
    return Column(
      children: [
        // Mod seçimi
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Puan Hedefi',
                isSelected: _isScoreMode,
                onTap: () => setState(() => _isScoreMode = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleChip(
                label: 'Tur Sayısı',
                isSelected: !_isScoreMode,
                onTap: () => setState(() => _isScoreMode = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Değer slider
        if (_isScoreMode) ...[
          Text(
            '${_scoreTarget.toInt()} puan',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.accent,
            ),
          ),
          Slider(
            value: _scoreTarget,
            min: 1000,
            max: 10000,
            divisions: 18,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.surfaceElevated,
            onChanged: (value) {
              setState(() => _scoreTarget = value);
            },
          ),
        ] else ...[
          Text(
            '${_roundTarget.toInt()} tur',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.accent,
            ),
          ),
          Slider(
            value: _roundTarget,
            min: 3,
            max: 20,
            divisions: 17,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.surfaceElevated,
            onChanged: (value) {
              setState(() => _roundTarget = value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGameMode() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.casino_rounded, color: AppColors.accent, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Klasik Çark Modu',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Şans ve kaos — çarkı çevir!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  'AKTİF',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle chip for end condition selection.
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
