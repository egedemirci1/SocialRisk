import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/user_provider.dart';

class ReportDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
  }) async {
    final reasons = [
      'Uygunsuz Fotoğraf / Çıplaklık',
      'Şiddet veya Tehdit',
      'Spam veya Reklam',
      'Diğer',
    ];

    String selectedReason = reasons.first;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Kullanıcıyı Raporla',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bu kullanıcının profil fotoğrafını raporlamak istediğinize emin misiniz?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                    ),
                    items: reasons
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Raporla',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      try {
        await ref
            .read(userControllerProvider.notifier)
            .reportUser(
              targetUserId: targetUserId,
              targetUserName: targetUserName,
              targetUserAvatar: targetUserAvatar,
              reason: selectedReason,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı raporlandı. İnceleyeceğiz.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Raporlanırken hata oluştu.')),
          );
        }
      }
    }
  }
}
