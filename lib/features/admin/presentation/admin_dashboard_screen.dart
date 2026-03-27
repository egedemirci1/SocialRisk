import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/task_item_entity.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';

enum SortOption {
  newest,
  mostLiked,
  leastLiked,
  mostDisliked,
}

/// Yönetici (Admin) Paneli — Parti Temalı, Responsive
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String? _selectedCategory;
  SortOption _sortOption = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(adminTasksProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'YÖNETİCİ PANELİ',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 2,
            fontSize: isSmallScreen ? 16 : 20,
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
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedMeshBackground(),
          ),
          tasksAsync.when(
            data: (tasks) {
              final filteredTasks = _filterAndSortTasks(tasks);
              final categories = _getCategories(tasks);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoBanner(tasks.length, filteredTasks.length, isSmallScreen),
                  _buildMaintenanceButtons(isSmallScreen, ref),
                  _buildFilters(categories, isSmallScreen),
                  const SizedBox(height: 8),
                  _buildTaskList(filteredTasks, isSmallScreen, ref),
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
        ],
      ),
    );
  }

  Widget _buildInfoBanner(int total, int filtered, bool isSmall) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 12, isSmall ? 12 : 20, 8),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accent, size: isSmall ? 24 : 28),
            SizedBox(width: isSmall ? 8 : 12),
            Expanded(
              child: Text(
                'Toplam $total görev • Filtreli: $filtered',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceButtons(bool isSmall, WidgetRef ref) {
    final buttons = [
      _MaintenanceButtonData(
        label: 'BAKIM TEMİZLİĞİ',
        icon: Icons.cleaning_services_rounded,
        color: AppColors.primary,
        onPressed: () => _runMaintenanceCleanup(context, ref),
      ),
      _MaintenanceButtonData(
        label: 'GÖREVLERİ YENİLE',
        icon: Icons.refresh_rounded,
        color: AppColors.accent,
        onPressed: () => _runSeedTasks(context, ref),
      ),
      _MaintenanceButtonData(
        label: 'ESKİ ODALARI SİL (3h+)',
        icon: Icons.delete_forever_rounded,
        color: Colors.red.shade700,
        onPressed: () => _runForceCleanup(context, ref),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 8, isSmall ? 12 : 20, 8),
      child: isSmall
          ? Column(
              children: buttons
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildMaintenanceButton(b, true),
                      ))
                  .toList(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMaintenanceButton(buttons[0], false)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMaintenanceButton(buttons[1], false)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _buildMaintenanceButton(buttons[2], false),
                ),
              ],
            ),
    );
  }

  Widget _buildMaintenanceButton(_MaintenanceButtonData data, bool isSmall) {
    return ElevatedButton.icon(
      onPressed: data.onPressed,
      icon: Icon(data.icon, color: Colors.white, size: isSmall ? 18 : 20),
      label: Text(
        data.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: data.color,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 10 : 14,
          horizontal: isSmall ? 8 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFilters(List<String> categories, bool isSmall) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 8, isSmall ? 12 : 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort Dropdown
          Row(
            children: [
              Text(
                'Sıralama:',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white70,
                  fontSize: isSmall ? 12 : 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SortOption>(
                      value: _sortOption,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: isSmall ? 12 : 14,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      onChanged: (value) {
                        if (value != null) setState(() => _sortOption = value);
                      },
                      items: [
                        DropdownMenuItem(
                          value: SortOption.newest,
                          child: Text('En Yeni', style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.mostLiked,
                          child: Text('En Çok Beğenilen 👍', style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.leastLiked,
                          child: Text('En Az Beğenilen 👎', style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: SortOption.mostDisliked,
                          child: Text('En Çok Beğenilmeyen 😒', style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category Chips
          Text(
            'Kategori Filtresi:',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white70,
              fontSize: isSmall ? 12 : 14,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: _selectedCategory == null ? Colors.black : Colors.white,
                    fontSize: isSmall ? 11 : 13,
                  ),
                ),
                ...categories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category ? Colors.black : Colors.white,
                    fontSize: isSmall ? 11 : 13,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskItemEntity> tasks, bool isSmall, WidgetRef ref) {
    if (tasks.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Filtreyle eşleşen görev bulunamadı.',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white24,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 20,
          vertical: 8,
        ),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(
            task: task,
            isSmallScreen: isSmall,
            onToggleActive: (val) {
              ref.read(adminControllerProvider.notifier).toggleTaskActiveStatus(task.id, val);
            },
            onEdit: () => context.push('/admin/task-editor', extra: task),
            onDelete: () => _deleteTask(context, ref, task),
          );
        },
      ),
    );
  }

  List<String> _getCategories(List<TaskItemEntity> tasks) {
    final categories = tasks.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<TaskItemEntity> _filterAndSortTasks(List<TaskItemEntity> tasks) {
    var filtered = _selectedCategory == null
        ? tasks
        : tasks.where((t) => t.category == _selectedCategory).toList();

    switch (_sortOption) {
      case SortOption.mostLiked:
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
      case SortOption.leastLiked:
        filtered.sort((a, b) => a.likes.compareTo(b.likes));
      case SortOption.mostDisliked:
        filtered.sort((a, b) => b.dislikes.compareTo(a.dislikes));
      case SortOption.newest:
        break;
    }

    return filtered;
  }

  Future<void> _runMaintenanceCleanup(BuildContext context, WidgetRef ref) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'BAKIM TEMİZLİĞİ?',
      content: 'Boş odalar, bitmiş oyunlar ve aktif olmayan kullanıcılar silinecek.',
      confirmText: 'ÇALIŞTIR',
      confirmColor: AppColors.primary,
    );
    if (confirm == true) {
      try {
        final result = await ref.read(adminControllerProvider.notifier).runMaintenanceCleanup();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Temizlik: ${result['roomsDeleted']} oda, ${result['gamesDeleted']} oyun, ${result['usersDeleted']} kullanıcı silindi.'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.primary),
          );
        }
      }
    }
  }

  Future<void> _runSeedTasks(BuildContext context, WidgetRef ref) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'GÖREVLERİ YENİLE?',
      content: 'Mevcut tüm görevler silinip güncel seed verisi yüklenecek.',
      confirmText: 'YENİLE',
      confirmColor: AppColors.accent,
    );
    if (confirm == true) {
      try {
        await ref.read(adminControllerProvider.notifier).seedTasks();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görevler güncel seed ile yenilendi.'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.primary),
          );
        }
      }
    }
  }

  Future<void> _runForceCleanup(BuildContext context, WidgetRef ref) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'ESKİ AKTİF ODALARI TEMİZLE?',
      content: '3 saatten eski tüm playing/lobby odaları ve oyunları silecek. Devam?',
      confirmText: 'SİL',
      confirmColor: Colors.red,
    );
    if (confirm == true) {
      try {
        final count = await ref.read(adminControllerProvider.notifier).forceCleanupOldPlayingRooms();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count eski aktif oda silindi.'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.primary),
          );
        }
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref, TaskItemEntity task) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'GÖREVİ SİL?',
      content: 'Bu görev sistemden kalıcı olarak silinecek.',
      confirmText: 'SİL',
      confirmColor: AppColors.primary,
    );
    if (confirm == true) {
      await ref.read(adminControllerProvider.notifier).deleteTask(task.id);
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          content,
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İPTAL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceButtonData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  _MaintenanceButtonData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}

