import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/shared_prefs_provider.dart';

enum AppSfx {
  buttonClick('assets/audio/sfx/button-click.mp3'),
  uiTapGeneric('assets/audio/sfx/button-click.mp3'),
  uiSuccess('assets/audio/sfx/success.mp3'),
  uiError('assets/audio/sfx/failed.mp3'),
  lobbyGameStart('assets/audio/sfx/success.mp3'),
  taskCardReveal('assets/audio/sfx/button-click.mp3'),
  wheelSpinStart('assets/audio/sfx/wheel-spin.mp3'),
  wheelSpinStop('assets/audio/sfx/button-click.mp3'),
  voteLike('assets/audio/sfx/button-click.mp3'),
  voteNeutral('assets/audio/sfx/button-click.mp3'),
  voteDislike('assets/audio/sfx/button-click.mp3'),
  voteResultLike('assets/audio/sfx/success.mp3'),
  voteResultNeutral('assets/audio/sfx/success.mp3'),
  voteResultDislike('assets/audio/sfx/failed.mp3'),
  gameOver('assets/audio/sfx/game-over.mp3'),
  roundResultShow('assets/audio/sfx/success.mp3'),
  roundNextTurn('assets/audio/sfx/button-click.mp3'),
  gameOverFanfare('assets/audio/sfx/game-over.mp3'),
  waitingTurnChime('assets/audio/sfx/button-click.mp3'),
  difficultyConfirm('assets/audio/sfx/success.mp3'),
  countdown('assets/audio/sfx/countdown.mp3'),
  performingTimerWarning('assets/audio/sfx/countdown.mp3'),
  performingTimerEnd('assets/audio/sfx/failed.mp3');

  const AppSfx(this.assetPath);
  final String assetPath;
}

const _prefMusicEnabled = 'audio_music_enabled';
const _prefSfxEnabled = 'audio_sfx_enabled';
const _prefMusicVolume = 'audio_music_volume';
const _prefSfxVolume = 'audio_sfx_volume';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  service.loadPreferences(ref.read(sharedPreferencesProvider));
  ref.onDispose(service.dispose);
  return service;
});

class AudioService {
  static const String menuLoopAsset = 'assets/audio/music/loop-menu-music.mp3';

  AudioService()
      : _sfxPlayer = AudioPlayer(),
        _musicPlayer = AudioPlayer(),
        _countdownPlayer = AudioPlayer() {
    _musicPlayer.setLoopMode(LoopMode.one);
  }

  final AudioPlayer _sfxPlayer;
  final AudioPlayer _musicPlayer;
  final AudioPlayer _countdownPlayer;

  SharedPreferences? _prefs;
  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.9;
  double _musicVolume = 0.35;
  String? _currentMusicAsset;
  bool _pendingMusicRetry = false;

  /// Menü loop'unun aktif olması gerektiğini işaretler (oyun ekranında false).
  bool _menuMusicActive = false;
  bool _pausedByLifecycle = false;
  bool _countdownLoopActive = false;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  bool get isMenuMusicActive => _menuMusicActive;

  void loadPreferences(SharedPreferences prefs) {
    _prefs = prefs;
    _musicEnabled = prefs.getBool(_prefMusicEnabled) ?? true;
    _sfxEnabled = prefs.getBool(_prefSfxEnabled) ?? true;
    _musicVolume = prefs.getDouble(_prefMusicVolume) ?? 0.35;
    _sfxVolume = prefs.getDouble(_prefSfxVolume) ?? 0.9;
    _musicPlayer.setVolume(_musicVolume);
    _sfxPlayer.setVolume(_sfxVolume);
    _countdownPlayer.setVolume(_sfxVolume);
  }

