// TODO: Fix VotingPanel timer issues
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_risk/core/audio/audio_service.dart';
// import 'package:social_risk/shared/widgets/voting/voting_panel.dart';

// class _FakeAudioService extends AudioService {
//   @override
//   Future<void> playSfx(AppSfx sfx, {double? volume}) async {}

//   @override
//   Future<void> startCountdownLoop({double? volume}) async {}

//   @override
//   Future<void> stopCountdown() async {}

//   @override
//   Future<void> dispose() async {}
// }

// void main() {
//   group('VotingPanel', () {
//     testWidgets('renders voting buttons', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             audioServiceProvider.overrideWithValue(_FakeAudioService()),
//           ],
//           child: MaterialApp(
//             home: Scaffold(
//               body: VotingPanel(
//                 onVote: (vote, {bool timedOut = false}) {},
//                 timeLimit: const Duration(seconds: 1),
//               ),
//             ),
//           ),
//         ),
//       );
      
//       await tester.pumpAndSettle();
      
//       // Check that voting buttons are present
//       expect(find.text('PERFORMANS NASILDI?'), findsOneWidget);
//       expect(find.text('BEĞEN'), findsOneWidget);
//       expect(find.text('KARARSIZ'), findsOneWidget);
//       expect(find.text('BEĞENME'), findsOneWidget);
//     });
//   });
// }
