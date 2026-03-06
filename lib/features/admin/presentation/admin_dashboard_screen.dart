import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_provider.dart';
import '../../../shared/utils/toast_utils.dart';

/// Yönetici (Admin) Paneli — Parti Temalı
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(adminTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'YÖNETİCİ PANELİ',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            onPressed: () => context.push('/admin/task-editor'),
          ),
          IconButton(
            icon: const Icon(Icons.report_rounded, color: AppColors.primary),
            onPressed: () => context.push('/admin/reports'),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kategoriler sabitlendi. İçerik girişine hazırsınız.',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Sistemde görev bulunamadı.',
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.white24,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
            itemCount: tasks.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.1),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    task.content,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${task.category.toUpperCase()} • ${task.difficulty.toUpperCase()} • 👍 ${task.likes} / 👎 ${task.dislikes}',
                    style: GoogleFonts.libreBaskerville(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: task.isActive,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) {
                          ref
                              .read(adminControllerProvider.notifier)
                              .toggleTaskActiveStatus(task.id, val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () =>
                            context.push('/admin/task-editor', extra: task),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: Text(
                                'GÖREVİ SİL?',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              content: Text(
                                'Bu görev sistemden kalıcı olarak silinecek.',
                                style: GoogleFonts.libreBaskerville(
                                  color: Colors.white70,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('İPTAL'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'SİL',
                                    style: TextStyle(color: AppColors.primary),
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
                  ),
                ),
              ],
            );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Hata: $e',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
