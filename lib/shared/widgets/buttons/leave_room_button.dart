import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/room/providers/room_provider.dart';

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
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Oyundan Çık',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Odadan / Oyundan ayrılmak istediğinize emin misiniz? Oyun devam ederken çıkış yapmak oyunun akışını etkileyebilir.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref
                        .read(roomControllerProvider.notifier)
                        .leaveRoom(roomCode: roomCode, playerId: user.uid);
                  }
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text(
                  'Çık',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
