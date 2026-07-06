import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/task_item_entity.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/common/animated_mesh_background.dart';
import 'package:social_risk/core/constants/app_text_styles.dart';
import '../../../core/data/task_translations/task_translation_map.dart';
import 'package:social_risk/core/providers/locale_provider.dart';
import '../../../shared/widgets/common/async_error_view.dart';
import '../../../shared/utils/error_message_utils.dart';
import '../../../shared/utils/toast_utils.dart';
import 'package:social_risk/l10n/app_localizations.dart';

part 'admin_dashboard_screen.builders.part.dart';
part 'admin_dashboard_screen.widgets.part.dart';

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

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l.adminPanelTitle,
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
              child: AsyncErrorView(
                message: l.loadFailed,
                detail: ErrorMessageUtils.formatUserError(e, l),
                onRetry: () => ref.invalidate(adminTasksProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setSortOption(SortOption value) => setState(() => _sortOption = value);

  void _setSelectedCategory(String? category) =>
      setState(() => _selectedCategory = category);
}