import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/room/providers/room_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../audio/audio_service.dart';
import 'shared_prefs_provider.dart';

const _activeRoomPrefsKey = 'active_room_code';

/// Kullanıcının o an hangi odada olduğunu takip eden basit bir provider.
class CurrentRoomTracker extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_activeRoomPrefsKey);
  }

  void updateRoom(String? roomCode) {
    state = roomCode;
    final prefs = ref.read(sharedPreferencesProvider);
    if (roomCode == null || roomCode.isEmpty) {
      prefs.remove(_activeRoomPrefsKey);
    } else {
      prefs.setString(_activeRoomPrefsKey, roomCode);
    }
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
    // Arka plan / sekme değişiminde sesi duraklat; oda çıkışı yalnızca kapanışta.
    _listener = AppLifecycleListener(
      onPause: _handleAudioPause,
      onInactive: _handleAudioPause,
      onHide: _handleAudioPause,
      onResume: _handleAudioResume,
      onShow: _handleAudioResume,
      onDetach: _handleExit,
    );
  }

  void _handleAudioPause() {
    ref.read(audioServiceProvider).pauseForLifecycle();
  }

  void _handleAudioResume() {
    ref.read(audioServiceProvider).resumeFromLifecycle();
  }

  void dispose() {
    _listener.dispose();
  }

  Future<void> _handleExit() async {
    await ref.read(audioServiceProvider).stopAll();

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
