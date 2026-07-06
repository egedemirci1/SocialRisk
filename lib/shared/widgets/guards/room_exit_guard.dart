import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_risk/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../utils/toast_utils.dart';

/// Lobby veya aktif oyun bağlamında odadan çıkış onayı.
enum LeaveRoomMode {
  lobby,
  inGame,
}

/// Geri sayımlı çıkış dialog'unu açar.
void showLeaveRoomDialog(
  BuildContext context,
  WidgetRef ref,
  String roomCode, {
  LeaveRoomMode mode = LeaveRoomMode.inGame,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => LeaveRoomCountdownDialog(
      roomCode: roomCode,
      mode: mode,
    ),
  );
}

/// Tarayıcı / sistem geri tuşunu onaylı çıkışa yönlendirir.
class RoomExitPopScope extends ConsumerWidget {
  const RoomExitPopScope({
    super.key,
    required this.roomCode,
    required this.child,
    this.mode = LeaveRoomMode.inGame,
  });

  final String roomCode;
  final LeaveRoomMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showLeaveRoomDialog(context, ref, roomCode, mode: mode);
      },
      child: child,
    );
  }
}

class LeaveRoomCountdownDialog extends ConsumerStatefulWidget {
  const LeaveRoomCountdownDialog({
    super.key,
    required this.roomCode,
    required this.mode,
  });

  final String roomCode;
  final LeaveRoomMode mode;

  @override
  ConsumerState<LeaveRoomCountdownDialog> createState() =>
      _LeaveRoomCountdownDialogState();
}

class _LeaveRoomCountdownDialogState
    extends ConsumerState<LeaveRoomCountdownDialog> {
  static const int _initialSeconds = 3;
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        setState(() => _remaining = 0);
        timer.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(roomControllerProvider.notifier).leaveRoom(
            roomCode: widget.roomCode,
            playerId: user.uid,
          );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (context.mounted) {
      ToastUtils.showInfo(
        context,
        AppLocalizations.of(context)!.leftRoomToast,
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final canExit = _remaining == 0;
    final confirmMessage = widget.mode == LeaveRoomMode.inGame
        ? l.leavePartyConfirmInGame
        : l.leavePartyConfirm;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      title: Text(
        l.leavePartyTitle,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        canExit
            ? confirmMessage
            : l.exitButtonActiveIn(_remaining),
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel, style: const TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: !canExit ? null : _confirmExit,
          child: Text(
            canExit
                ? l.deleteAndExit
                : '${l.deleteAndExit} ($_remaining)',
          ),
        ),
      ],
    );
  }
}
