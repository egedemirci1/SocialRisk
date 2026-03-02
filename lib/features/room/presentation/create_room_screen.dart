import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/buttons/medieval_button.dart';
import '../../../shared/models/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';

/// Oda oluşturma ekranı — Orta Çağ Temalı
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int _maxPlayers = 4;
  bool _isScoreMode = true; // true = Puan Hedefi, false = Tur Sayısı
  double _scoreTarget = 500; // Yeni default
  double _roundTarget = 5; // Yeni default
  bool _isCreating = false;
  bool _isOpenMode = true;
  GamePreset _preset = GamePreset.classic; // Yeni alan
  GameMode _selectedMode = GameMode.classic;

  bool _useCustomDeck = false;

  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _cardColor = Color(0xFF1E140F); // Kart arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo / Koyu kırmızı
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Oda Oluştur',
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
          onPressed: () => Navigator.of(context).pop(),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

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

                  // Oyun Modu
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
                  MedievalButton(
                    label: 'Odayı Oluştur',
                    icon: Icons.rocket_launch_rounded,
                    backgroundColor: _accentCrimson,
                    textColor: _textLight,
                    borderColor: _accentGold.withOpacity(0.6),
                    onPressed: _createRoom,
                    isLoading: _isCreating,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
              style: GoogleFonts.cinzelDecorative(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _accentCrimson,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'oyuncu',
              style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _accentCrimson,
            inactiveTrackColor: Colors.black38,
            thumbColor: _accentCrimson,
            overlayColor: _accentCrimson.withOpacity(0.2),
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
            Text(
              '2',
              style: GoogleFonts.cinzel(color: Colors.white38, fontSize: 12),
            ),
            Text(
              '8',
              style: GoogleFonts.cinzel(color: Colors.white38, fontSize: 12),
            ),
          ],
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
        const SizedBox(height: 24),
        if (_isScoreMode) ...[
          Text(
            '${_scoreTarget.toInt()} puan',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _accentGold,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accentGold,
              inactiveTrackColor: Colors.black38,
              thumbColor: _accentGold,
              overlayColor: _accentGold.withOpacity(0.2),
            ),
            child: Slider(
              value: _scoreTarget,
              min: 50,
              max: 500,
              divisions: 9,
              onChanged: (value) => setState(() => _scoreTarget = value),
            ),
          ),
        ] else ...[
          Text(
            '${_roundTarget.toInt()} tur',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _accentGold,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accentGold,
              inactiveTrackColor: Colors.black38,
              thumbColor: _accentGold,
              overlayColor: _accentGold.withOpacity(0.2),
            ),
            child: Slider(
              value: _roundTarget,
              min: 3,
              max: 20,
              divisions: 17,
              onChanged: (value) => setState(() => _roundTarget = value),
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
                label: '🎡 Klasik',
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
          style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 13),
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
                label: '👁️ Açık',
                isSelected: _isOpenMode,
                onTap: () => setState(() => _isOpenMode = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleChip(
                label: '🔒 Kapalı',
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
          style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 13),
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
                label: 'Aile',
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
                label: 'Yetişkin',
                isSelected: _preset == GamePreset.adult,
                onTap: () => setState(() => _preset = GamePreset.adult),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _preset == GamePreset.classic
              ? 'Tüm kategoriler devrede, genel kitleye uygun.'
              : _preset == GamePreset.family
              ? 'Çocuklara ve ailelere uygun, risksiz görevler.'
              : _preset == GamePreset.couple
              ? 'Çiftlere özel, daha flörtöz ve itiraf dolu.'
              : 'Sınırların aşıldığı, her türlü 18+ içerikli görevler.',
          style: GoogleFonts.cinzel(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Destemi Kullan',
                isSelected: _useCustomDeck,
                onTap: () => setState(() => _useCustomDeck = !_useCustomDeck),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Profilinde oluşturduğun özel sorular oyuna dahil edilir (Zorluk ve kategori uyarsa).',
          style: GoogleFonts.cinzel(color: Colors.white38, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Medieval style toggle chip
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
    const activeBg = Color(0xFF5C1616); // Crimson
    const activeBorder = Color(0xFFD4AF37); // Gold
    const inactiveBg = Color(0xFF140D0B); // Koyu kahve/siyah
    const inactiveText = Colors.white54;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeBorder.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBorder.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              color: isSelected ? const Color(0xFFFDEFC2) : inactiveText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
