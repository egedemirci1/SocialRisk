import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/pending_toast.dart';
import '../../../shared/widgets/common/social_risk_logo.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import '../../../core/providers/lifecycle_provider.dart';
import '../../../core/utils/game_route_resolver.dart';
import '../../game/domain/game_entity.dart';
import '../../game/providers/game_provider.dart';
import '../domain/room_entity.dart';
import '../providers/room_provider.dart';
import '../../../shared/models/enums.dart';

part 'home_screen.builders.part.dart';

/// Ana menü ekranı — Parti Temalı
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = PendingToast.instance.consume();
      if (pending != null) {
        final (msg, isSuccess) = pending;
        if (isSuccess) {
          ToastUtils.showSuccess(context, msg);
        } else {
          ToastUtils.showError(context, msg);
        }
      }
    });
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l.menu,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.settings_rounded, color: AppColors.accent),
                  title: Text(
                    l.settingsTitle, // Changed from 'Ayarlar'
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    l.settingsSubtitle, // Changed from 'Ses ve Dil'
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_rounded, color: AppColors.accent),
                  title: Text(
                    l.store, // Changed from 'Mağaza'
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    l.storeSubtitle, // Changed from 'Kozmetikler ve içerikler'
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/store');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded, color: AppColors.accent),
                  title: Text(
                    l.myContent, // Changed from 'İçeriklerim'
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    l.myContentSubtitle, // Changed from 'Kendi içeriklerini yönet'
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/custom-deck');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: Text(
                    l.logOut, // Changed from 'Çıkış Yap'
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout(context, ref);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    l.copyright, // Changed from '2026 Tüm Hakları Saklıdır'
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null
        ? ref.watch(watchUserProfileProvider(user.uid))
        : const AsyncValue<UserEntity?>.loading();

    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    final profile = userProfileAsync.value;
    final displayName = profile?.displayName ?? user?.displayName ?? l.player; // Changed from 'Oyuncu'
    final cosmetics = cosmeticsAsync.value ?? [];

    final hasLoadError = userProfileAsync.hasError || cosmeticsAsync.hasError;

    // Ana menü hazır olana kadar yükleme ekranında kal:
    // - Auth çözülmemişse (user null) veya
    // - Profil / kozmetikler hâlâ yükleniyorsa
    final isInitialLoading = user == null ||
        userProfileAsync.isLoading ||
        cosmeticsAsync.isLoading;

    // İlerleme: auth → profil → kozmetik (Firestore gerçek % vermiyor, aşamalara göre simüle)
    double loadingProgress = 0.0;
    if (user != null) {
      loadingProgress = 0.33;
      if (userProfileAsync.hasValue) loadingProgress = 0.66;
      if (cosmeticsAsync.hasValue) loadingProgress = 1.0;
    }

    if (hasLoadError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: AsyncErrorView(
            message: l.loadFailed,
            onRetry: () {
              if (user != null) {
                ref.invalidate(watchUserProfileProvider(user.uid));
              }
              ref.invalidate(fetchCosmeticsProvider);
            },
          ),
        ),
      );
    }

    if (isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(
          message: l.homeScreenLoading, // Changed from 'Ana menü hazırlanıyor...'
          progress: loadingProgress,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan ışıklandırması (Yeni Party konsepti)
          const Positioned.fill(
            child: AnimatedMeshBackground(),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Builder(
                              builder: (ctx) {
                                final sh = MediaQuery.sizeOf(ctx).height;
                                return SizedBox(height: sh < 700 ? 16 : 28);
                              },
                            ),
                            const SocialRiskLogo(height: 100),
                            Builder(
                              builder: (ctx) {
                                final sh = MediaQuery.sizeOf(ctx).height;
                                return SizedBox(height: sh < 700 ? 24 : 32);
                              },
                            ),
                            const Spacer(flex: 2),
                            _buildWelcome(
                              context,
                              displayName,
                              profile,
                              cosmetics,
                              user.uid,
                            ),
                            const SizedBox(height: 32),
                            _buildActivePartySection(context, ref, user) ??
                                const SizedBox.shrink(),
                            _buildActions(context, ref, user),
                            const Spacer(flex: 3),
                            _buildFooter(context, ref),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
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
}