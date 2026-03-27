import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/enums.dart';
import '../../auth/domain/user_entity.dart';
import '../../custom_decks/domain/user_task_entity.dart';
import '../../custom_decks/providers/user_task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../../shared/utils/toast_utils.dart';
import '../../../core/constants/app_colors.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import 'package:social_risk/l10n/app_localizations.dart';

class CustomDeckEditorScreen extends ConsumerStatefulWidget {
  const CustomDeckEditorScreen({super.key});

  @override
  ConsumerState<CustomDeckEditorScreen> createState() =>
      _CustomDeckEditorScreenState();
}

class _CustomDeckEditorScreenState
    extends ConsumerState<CustomDeckEditorScreen> {
  // Keep legacy colors for card list (will be migrated separately)
  static const _bgColor = AppColors.background;
  static const _accentGold = AppColors.accent;
  static const _accentCrimson = AppColors.error;
  static const _textLight = Colors.white;
  static const _cardColor = AppColors.surface;

  AppLocalizations get l => AppLocalizations.of(context)!;

  void _showTaskDialog(UserEntity user, {UserTaskEntity? editingTask}) {
    final uid = user.uid;
    final formKey = GlobalKey<FormState>();
    final contentController = TextEditingController(
      text: editingTask?.content ?? '',
    );
    String selectedDifficulty = editingTask?.difficulty ?? 'easy';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer(
              builder: (context, ref, _) {
                final controllerState = ref.watch(customTaskControllerProvider);
                final isLoading = controllerState.isLoading;
                
                ref.listen(customTaskControllerProvider, (prev, next) {
                  if (next is AsyncError) {
                    ToastUtils.showError(context, l.error(next.error.toString()));
                  } else if (prev?.isLoading == true &&
                      !next.isLoading &&
                      !next.hasError) {
                    ToastUtils.showSuccess(context, editingTask == null ? l.contentAdded : l.contentUpdated);
                    Navigator.pop(context);
                  }
                });
                
                return AlertDialog(
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _accentGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              title: Text(
                editingTask == null ? l.createContent : l.editContent,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    TextFormField(
                      controller: contentController,
                      enabled: !isLoading,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.pleaseWriteContent
                          : null,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 120,
                      style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l.contentText,
                        labelStyle: AppTextStyles.titleSmall.copyWith(color: AppColors.accent),
                        counterStyle: AppTextStyles.titleSmall.copyWith(color: Colors.white38),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDifficulty,
                      dropdownColor: _cardColor,
                      decoration: InputDecoration(
                        labelText: l.difficultyLabel,
                        labelStyle: AppTextStyles.titleSmall.copyWith(color: _accentGold),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.4),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _accentGold.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _accentGold),
                        ),
                      ),
                      items:
                          [
                                DropdownMenuItem(
                                  value: 'easy',
                                  child: Text(l.easyDifficulty),
                                ),
                                DropdownMenuItem(
                                  value: 'medium',
                                  child: Text(l.mediumDifficulty),
                                ),
                                DropdownMenuItem(
                                  value: 'hard',
                                  child: Text(l.hardDifficulty),
                                ),
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.value,
                                  child: Text(
                                    (item.child as Text).data!,
                                    style: AppTextStyles.titleSmall.copyWith(color: _textLight,),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedDifficulty = v!),
                    ),
                  ],
                ),
              ),
            ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(l.cancel, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) return;

                          final content = contentController.text.trim();
                          final task = UserTaskEntity(
                            id:
                                editingTask?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            category: 'Özel',
                            content: content,
                            difficulty: selectedDifficulty,
                            type: TaskType.action,
                            tags: const ['custom'],
                            isActive: true,
                          );

                          final notifier = ref.read(
                            customTaskControllerProvider.notifier,
                          );
                          if (editingTask == null) {
                            notifier.addTask(uid: uid, task: task);
                          } else {
                            notifier.updateTask(uid: uid, task: task);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          editingTask == null ? l.addContent : l.update,
                          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800,),
                        ),
                ),
              ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: _accentGold),
        ),
      );
    }

    final userAsync = ref.watch(watchUserProfileProvider(authUser.uid));

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: _bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: _accentGold),
        ),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: Text(l.error(e.toString()))),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final premiumService = ref.read(premiumPurchaseServiceProvider);
        premiumService.init();

        if (!user.isPremium) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                l.myContentsTitle,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.accent),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 62),
                    const SizedBox(height: 16),
                    Text(
                      'Özel içerik üretmek için Premium gerekli.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tek seferlik Premium satın alarak içerik ekleme özelliğini açabilirsin.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await premiumService.buyLifetimePremium();
                          if (!context.mounted) return;
                          ToastUtils.showSuccess(
                            context,
                            'Satın alma akışı başlatıldı.',
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastUtils.showError(context, e.toString());
                        }
                      },
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Premium Al'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await premiumService.restorePurchases();
                          if (!context.mounted) return;
                          ToastUtils.showSuccess(context, 'Satın alımlar geri yükleniyor.');
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastUtils.showError(context, e.toString());
                        }
                      },
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Satın Alımları Geri Yükle'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final customTasksAsync = ref.watch(watchCustomTasksProvider(user.uid));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              l.myContentsTitle,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 18,),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.accent,
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
                onPressed: () => _showTaskDialog(user),
                tooltip: l.createContent,
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0D0D1A),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
              // Accent glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Kategori Filtreleme (Chips) kaldırıldı
                    Expanded(
                      child: customTasksAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: _accentGold),
                        ),
                        error: (err, stack) => Center(
                          child: Text(
                            l.error(err.toString()),
                            style: AppTextStyles.titleSmall.copyWith(color: _accentCrimson),
                          ),
                        ),
                        data: (allTasks) {
                          final tasks = allTasks;

                          if (tasks.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_stories_outlined,
                                      color: AppColors.accent.withValues(alpha: 0.3),
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l.myContentsDescription,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l.myContentsUsage,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white38,
                                        fontSize: 13,
                                        height: 1.5,),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () => _showTaskDialog(user),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      ),
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(l.createContent, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                              bottom: 80,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];

                              return Stack(
                                children: [
                                  Card(
                                    color: _cardColor.withValues(alpha: 0.9),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.1,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Kalem / Tüy İkonu
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _accentGold.withValues(
                                                alpha: 0.1,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _accentGold.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.history_edu_rounded,
                                              color: _accentGold,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.content,
                                                  style: AppTextStyles.titleMedium.copyWith(color: _textLight,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.4,),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: _accentGold
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                          task.category == 'Özel' ? l.specialCategory : task.category,
                                                          style:
                                                              AppTextStyles.labelSmall.copyWith(color:
                                                                    _accentGold,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,),
                                                        ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.grey
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                          task.difficulty ==
                                                                  'easy'
                                                              ? l.easyDifficulty.toUpperCase()
                                                              : task.difficulty ==
                                                                    'medium'
                                                              ? l.mediumDifficulty.toUpperCase()
                                                              : l.hardDifficulty.toUpperCase(),
                                                        style:
                                                            AppTextStyles.labelSmall.copyWith(color: Colors
                                                                  .grey
                                                                  .shade400,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_note_rounded,
                                                  color: _accentGold,
                                                ),
                                                onPressed: () =>
                                                    _showTaskDialog(
                                                      user,
                                                      editingTask: task,
                                                    ),
                                                tooltip: l.editTooltip,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: _accentCrimson,
                                                ),
                                                onPressed: () => ref
                                                    .read(
                                                      customTaskControllerProvider
                                                          .notifier,
                                                    )
                                                    .deleteTask(
                                                      uid: user.uid,
                                                      taskId: task.id,
                                                    ),
                                                tooltip: l.deleteTooltip,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

