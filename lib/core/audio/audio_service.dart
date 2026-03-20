import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum AppSfx {
  buttonClick('assets/audio/sfx/button-click.mp3'),
  uiTapGeneric('assets/audio/sfx/ui_tap_generic.mp3'),
  uiSuccess('assets/audio/sfx/success.mp3'),
  uiError('assets/audio/sfx/failed.mp3'),
  lobbyGameStart('assets/audio/sfx/lobby_game_start.mp3'),
  taskCardReveal('assets/audio/sfx/task_card_reveal.mp3'),
  wheelSpinStart('assets/audio/sfx/wheel-spin.mp3'),
  wheelSpinStop('assets/audio/sfx/wheel_spin_stop.mp3'),
  /// Oy butonları — hepsi `button-click` ile aynı dosya.
  voteLike('assets/audio/sfx/button-click.mp3'),
  voteNeutral('assets/audio/sfx/button-click.mp3'),
  voteDislike('assets/audio/sfx/button-click.mp3'),
  voteResultLike('assets/audio/sfx/success.mp3'),
  voteResultNeutral('assets/audio/sfx/success.mp3'),
  voteResultDislike('assets/audio/sfx/failed.mp3'),
  roundResultShow('assets/audio/sfx/round_result_show.mp3'),
  roundNextTurn('assets/audio/sfx/round_next_turn.mp3'),
  gameOverFanfare('assets/audio/sfx/game_over_fanfare.mp3'),
  waitingTurnChime('assets/audio/sfx/waiting_turn_chime.mp3'),
  difficultyConfirm('assets/audio/sfx/difficulty_confirm.mp3'),
  /// Oylama vb. geri sayım (loop; `stopCountdown` ile kesilir).
  countdown('assets/audio/sfx/countdown.mp3'),
  performingTimerWarning('assets/audio/sfx/performing_timer_warning.mp3'),
  performingTimerEnd('assets/audio/sfx/performing_timer_end.mp3');

  const AppSfx(this.assetPath);
  final String assetPath;
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
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

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.9;
  double _musicVolume = 0.35;
  String? _currentMusicAsset;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;

  Future<void> playSfx(AppSfx sfx, {double? volume}) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.setVolume(volume ?? _sfxVolume);
      await _sfxPlayer.setAsset(sfx.assetPath);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (e) {
      // Asset dosyaları aşamalı ekleneceği için sessiz fail.
      debugPrint('AudioService.playSfx failed: $e');
    }
  }

  /// Geri sayım sesi (loop). Oy / süre bitince [stopCountdown] çağır.
  Future<void> startCountdownLoop({double? volume}) async {
    if (!_sfxEnabled) return;
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
    try {
      await _countdownPlayer.stop();
    } catch (e) {
      debugPrint('AudioService.stopCountdown failed: $e');
    }
  }

  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!_musicEnabled) return;
    try {
      final isSameTrack = _currentMusicAsset == assetPath;
      if (isSameTrack && _musicPlayer.playing) {
        return;
      }
      await _musicPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.setAsset(assetPath);
      _currentMusicAsset = assetPath;
      await _musicPlayer.play();
    } catch (e) {
      debugPrint('AudioService.playMusic failed: $e');
    }
  }

  Future<void> playMenuLoop() => playMusic(menuLoopAsset, loop: true);

  Future<void> stopMusic() async {
    _currentMusicAsset = null;
    await _musicPlayer.stop();
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (!enabled) {
      await _musicPlayer.stop();
      return;
    }
    if (_currentMusicAsset != null && !_musicPlayer.playing) {
      await _musicPlayer.play();
    }
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0, 1);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _countdownPlayer.setVolume(_sfxVolume);
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0, 1);
    await _musicPlayer.setVolume(_musicVolume);
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _countdownPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