class _TaskCard extends StatelessWidget {
  final TaskItemEntity task;
  final bool isSmallScreen;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isSmallScreen,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1)),
      ),
      child: isSmallScreen ? _buildSmallLayout() : _buildLargeLayout(),
    );
  }

  Widget _buildSmallLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          title: Text(
            task.content,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _buildBadge(task.category, AppColors.accent),
                const SizedBox(width: 8),
                _buildBadge(task.difficulty.toUpperCase(), Colors.white60),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LikeBadge(likes: task.likes, dislikes: task.dislikes, isSmall: true),
              const SizedBox(width: 8),
              Switch(
                value: task.isActive,
                activeThumbColor: AppColors.accent,
                onChanged: onToggleActive,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white70),
                  label: const Text('DÜZENLE', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, size: 16, color: AppColors.primary),
                  label: const Text('SİL', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeLayout() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        task.content,
        style: AppTextStyles.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _LikeBadge(likes: task.likes, dislikes: task.dislikes, isSmall: false),
            const SizedBox(width: 12),
            _buildBadge(task.category, AppColors.accent, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
            const SizedBox(width: 8),
            _buildBadge(task.difficulty.toUpperCase(), Colors.white60, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: task.isActive,
            activeThumbColor: AppColors.accent,
            onChanged: onToggleActive,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.primary, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == AppColors.accent ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: padding != null ? 11 : 10,
          fontWeight: color == AppColors.accent ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}

class _LikeBadge extends StatelessWidget {
  final int likes;
  final int dislikes;
  final bool isSmall;

  const _LikeBadge({
    required this.likes,
    required this.dislikes,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.thumb_up_rounded, size: isSmall ? 12 : 14, color: Colors.green.shade400),
        const SizedBox(width: 2),
        Text(
          '$likes',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.green.shade400,
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: isSmall ? 4 : 8),
        Icon(Icons.thumb_down_rounded, size: isSmall ? 12 : 14, color: Colors.red.shade400),
        const SizedBox(width: 2),
        Text(
          '$dislikes',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.red.shade400,
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

