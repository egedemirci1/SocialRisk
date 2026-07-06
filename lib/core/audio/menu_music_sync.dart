import 'audio_service.dart';

/// Menü müziği çalınmayan rotalar.
const _silentRoutes = <String>{
  '/',
  '/splash',
};

const _gameRoutes = <String>{
  '/task',
  '/performing',
  '/voting',
  '/waiting',
  '/round-result',
  '/difficulty',
  '/economy-pick',
  '/game-over',
};

bool routeUsesMenuMusic(String location) {
  if (_silentRoutes.contains(location)) return false;
  if (location.startsWith('/admin')) return false;
  if (_gameRoutes.contains(location)) return false;
  return true;
}

bool routeStopsMenuMusic(String location) => _gameRoutes.contains(location);

/// Rota değişiminde menü müziğini tek noktadan yönet.
void syncMenuMusicForRoute(AudioService audio, String location) {
  if (routeStopsMenuMusic(location)) {
    audio.stopMusic();
    return;
  }
  if (routeUsesMenuMusic(location)) {
    audio.ensureMenuMusic();
  }
}
