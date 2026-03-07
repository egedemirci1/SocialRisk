import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';

/// Oda Kurma Ekranı — Parti Temalı
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  bool _isScoreMode = true; // true = Puan Hedefi, false = Tur Sayısı
  double _scoreTarget = 500;
  double _roundTarget = 5;
  bool _isCreating = false;
  final List<String> _selectedCategories = GameConstants.defaultCategoriesConst.toList();
  GameMode _selectedMode = GameMode.classic;

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
        visibility: RoomVisibility.open,
        categories: _selectedCategories,
        hostAvatarUrl: userProfile?.avatarUrl,
        mode: _selectedMode,
        useCustomDeck: _selectedCategories.contains('Özel'),
      );

      if (mounted && roomCode.isNotEmpty) {
        context.push('/lobby', extra: roomCode);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Hata: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isCreating,
      message: 'Parti kuruluyor...',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedMeshBackground(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ResponsiveWrapper(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF130D26).withValues(alpha: 0.85), // Very dark plum/indigo
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Yeni Parti Kur',
                          style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            shadows: const [
                              Shadow(offset: Offset(0, 4), color: Colors.black26, blurRadius: 4),
                            ],),
                        ),
                        const SizedBox(height: 24),
                        _buildSection(
                          title: 'Oyun Sonu',
                          icon: Icons.flag_rounded,
                          child: _buildEndCondition(),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'Oyun Modu',
                          icon: Icons.celebration_rounded,
                          child: _buildGameMode(),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'Kategoriler',
                          icon: Icons.category_rounded,
                          child: _buildCategorySelector(),
                        ),
                        const SizedBox(height: 32),
                        StageButton(
                          label: 'Partiyi Başlat',
                          icon: Icons.play_arrow_rounded,
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.background,
                          borderColor: Colors.transparent,
                          onPressed: _createRoom,
                          isLoading: _isCreating,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
     ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool fillHeight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],),
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

  Widget _buildEndCondition() {
    // Dinamik renk hesaplama: Düşük değerler Mavi/Yeşil, yüksek değerler Turuncu/Kırmızı
    final scoreRatio = ((_scoreTarget - 50) / 450).clamp(0.0, 1.0);
    final scoreColor = Color.lerp(const Color(0xFF00E5FF), const Color(0xFFFF3D00), scoreRatio) ?? AppColors.accent;

    final roundRatio = ((_roundTarget - 3) / 17).clamp(0.0, 1.0);
    final roundColor = Color.lerp(const Color(0xFF00E5FF), const Color(0xFFFF3D00), roundRatio) ?? AppColors.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.titleLarge.copyWith(fontSize: 16 + (14 * scoreRatio), // Goes from 16 to 30!
              fontWeight: FontWeight.w900, 
              color: scoreColor,
              shadows: [
                Shadow(color: scoreColor.withValues(alpha: 0.5), blurRadius: 10 * scoreRatio),
              ],),
            child: Text('${_scoreTarget.toInt()} Puan'),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scoreColor,
              inactiveTrackColor: Colors.black38,
              thumbColor: scoreColor,
              overlayColor: scoreColor.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _scoreTarget,
              min: 50,
              max: 500,
              divisions: 9,
              onChanged: (value) {
                if (value != _scoreTarget) {
                  HapticFeedback.selectionClick();
                  setState(() => _scoreTarget = value);
                }
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('50', style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
                  Text('500', style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
                ],
              ),
            ),
          ),
        ] else ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.titleLarge.copyWith(fontSize: 16 + (14 * roundRatio), // Goes from 16 to 30!
              fontWeight: FontWeight.w900, 
              color: roundColor,
              shadows: [
                Shadow(color: roundColor.withValues(alpha: 0.5), blurRadius: 10 * roundRatio),
              ],),
            child: Text('${_roundTarget.toInt()} Tur'),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: roundColor,
              inactiveTrackColor: Colors.black38,
              thumbColor: roundColor,
              overlayColor: roundColor.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _roundTarget,
              min: 3,
              max: 20,
              divisions: 17,
              onChanged: (value) {
                if (value != _roundTarget) {
                  HapticFeedback.selectionClick();
                  setState(() => _roundTarget = value);
                }
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('3', style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
                  Text('20', style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
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
                label: 'Çark',
                isSelected: _selectedMode == GameMode.classic,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedMode = GameMode.classic);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleChip(
                label: 'Ekonomi',
                isSelected: _selectedMode == GameMode.economy,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedMode = GameMode.economy);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Premium Tooltip Information Box
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(_selectedMode),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _selectedMode == GameMode.classic ? Icons.info_outline_rounded : Icons.monetization_on_outlined,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMode == GameMode.classic ? 'Klasik Parti' : 'Patron Parti',
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedMode == GameMode.classic
                            ? 'Şans çarkını çevir ve rastgele kategoriden gelen riskli cezalarla yüzleş. Puan toplamak için tek şansın cesaret!'
                            : 'Görevleri tamamlayarak coin kazan; bu coinlerle başkalarına ceza kitle, risklerden kurtul. Kim daha acımasızsa o kazanır.',
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: 1.4,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = CategoryConstants.allCategoryNames;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const runSpacing = 8.0;
        const minChipWidth = 92.0;
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
        final crossCount = (maxW / (minChipWidth + spacing)).floor().clamp(2, 10);
        final itemWidth = (maxW - (crossCount - 1) * spacing) / crossCount;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: categories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedCategories.length > 2) {
                        _selectedCategories.remove(category);
                      } else {
                        ToastUtils.showWarning(context, 'En az 2 kategori seçmelisiniz.');
                      }
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.3)
                          : Colors.white10,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Border
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white10,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.transparent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,),
              ),
            ),
          ),
          // Animated Background
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // Animated Text Colors
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: AppTextStyles.labelSmall.copyWith(color: isSelected ? AppColors.background : Colors.white54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,),
            child: Center(child: Text(label)),
          ),
        ],
      ),
    );
  }
}
