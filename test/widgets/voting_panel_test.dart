import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/core/audio/audio_service.dart';
import 'package:social_risk/shared/widgets/voting/voting_panel.dart';
import '../helpers/test_provider_overrides.dart';
import '../helpers/widget_test_app.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AppSfx.buttonClick);
  });

  testWidgets('VotingPanel like butonuna tıklanınca onVote tetiklenir', (tester) async {
    final mockAudio = MockAudioService();
    when(() => mockAudio.startCountdownLoop()).thenAnswer((_) async {});
    when(() => mockAudio.stopCountdown()).thenAnswer((_) async {});
    when(() => mockAudio.playSfx(any())).thenAnswer((_) async {});

    String? voted;

    await tester.binding.setSurfaceSize(const Size(600, 900));
    await tester.pumpWidget(
      wrapWithLocalizedApp(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: VotingPanel(
          timeLimit: const Duration(hours: 1),
          onVote: (value, {bool timedOut = false}) => voted = value,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('BEĞEN'));
    await tester.pump();

    expect(voted, 'like');
  });
}
