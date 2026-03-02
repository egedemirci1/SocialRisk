import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(adminTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Paneli - Görevler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/admin/task-editor'),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Seed Soruları Yükle',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seed işlemi başlatıldı...')),
              );
              try {
                await ref.read(adminControllerProvider.notifier).seedTasks();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Görevler seed edildi!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront_rounded),
            tooltip: 'Seed Kozmetikler Yükle',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kozmetikler seed ediliyor...')),
              );
              try {
                await ref
                    .read(adminControllerProvider.notifier)
                    .seedCosmetics();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seed tamamlandı!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_rounded),
            onPressed: () => context.push('/admin/reports'),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'Hiç görev yok.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                color: AppColors.surfaceElevated,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    task.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${task.category} • ${task.difficulty} • Beğeni: ${task.likes} / Dislike: ${task.dislikes}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: task.isActive,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          ref
                              .read(adminControllerProvider.notifier)
                              .toggleTaskActiveStatus(task.id, val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            context.push('/admin/task-editor', extra: task),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.error,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'Sil?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Bu görev kalıcı olarak silinecek.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Sil',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref
                                .read(adminControllerProvider.notifier)
                                .deleteTask(task.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Hata: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
