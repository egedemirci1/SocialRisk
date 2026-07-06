import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import '../../../shared/widgets/common/loading_overlay.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/room_provider.dart';
import '../../../core/providers/lifecycle_provider.dart';

part 'create_room_screen.builders.part.dart';
part 'create_room_screen.widgets.part.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  bool _isScoreMode = false;
  double _scoreTarget = GameConstants.defaultTargetScore.toDouble();
  double _roundTarget = GameConstants.defaultMaxRounds.toDouble();
  bool _isCreating = false;
  final List<String> _selectedCategories =
      GameConstants.defaultCategoriesConst.toList();
  GameMode _selectedMode = GameMode.classic;

  @override
  void initState() {
    super.initState();
  }

  void _setScoreMode(bool isScoreMode) {
    setState(() => _isScoreMode = isScoreMode);
  }

  void _setScoreTarget(double value) {
    setState(() => _scoreTarget = value);
  }

  void _setRoundTarget(double value) {
    setState(() => _roundTarget = value);
  }

  void _selectClassicMode() {
    setState(() => _selectedMode = GameMode.classic);
  }

  void _selectEconomyMode(bool isPremium) {
    setState(() {
      _selectedMode = GameMode.economy;
      if (_selectedCategories.length < 3) {
        final allCats = CategoryConstants.all;
        for (final cat in allCats) {
          if (_selectedCategories.length >= 3) break;
          if (cat.id == CategoryConstants.customCategoryId && !isPremium) continue;
          if (!_selectedCategories.contains(cat.id)) {
            _selectedCategories.add(cat.id);
          }
        }
      }
    });
  }

  void _onCategoryTap(String categoryId, bool isPremium, bool isSelected) {
    if (categoryId == CategoryConstants.customCategoryId && !isPremium) {
      HapticFeedback.heavyImpact();
      ToastUtils.showInfo(
        context,
        AppLocalizations.of(context)!.premiumCategoryLocked,
      );
      return;
    }
    setState(() {
      if (isSelected) {
        if (_selectedCategories.length > 1) {
          _selectedCategories.remove(categoryId);
        } else {
          ToastUtils.showWarning(
            context,
            AppLocalizations.of(context)!.minOneCategoryWarn,
          );
        }
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  Future<void> _createRoom() async {
    final l = AppLocalizations.of(context)!;
    // Borsa modu i├ğin 3 kategori zorunlulu─şu
    if (_selectedMode == GameMode.economy && _selectedCategories.length < 3) {
      ToastUtils.showWarning(
        context, 
        l.minThreeCategoriesEconomy,
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final endType =
          _isScoreMode ? EndConditionType.score : EndConditionType.rounds;
      final endValue =
          _isScoreMode ? _scoreTarget.toInt() : _roundTarget.toInt();

      final userProfile =
          await ref.read(userRepositoryProvider).getUserProfile(user.uid);
      if (!mounted) return;

      final repo = ref.read(roomRepositoryProvider);
      final effectiveMode = _selectedMode;
      final hostName = user.displayName ?? l.hostDefaultName;

      final roomCode = await repo.createRoom(
        hostId: user.uid,
        hostName: hostName,
        endConditionType: endType,
        endConditionValue: endValue,
        visibility: RoomVisibility.open,
        categories: _selectedCategories,
        hostAvatarUrl: userProfile?.avatarUrl,
        mode: effectiveMode,
        useCustomDeck: _selectedCategories.contains(CategoryConstants.customCategoryId),
      );

      if (!mounted) return;
      if (roomCode.isNotEmpty) {
        ref.read(currentRoomTrackerProvider.notifier).updateRoom(roomCode);
        context.push('/lobby', extra: roomCode);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _CreateRoomMetrics.from(context);
    final user = ref.watch(currentUserProvider);
    final userProfile = user != null
        ? ref.watch(watchUserProfileProvider(user.uid)).value
        : null;
    final isPremium = userProfile?.isPremium ?? false;

    Widget buildContent(double availableWidth) {
      return SizedBox(
        width: availableWidth,
        child: Container(
          padding: EdgeInsets.all(metrics.cardPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF130D26).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(metrics.cardRadius),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: metrics.isCompactHeight ? 28 : 40,
                offset: Offset(0, metrics.isCompactHeight ? 14 : 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.newPartyHostTitle,
                style: AppTextStyles.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: metrics.titleFontSize,
                  color: Colors.white,
                  letterSpacing: 1.0,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 4),
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: metrics.sectionGapLarge),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.endConditionLabel,
                icon: Icons.flag_rounded,
                child: _buildEndCondition(metrics),
              ),
              SizedBox(height: metrics.sectionGap),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.gameModeLabel,
                icon: Icons.celebration_rounded,
                child: _buildGameMode(metrics, isPremium),
              ),
              SizedBox(height: metrics.sectionGap),
              _buildSection(
                metrics: metrics,
                title: AppLocalizations.of(context)!.categoriesLabel,
                icon: Icons.category_rounded,
                child: _buildCategorySelector(metrics, isPremium),
              ),
              SizedBox(height: metrics.actionTopSpacing),
              SizedBox(
                width: double.infinity,
                child: StageButton(
                    label: AppLocalizations.of(context)!.startPartyButton,
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.background,
                  borderColor: Colors.transparent,
                  onPressed: _createRoom,
                  isLoading: _isCreating,
                  compact: metrics.isCompactWidth || metrics.isCompactHeight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isCreating,
      message: AppLocalizations.of(context)!.roomCreating,
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
            const Positioned.fill(child: AnimatedMeshBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalInset = metrics.outerHorizontalPadding * 2;
                  final availableWidth = math.max(
                    280.0,
                    math.min(
                      metrics.contentMaxWidth,
                      constraints.maxWidth - horizontalInset,
                    ),
                  );

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        metrics.outerHorizontalPadding,
                        metrics.outerVerticalPadding,
                        metrics.outerHorizontalPadding,
                        metrics.outerVerticalPadding + metrics.safeBottomSpacing,
                      ),
                      child: buildContent(availableWidth),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}