  Future<void> _persistPreferences() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setBool(_prefMusicEnabled, _musicEnabled);
    await prefs.setBool(_prefSfxEnabled, _sfxEnabled);
    await prefs.setDouble(_prefMusicVolume, _musicVolume);
    await prefs.setDouble(_prefSfxVolume, _sfxVolume);
  }

  Future<void> playSfx(AppSfx sfx, {double? volume}) async {
    if (!_sfxEnabled || _pausedByLifecycle) return;
    try {
      await _sfxPlayer.setVolume(volume ?? _sfxVolume);
      await _sfxPlayer.setAsset(sfx.assetPath);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('AudioService.playSfx failed: $e');
    }
  }

  Future<void> startCountdownLoop({double? volume}) async {
    _countdownLoopActive = true;
    if (!_sfxEnabled || _pausedByLifecycle) return;
    try {
      await _countdownPlayer.stop();
      await _countdownPlayer.setLoopMode(LoopMode.one);
      await _countdownPlayer.setVolume(volume ?? _sfxVolume);
      await _countdownPlayer.setAsset(AppSfx.countdown.assetPath);
      await _countdownPlayer.seek(Duration.zero);
      await _countdownPlayer.play();
    } catch (e) {
      debugPrint('AudioService.startCountdownLoop failed: $e');
    }
  }

  Future<void> stopCountdown() async {
    _countdownLoopActive = false;
    try {
      await _countdownPlayer.stop();
    } catch (e) {
      debugPrint('AudioService.stopCountdown failed: $e');
    }
  }

  Future<void> _pauseCountdownForLifecycle() async {
    if (!_countdownLoopActive) return;
    try {
      if (_countdownPlayer.playing) {
        await _countdownPlayer.pause();
      }
    } catch (e) {
      debugPrint('AudioService._pauseCountdownForLifecycle failed: $e');
    }
  }

  Future<void> _resumeCountdownAfterLifecycle() async {
    if (!_countdownLoopActive || !_sfxEnabled || _pausedByLifecycle) return;
    try {
      if (_countdownPlayer.processingState != ProcessingState.idle &&
          !_countdownPlayer.playing) {
        await _countdownPlayer.play();
        return;
      }
      if (_countdownPlayer.processingState == ProcessingState.idle) {
        await startCountdownLoop();
      }
    } catch (e) {
      debugPrint('AudioService._resumeCountdownAfterLifecycle failed: $e');
    }
  }

  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!_musicEnabled) return;
    if (_pausedByLifecycle) {
      _pendingMusicRetry = true;
      _currentMusicAsset = assetPath;
      return;
    }
    try {
      final isSameTrack = _currentMusicAsset == assetPath;
      if (isSameTrack && _musicPlayer.playing) {
        return;
      }
      if (isSameTrack &&
          _musicPlayer.processingState != ProcessingState.idle &&
          !_musicPlayer.playing) {
        await _musicPlayer.play();
        _pendingMusicRetry = false;
        return;
      }
      await _musicPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.setAsset(assetPath);
      _currentMusicAsset = assetPath;
      await _musicPlayer.play();
      _pendingMusicRetry = false;
    } catch (e) {
      _pendingMusicRetry = true;
      debugPrint('AudioService.playMusic failed: $e');
    }
  }

  /// Web tarayıcı politikası nedeniyle ilk play başarısız olduysa, kullanıcı
  /// etkileşiminden sonra tekrar dene.
  Future<void> retryPendingMusic() async {
    if (!_musicEnabled || _pausedByLifecycle) return;
    if (!_pendingMusicRetry && _menuMusicActive && !_musicPlayer.playing) {
      await _resumeMenuMusic();
      return;
    }
    if (!_pendingMusicRetry) return;
    final asset = _currentMusicAsset ?? menuLoopAsset;
    _pendingMusicRetry = false;
    await playMusic(asset, loop: true);
  }

  /// Menü müziğini yalnızca gerektiğinde başlatır (rota senkronu için).
  Future<void> ensureMenuMusic() async {
    _menuMusicActive = true;
    if (!_musicEnabled || _pausedByLifecycle) return;
    if (_musicPlayer.playing && _currentMusicAsset == menuLoopAsset) return;
    await playMusic(menuLoopAsset, loop: true);
  }

  Future<void> playMenuLoop() => ensureMenuMusic();

  Future<void> stopMusic() async {
    _menuMusicActive = false;
    _pendingMusicRetry = false;
    _currentMusicAsset = null;
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('AudioService.stopMusic failed: $e');
    }
  }

  /// Uygulama arka plana / başka sekmeye geçince tüm sesleri duraklat.
  Future<void> pauseForLifecycle() async {
    if (_pausedByLifecycle) return;
    _pausedByLifecycle = true;
    try {
      if (_menuMusicActive &&
          _currentMusicAsset != null &&
          _musicPlayer.processingState != ProcessingState.idle) {
        await _musicPlayer.pause();
      }
      await _pauseCountdownForLifecycle();
      await _sfxPlayer.stop();
    } catch (e) {
      debugPrint('AudioService.pauseForLifecycle failed: $e');
    }
  }

  /// Ön plana dönünce menü müziğini kaldığı yerden devam ettir.
  Future<void> resumeFromLifecycle() async {
    if (!_pausedByLifecycle) return;
    _pausedByLifecycle = false;
    if (_musicEnabled && _menuMusicActive) {
      await _resumeMenuMusic();
    }
    if (_pendingMusicRetry) {
      await retryPendingMusic();
    }
    await _resumeCountdownAfterLifecycle();
  }

  Future<void> _resumeMenuMusic() async {
    try {
      if (_currentMusicAsset != null &&
          _musicPlayer.processingState != ProcessingState.idle) {
        await _musicPlayer.play();
        _pendingMusicRetry = false;
        return;
      }
      await playMenuLoop();
    } catch (e) {
      _pendingMusicRetry = true;
      debugPrint('AudioService._resumeMenuMusic failed: $e');
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    if (!enabled) {
      await _sfxPlayer.stop();
      await stopCountdown();
    }
    await _persistPreferences();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      _pendingMusicRetry = false;
      try {
        await _musicPlayer.stop();
      } catch (e) {
        debugPrint('AudioService.setMusicEnabled stop failed: $e');
      }
      await _persistPreferences();
      return;
    }
    await _persistPreferences();
    if (_menuMusicActive && !_pausedByLifecycle) {
      await playMenuLoop();
    }
  }

  /// Uygulama kapanırken tüm sesleri kes.
  Future<void> stopAll() async {
    _menuMusicActive = false;
    _countdownLoopActive = false;
    _pendingMusicRetry = false;
    _currentMusicAsset = null;
    _pausedByLifecycle = false;
    try {
      await Future.wait([
        _musicPlayer.stop(),
        _sfxPlayer.stop(),
        _countdownPlayer.stop(),
      ]);
    } catch (e) {
      debugPrint('AudioService.stopAll failed: $e');
    }
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0, 1);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _countdownPlayer.setVolume(_sfxVolume);
    await _persistPreferences();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0, 1);
    await _musicPlayer.setVolume(_musicVolume);
    await _persistPreferences();
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _countdownPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
