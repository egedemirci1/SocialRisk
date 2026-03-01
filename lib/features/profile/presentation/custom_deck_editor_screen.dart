import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';
import '../../../shared/models/enums.dart';
import '../../custom_decks/domain/user_task_entity.dart';
import '../../custom_decks/providers/user_task_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CustomDeckEditorScreen extends ConsumerStatefulWidget {
  const CustomDeckEditorScreen({super.key});

  @override
  ConsumerState<CustomDeckEditorScreen> createState() =>
      _CustomDeckEditorScreenState();
}

class _CustomDeckEditorScreenState
    extends ConsumerState<CustomDeckEditorScreen> {
  void _showAddTaskDialog(String uid) {
    final contentController = TextEditingController();
    String selectedCategory = 'Cesaret';
    String selectedDifficulty = 'easy';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              title: const Text(
                'Kendi Sorunu Ekle',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Görev Metni',
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      filled: true,
                    ),
                    items: ['Cesaret', 'İtiraf', 'Taklit']
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDifficulty,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Zorluk',
                      filled: true,
                    ),
                    items: ['easy', 'medium', 'hard']
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedDifficulty = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    final content = contentController.text.trim();
                    if (content.isNotEmpty) {
                      final newTask = UserTaskEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: selectedCategory,
                        content: content,
                        difficulty: selectedDifficulty,
                        type: TaskType.action,
                        tags: const ['custom'],
                        isActive: true,
                      );
                      ref
                          .read(customTaskControllerProvider.notifier)
                          .addTask(uid: uid, task: newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Ekle',
                    style: TextStyle(color: Colors.white),
                  ),
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
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final customTasksAsync = ref.watch(watchCustomTasksProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senin Soruların'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddTaskDialog(user.uid),
          ),
        ],
      ),
      body: GradientContainer(
        child: customTasksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Bir hata oluştu: $err',
              style: const TextStyle(color: AppColors.voteNegative),
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  'Henüz kendi sorun yok.\nSağ üstten yeni soru ekle!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white54,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      task.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${task.category} • Zorluk: ${task.difficulty}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.voteNegative,
                      ),
                      onPressed: () {
                        ref
                            .read(customTaskControllerProvider.notifier)
                            .deleteTask(uid: user.uid, taskId: task.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
