import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/room/providers/room_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/enums.dart';
import '../../utils/toast_utils.dart';

/// Dinler ve eğer odadaki oyuncu sayısı 2'nin altına düşerse
/// kullanıcıyı ana ekrana (lobi/home) atar.
class ActiveGameGuard extends ConsumerWidget {
  final Widget child;
  final String roomCode;

  const ActiveGameGuard({
    super.key,
    required this.child,
    required this.roomCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(watchPlayersProvider(roomCode));

    ref.listen(watchPlayersProvider(roomCode), (previous, next) {
      if (!context.mounted) return;

      final players = next.value;
      if (players == null) return; // Henüz yüklenmedi

      // Oyunun durumunu alalım. Eğer oyun henüz playing değilse kimseyi atmayalım.
      final roomAsync = ref.read(watchRoomProvider(roomCode));
      final roomData = roomAsync.value;

      // Kendimizin listede olduğundan emin olalım (Zaten çıktıysak bizi ilgilendirmez)
      final currentUser = ref.read(currentUserProvider);
      final isIamInRoom = players.any((p) => p.id == currentUser?.uid);

      if (!isIamInRoom) return; // Ben zaten odadan çıktıysam guard çalışmamalı

      // Eğer oyun devam ederken oyuncu sayısı 2'nin altına düşerse
      if (players.length < 2) {
        // Eğer oyun henüz yeni kuruluyorsa (lobby/bekleme vs), host tek kalana kadar bekleriz.
        // Ama eğer oyun aktif oynanıyorsa, o zaman at.
        if (roomData?.status != GameStatus.playing) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ToastUtils.showError(
              context,
              'Oyuncu sayısı yetersiz kaldığı için oyun sona erdi.',
            );

            // Kalan o son kişiyi de odadan çıkartıyoruz
            if (currentUser != null) {
              ref
                  .read(roomControllerProvider.notifier)
                  .leaveRoom(roomCode: roomCode, playerId: currentUser.uid);
            }

            // Ana ekrana yönlendir
            context.go('/home');
          }
        });
      }
    });

    return child;
  }
}
