import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../../core/constants/app_text_styles.dart';

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
          builder: (ctx) => AlertDialog(
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
              'Oyundan çıkmak istediğinize emin misiniz? (Eğer kurucuysanız oda kapanır.)',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    ref.read(roomControllerProvider.notifier).leaveRoom(
                          roomCode: roomCode,
                          playerId: user.uid,
                        );
                  }
                  context.go('/home');
                },
                child: const Text('Çıkış'),
              ),
            ],
          ),
        );
      },
    );
  }
}
