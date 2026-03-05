import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/enums.dart';
import '../../auth/domain/user_entity.dart';
import '../../custom_decks/domain/user_task_entity.dart';
import '../../custom_decks/providers/user_task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';

class CustomDeckEditorScreen extends ConsumerStatefulWidget {
  const CustomDeckEditorScreen({super.key});

  @override
  ConsumerState<CustomDeckEditorScreen> createState() =>
      _CustomDeckEditorScreenState();
}

class _CustomDeckEditorScreenState
    extends ConsumerState<CustomDeckEditorScreen> {
  // Tematik Renkler
  static const _bgColor = Color(0xFF140D0B); // En arka plan
  static const _accentGold = Color(0xFFD4AF37); // Altın
  static const _accentCrimson = Color(0xFF5C1616); // Bordo
  static const _textLight = Color(0xFFFDEFC2); // Parşömen sarısı / açık
  static const _cardColor = Color(0xFF1E140F); // Koyu kahve/Ahşap tonu

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
                editingTask == null ? 'Kendi Sorunu Ekle' : 'Sorunu Düzenle',
                style: GoogleFonts.cinzelDecorative(
                  color: _textLight,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: contentController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Lütfen bir senaryo yazın'
                          : null,
                      maxLines: 3,
                      minLines: 1,
                      style: GoogleFonts.cinzel(color: _textLight),
                      decoration: InputDecoration(
                        labelText: 'Görev Metni',
                        labelStyle: GoogleFonts.cinzel(color: _accentGold),
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDifficulty,
                      dropdownColor: _cardColor,
                      decoration: InputDecoration(
                        labelText: 'Zorluk',
                        labelStyle: GoogleFonts.cinzel(color: _accentGold),
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
                          const [
                                DropdownMenuItem(
                                  value: 'easy',
                                  child: Text('Kolay'),
                                ),
                                DropdownMenuItem(
                                  value: 'medium',
                                  child: Text('Orta'),
                                ),
                                DropdownMenuItem(
                                  value: 'hard',
                                  child: Text('Zor'),
                                ),
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.value,
                                  child: Text(
                                    (item.child as Text).data!,
                                    style: GoogleFonts.cinzel(
                                      color: _textLight,
                                    ),
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
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.cinzel(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final controllerState = ref.watch(
                      customTaskControllerProvider,
                    );
                    final isLoading = controllerState.isLoading;

                    ref.listen(customTaskControllerProvider, (prev, next) {
                      if (next is AsyncError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hata: ${next.error}')),
                        );
                      } else if (prev?.isLoading == true &&
                          !next.isLoading &&
                          !next.hasError) {
                        Navigator.pop(context);
                      }
                    });

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentCrimson,
                        foregroundColor: _textLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _accentGold.withValues(alpha: 0.5),
                          ),
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
                                color: _textLight,
                              ),
                            )
                          : Text(
                              editingTask == null ? 'Ekle' : 'Güncelle',
                              style: GoogleFonts.cinzel(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ],
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
        body: Center(child: Text('Hata: $e')),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final customTasksAsync = ref.watch(watchCustomTasksProvider(user.uid));

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            title: Text(
              'Senin Soruların',
              style: GoogleFonts.cinzelDecorative(
                fontWeight: FontWeight.w700,
                color: _textLight,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _accentGold,
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: _accentGold,
                  size: 28,
                ),
                onPressed: () => _showTaskDialog(user),
                tooltip: 'Soru Ekle',
              ),
            ],
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
              Container(color: _bgColor.withValues(alpha: 0.85)),

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
                            'Bir hata oluştu: $err',
                            style: GoogleFonts.cinzel(color: _accentCrimson),
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
                                      color: _accentGold.withValues(alpha: 0.3),
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Henüz efsanelere konu olacak sorular girmedin.\nSağ üstten yeni soru ekle!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cinzel(
                                        color: _textLight.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 18,
                                        height: 1.5,
                                      ),
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
                                        color: _accentGold.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1.5,
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
                                                  style: GoogleFonts.cinzel(
                                                    color: _textLight,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.4,
                                                  ),
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
                                                        task.category,
                                                        style:
                                                            GoogleFonts.cinzel(
                                                              color:
                                                                  _accentGold,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
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
                                                            ? 'KOLAY'
                                                            : task.difficulty ==
                                                                  'medium'
                                                            ? 'ORTA'
                                                            : 'ZOR',
                                                        style:
                                                            GoogleFonts.cinzel(
                                                              color: Colors
                                                                  .grey
                                                                  .shade400,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
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
                                                tooltip: 'Düzenle',
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
                                                tooltip: 'Sil',
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

