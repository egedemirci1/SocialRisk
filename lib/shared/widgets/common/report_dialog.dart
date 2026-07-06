import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/user_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/toast_utils.dart';

class ReportDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
  }) async {
    final l = AppLocalizations.of(context)!;
    final reasons = [
      l.reportReasonInappropriate,
      l.reportReasonViolence,
      l.reportReasonSpam,
      l.reportReasonOther,
    ];

    String selectedReason = reasons.first;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                l.reportUserTitle,
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.reportUserConfirmMessage,
                    style: const TextStyle(color: Colors.white70),
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
                  child: Text(l.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    l.reportUserAction,
                    style: const TextStyle(color: AppColors.error),
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
          ToastUtils.showSuccess(context, l.reportUserSuccess);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showError(context, l.reportUserFailed);
        }
      }
    }
  }
}
