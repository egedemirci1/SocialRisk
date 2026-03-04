import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/room/providers/room_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Kullanıcının o an hangi odada olduğunu takip eden basit bir provider.
class CurrentRoomTracker extends Notifier<String?> {
  @override
  String? build() => null;

  void updateRoom(String? roomCode) {
    state = roomCode;
  }
}

final currentRoomTrackerProvider =
    NotifierProvider<CurrentRoomTracker, String?>(CurrentRoomTracker.new);

/// Uygulama yaşam döngüsünü (Lifecycle) dinleyen ve
/// uygulama kapandığında odadan ayrılmayı sağlayan provider.
final appLifecycleManagerProvider = Provider<AppLifecycleManager>((ref) {
  final manager = AppLifecycleManager(ref);
  manager.init();
  ref.onDispose(() => manager.dispose());
  return manager;
});

class AppLifecycleManager {
  final Ref ref;
  late final AppLifecycleListener _listener;

  AppLifecycleManager(this.ref);

  void init() {
    _listener = AppLifecycleListener(
      onDetach: _handleExit,
      onHide: _handleExit,
    );
  }

  void dispose() {
    _listener.dispose();
  }

  Future<void> _handleExit() async {
    final roomCode = ref.read(currentRoomTrackerProvider);
    final user = ref.read(currentUserProvider);

    if (roomCode != null && user != null) {
      // Fire-and-forget
      ref
          .read(roomControllerProvider.notifier)
          .leaveRoom(roomCode: roomCode, playerId: user.uid);
    }
  }
}
