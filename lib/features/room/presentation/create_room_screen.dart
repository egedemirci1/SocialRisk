import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
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
  double _scoreTarget = 500; // Yeni default
  double _roundTarget = 5;   // Yeni default
  bool _isCreating = false;
  bool _isOpenMode = true;
  GamePreset _preset = GamePreset.classic; // Yeni alan
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

      // Custom profili al ki avatarUrl'yi okuyabilelim
      final userProfile = await ref.read(userRepositoryProvider).getUserProfile(user.uid);

      // Repository'yi async gap öncesi yakala — provider dispose olsa bile
      // repo referansı hâlâ geçerli kalır.
      final repo = ref.read(roomRepositoryProvider);
      final roomCode = await repo.createRoom(
        hostId: user.uid,
        hostName: user.displayName ?? 'Host',
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

              const SizedBox(height: 24),

              // Görünürlük Modu
              _buildSection(
                title: 'Görünürlük Modu',
                icon: Icons.visibility_outlined,
                child: _buildVisibilityMode(),
              ),

              const SizedBox(height: 24),
              
              // İçerik Modu (Preset)
              _buildSection(
                title: 'İçerik Modu',
                icon: Icons.auto_awesome_mosaic_rounded,
                child: _buildPresetMode(),
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
            min: 50,
            max: 500,
            divisions: 9, // Adımlar: 50, 100, 150... 500
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: '🎡 Klasik Çark',
                isSelected: _selectedMode == GameMode.classic,
                onTap: () => setState(() => _selectedMode = GameMode.classic),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleChip(
                label: '🏦 Ekonomi',
                isSelected: _selectedMode == GameMode.economy,
                onTap: () => setState(() => _selectedMode = GameMode.economy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _selectedMode == GameMode.classic
              ? 'Şans ve kaos — çarkı çevir, hangi kategori gelirse o!'
              : 'Strateji — puan lideri önce seçer, pazar daralır!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
            fontSize: 12,
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
                label: '👁️ Açık Mod',
                isSelected: _isOpenMode,
                onTap: () => setState(() => _isOpenMode = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleChip(
                label: '🔒 Kapalı Mod',
                isSelected: !_isOpenMode,
                onTap: () => setState(() => _isOpenMode = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _isOpenMode
              ? 'Herkes görev içeriğini önceden görebilir.'
              : 'Sadece kategori ve çarpan görünür. İçerik gizli!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPresetMode() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Klasik',
                isSelected: _preset == GamePreset.classic,
                onTap: () => setState(() => _preset = GamePreset.classic),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Aile (PG)',
                isSelected: _preset == GamePreset.family,
                onTap: () => setState(() => _preset = GamePreset.family),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Sevgili',
                isSelected: _preset == GamePreset.couple,
                onTap: () => setState(() => _preset = GamePreset.couple),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Yetişkin (18+)',
                isSelected: _preset == GamePreset.adult,
                onTap: () => setState(() => _preset = GamePreset.adult),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _preset == GamePreset.classic ? 'Tüm kategoriler devrede, genel kitleye uygun.' 
          : _preset == GamePreset.family ? 'Çocuklara ve ailelere uygun, risksiz görevler.'
          : _preset == GamePreset.couple ? 'Çiftlere özel, daha flörtöz ve itiraf dolu.'
          : 'Sınırların aşıldığı, her türlü 18+ içerikli görevler.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white38,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Kendi destemi kullan toggle
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Kendi Destemi Kullan',
                isSelected: _useCustomDeck,
                onTap: () => setState(() => _useCustomDeck = !_useCustomDeck),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Profilinde oluşturduğun özel sorular oyuna dahil edilir (Zorluk ve kategori uyarsa).',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white38,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
