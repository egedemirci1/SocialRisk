import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../utils/toast_utils.dart';

class LeaveRoomButton extends ConsumerWidget {
  final String roomCode;

  const LeaveRoomButton({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.primary),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => _LeaveCountdownDialog(roomCode: roomCode),
        );
      },
    );
  }
}

class _LeaveCountdownDialog extends ConsumerStatefulWidget {
  const _LeaveCountdownDialog({required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<_LeaveCountdownDialog> createState() => _LeaveCountdownDialogState();
}

class _LeaveCountdownDialogState extends ConsumerState<_LeaveCountdownDialog> {
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

  @override
  Widget build(BuildContext context) {
    final canExit = _remaining == 0;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Oyundan Çık',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        canExit
            ? 'Odadan / Oyundan ayrılmak istediğinize emin misiniz? Oyun devam ederken çıkış yapmak oyunun akışını etkileyebilir.'
            : 'Sil ve Çık butonu $_remaining saniye sonra aktif olacak.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'İptal',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: !canExit
              ? null
              : () {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref
                        .read(roomControllerProvider.notifier)
                        .leaveRoom(roomCode: widget.roomCode, playerId: user.uid);
                  }
                  Navigator.pop(context);
                  if (context.mounted) {
                    ToastUtils.showInfo(context, 'Odadan ayrıldınız');
                  }
                  context.go('/home');
                },
          child: Text(
            canExit ? 'Sil ve Çık' : 'Sil ve Çık ($_remaining)',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
