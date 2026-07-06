import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common/player_avatar.dart';
import '../../auth/domain/user_entity.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../economy/providers/economy_provider.dart';
import '../../../shared/widgets/buttons/stage_button.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import '../../../shared/widgets/common/responsive_wrapper.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../profile/presentation/widgets/achievements_widget.dart';

part 'profile_screen.builders.part.dart';
part 'profile_screen.widgets.part.dart';

/// Test override: null ise gerçek ImagePicker kullanılır; override ile () async => null verilerek iptal simüle edilir.
final pickImageFromGalleryProvider = Provider<Future<XFile?> Function()?>((ref) => null);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTabIndex = 0; // 0: Profil, 1: Gardırop, 2: Performans
  bool _isUploading = false;

  AppLocalizations get l => AppLocalizations.of(context)!;

  void _setSelectedTab(int index) {
    setState(() => _selectedTabIndex = index);
  }

  Future<void> _updateDisplayName(UserEntity user) async {
    final controller = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l.updateDisplayNameTitle,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
        ),
        content: TextField(
          controller: controller,
          maxLength: 16,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l.newDisplayNameLabel,
            labelStyle: const TextStyle(color: Colors.white70),
            counterStyle: const TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.update),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      final name = newName.trim();
      final nameRegex = RegExp(r'^[a-zA-Z0-9ığüşöçİĞÜŞÖÇ ]+$');
      
      if (name.length >= 3 && nameRegex.hasMatch(name)) {
        final updatedUser = user.copyWith(displayName: name);
        await ref
            .read(userControllerProvider.notifier)
            .updateUserProfile(updatedUser);
        if (mounted) ToastUtils.showSuccess(context, l.profileUpdated);
      } else {
        ToastUtils.showError(context, l.invalidNameLong);
      }
    }
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final pick = ref.read(pickImageFromGalleryProvider);
    final image = pick != null
        ? await pick()
        : await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 512,
            maxHeight: 512,
            imageQuality: 70,
          );

    if (image != null) {
      if (!mounted) return;
      setState(() => _isUploading = true);

      try {
        // Zaten ImagePicker tarafından küçültüldüğü için doğrudan byteları alıp yükleyebiliriz
        // Ağır çalışan pure-dart ImageCompressor'ı devreden çıkardık
        final rawBytes = await image.readAsBytes();

        final url = await ref
            .read(userControllerProvider.notifier)
            .uploadAvatar(uid, rawBytes);

        if (url != null && mounted) {
          await ref
              .read(userControllerProvider.notifier)
              .updateAvatarUrl(uid, url);
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, l.error(ErrorMessageUtils.formatUserError(e, l)));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(
      watchUserProfileProvider(user?.uid ?? ''),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            l.editProfileTitle,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: 1.0,
              fontSize: 16,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : userProfileAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (err, stack) => Center(
                child: AsyncErrorView(
                  message: l.loadFailed,
                  detail: ErrorMessageUtils.formatUserError(err, l),
                  onRetry: () {
                    if (user != null) {
                      ref.invalidate(watchUserProfileProvider(user.uid));
                    }
                  },
                ),
              ),
              data: (userProfile) {
                // Auth'tan gelen ismi tercih et (Firestore'da 'Misafir' olabilir)
                final authName = user.displayName ?? l.playerDefaultName;
                UserEntity profile;
                if (userProfile == null) {
                  profile = UserEntity(
                    uid: user.uid,
                    displayName: authName,
                    avatarUrl: user.photoURL,
                  );
                } else {
                  // Firestore'daki isim 'Misafir' ise Auth ismini kullan
                  final effectiveName = (userProfile.displayName == 'Misafir')
                      ? authName
                      : userProfile.displayName;
                  profile = userProfile.copyWith(displayName: effectiveName);
                }
                return ResponsiveWrapper(
                  maxWidth: 600,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: _buildTabBar(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_selectedTabIndex == 0)
                                _buildActorTab(profile, userProfileAsync),
                              if (_selectedTabIndex == 1)
                                _buildWardrobeTab(profile, userProfileAsync),
                              if (_selectedTabIndex == 2)
                                _buildPerformanceTab(userProfileAsync),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
