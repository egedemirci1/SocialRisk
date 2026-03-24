import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../auth/providers/user_provider.dart';
import '../../admin/providers/admin_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../auth/domain/user_entity.dart';
import '../../economy/domain/cosmetic_item_entity.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/pending_toast.dart';
import '../../../shared/widgets/common/social_risk_logo.dart';
import '../../../shared/widgets/common/theater_loading_screen.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import '../../../core/audio/audio_service.dart';

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
    // Ana menü müziğini menü akışlarında loop'ta tut.
    ref.read(audioServiceProvider).playMenuLoop();
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
        return SafeArea(
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
                  'Menü',
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
                    'Ayarlar',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Ses ve Dil',
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
                    'Mağaza',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Kozmetikler ve içerikler',
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
                    'İçeriklerim',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Kendi içeriklerini yönet',
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
                    'Çıkış Yap',
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
                    '2026 Tüm Hakları Saklıdır',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = user != null
        ? ref.watch(watchUserProfileProvider(user.uid))
        : const AsyncValue<UserEntity?>.loading();

    final cosmeticsAsync = ref.watch(fetchCosmeticsProvider);

    final profile = userProfileAsync.value;
    final displayName = profile?.displayName ?? user?.displayName ?? 'Oyuncu';
    final cosmetics = cosmeticsAsync.value ?? [];

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
      if (userProfileAsync.hasValue || userProfileAsync.hasError) loadingProgress = 0.66;
      if (cosmeticsAsync.hasValue || cosmeticsAsync.hasError) loadingProgress = 1.0;
    }

    if (isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: TheaterLoadingScreen(
          message: 'Ana menü hazırlanıyor...',
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

  Widget _buildWelcome(
    BuildContext context,
    String playerName,
    UserEntity? profile,
    List<CosmeticItemEntity> cosmetics,
    String? uid,
  ) {
    final activeTitleItem = profile?.activeTitle != null
        ? cosmetics.where((c) => c.id == profile!.activeTitle).firstOrNull
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: PlayerAvatar(
              uid: uid ?? '',
              displayName: playerName,
              radius: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: AppTextStyles.displayLarge.copyWith(color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            shadows: const [
              Shadow(offset: Offset(-1.5, -1.5), color: Colors.black87),
              Shadow(offset: Offset(1.5, -1.5), color: Colors.black87),
              Shadow(offset: Offset(1.5, 1.5), color: Colors.black87),
              Shadow(offset: Offset(-1.5, 1.5), color: Colors.black87),
              Shadow(offset: Offset(0, 6), color: Colors.black54, blurRadius: 8),
            ],),
          textAlign: TextAlign.center,
        ),
        if (activeTitleItem != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AppColors.accentGradient.begin,
                end: AppColors.accentGradient.end,
                colors: AppColors.accentGradient.colors
                    .map((c) => c.withValues(alpha: 0.15))
                    .toList(),
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              activeTitleItem.name,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageButton(
          label: 'Yeni Parti Başlat',
          icon: Icons.add_circle_outline_rounded,
          backgroundColor: AppColors.primary,
          textColor: AppColors.background,
          borderColor: Colors.transparent,
          onPressed: () => context.push('/create-room'),
        ),
        const SizedBox(height: 16),
        StageButton(
          label: 'Partiye Katıl',
          icon: Icons.login_rounded,
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          borderColor: Colors.transparent,
          onPressed: () => context.push('/join-room'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StageButton(
                label: 'Mağaza',
                icon: Icons.shopping_bag_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/store'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StageButton(
                label: 'İçerik',
                icon: Icons.menu_book_rounded,
                backgroundColor: AppColors.surface,
                textColor: AppColors.accent,
                borderColor: AppColors.accent.withValues(alpha: 0.3),
                onPressed: () => context.push('/custom-deck'),
              ),
            ),
          ],
        ),
        if (isAdmin(user?.uid)) ...[
          const SizedBox(height: 24),
          StageButton(
            label: 'Yönetici Paneli',
            icon: Icons.admin_panel_settings_rounded,
            backgroundColor: const Color(0xFF1A1A1A),
            textColor: Colors.amber,
            borderColor: Colors.amber.withValues(alpha: 0.5),
            onPressed: () => context.push('/admin'),
          ),
        ],
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user?.isAnonymous == true) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                'DİKKAT!',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'Misafir olarak oynuyorsun. Çıkış yaparsan puan, rütbe ve kozmetikler kalıcı olarak silinir.\n\nYine de çıkmak istiyor musun?',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                foregroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hayır', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Sil ve Çık', style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Çıkış Başarılı');
        await Future.delayed(const Duration(milliseconds: 600));
        if (context.mounted) context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Çıkış yapılamadı: $e');
      }
    }
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/profile'),
          child: Text(
            'Profil',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,),
          ),
        ),
        Container(
          height: 16,
          width: 1,
          color: Colors.white24,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        TextButton(
          onPressed: () => _showSettingsSheet(context, ref),
          child: Text(
            'Menü',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,),
          ),
        ),
      ],
    );
  }
}
