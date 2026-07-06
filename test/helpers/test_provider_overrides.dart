import 'package:mocktail/mocktail.dart';
import 'package:riverpod/misc.dart';
import 'package:social_risk/core/audio/audio_service.dart';
import 'package:social_risk/core/providers/shared_prefs_provider.dart';
import 'package:social_risk/features/premium/providers/premium_provider.dart';

import 'test_shared_preferences.dart';
import 'widget_test_app.dart' show MockPremiumPurchaseService, ensureTestMocks;

class MockAudioService extends Mock implements AudioService {}

bool _testFallbacksRegistered = false;

void _ensureTestFallbacks() {
  if (_testFallbacksRegistered) return;
  try {
    registerFallbackValue(AppSfx.buttonClick);
  } catch (_) {
    // Başka test dosyası zaten kaydettiyse yoksay.
  }
  _testFallbacksRegistered = true;
}

/// SharedPreferences override for ProviderContainer / ProviderScope tests.
get sharedPreferencesTestOverride =>
    sharedPreferencesProvider.overrideWithValue(testSharedPreferences);

List<Override> unitTestOverrides({
  List<Override> extra = const [],
  MockAudioService? audioService,
}) {
  ensureTestMocks();
  _ensureTestFallbacks();
  final mockAudio = audioService ?? MockAudioService();
  when(() => mockAudio.pauseForLifecycle()).thenAnswer((_) async {});
  when(() => mockAudio.resumeFromLifecycle()).thenAnswer((_) async {});
  when(() => mockAudio.stopAll()).thenAnswer((_) async {});
  when(() => mockAudio.startCountdownLoop()).thenAnswer((_) async {});
  when(() => mockAudio.stopCountdown()).thenAnswer((_) async {});
  when(() => mockAudio.playSfx(any())).thenAnswer((_) async {});

  return [
    sharedPreferencesTestOverride,
    premiumPurchaseServiceProvider.overrideWithValue(
      MockPremiumPurchaseService(),
    ),
    audioServiceProvider.overrideWithValue(mockAudio),
    ...extra,
  ];
}
