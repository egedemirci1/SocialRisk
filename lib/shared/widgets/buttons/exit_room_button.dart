import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../utils/toast_utils.dart';

class ExitRoomButton extends ConsumerWidget {
  final String roomCode;

  const ExitRoomButton({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.primary),
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => _ExitCountdownDialog(roomCode: roomCode),
        );
      },
    );
  }
}

class _ExitCountdownDialog extends ConsumerStatefulWidget {
  const _ExitCountdownDialog({required this.roomCode});

  final String roomCode;

  @override
  ConsumerState<_ExitCountdownDialog> createState() => _ExitCountdownDialogState();
}

class _ExitCountdownDialogState extends ConsumerState<_ExitCountdownDialog> {
  static const int _initialSeconds = 10;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      title: Text(
        'Partiden Ayrıl',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        canExit
            ? 'Oyundan çıkmak istediğinize emin misiniz? (Eğer kurucuysanız oda kapanır.)'
            : 'Çıkış butonu $_remaining saniye sonra aktif olacak.',
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: !canExit
              ? null
              : () {
                  Navigator.of(context).pop();
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.read(roomControllerProvider.notifier).leaveRoom(
                          roomCode: widget.roomCode,
                          playerId: user.uid,
                        );
                  }
                  if (context.mounted) {
                    ToastUtils.showInfo(context, 'Odadan ayrıldınız');
                  }
                  context.go('/home');
                },
          child: Text(canExit ? 'Sil ve Çık' : 'Sil ve Çık ($_remaining)'),
        ),
      ],
    );
  }
}
