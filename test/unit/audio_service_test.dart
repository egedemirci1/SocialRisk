import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/audio/audio_service.dart';
import '../helpers/test_shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService', () {
    late AudioService service;
    late TestSharedPreferences prefs;

    setUp(() {
      service = AudioService();
      prefs = TestSharedPreferences();
      service.loadPreferences(prefs);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('loadPreferences varsayılan değerleri yükler', () {
      expect(service.sfxEnabled, isTrue);
      expect(service.musicEnabled, isTrue);
      expect(service.sfxVolume, closeTo(0.9, 0.001));
      expect(service.musicVolume, closeTo(0.35, 0.001));
    });

    test('setSfxEnabled false yapınca sfxEnabled güncellenir', () async {
      await service.setSfxEnabled(false);
      expect(service.sfxEnabled, isFalse);
      expect(prefs.getBool('audio_sfx_enabled'), isFalse);
    });

    test('setMusicEnabled false yapınca musicEnabled güncellenir', () async {
      await service.setMusicEnabled(false);
      expect(service.musicEnabled, isFalse);
      expect(prefs.getBool('audio_music_enabled'), isFalse);
    });

    test('setSfxVolume ve setMusicVolume tercihleri kaydeder', () async {
      await service.setSfxVolume(0.5);
      await service.setMusicVolume(0.2);

      expect(service.sfxVolume, 0.5);
      expect(service.musicVolume, 0.2);
      expect(prefs.getDouble('audio_sfx_volume'), 0.5);
      expect(prefs.getDouble('audio_music_volume'), 0.2);
    });

    test('pauseForLifecycle ve resumeFromLifecycle hata fırlatmaz', () async {
      await service.pauseForLifecycle();
      await service.resumeFromLifecycle();
    });

    test('stopAll ve stopCountdown hata fırlatmaz', () async {
      await service.stopCountdown();
      await service.stopAll();
    });
  });
}
