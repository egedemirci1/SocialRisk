import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/widgets/voting/voting_panel.dart';

void main() {
  group('VotingPanel', () {
    testWidgets('renders three vote buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) {},
            ),
          ),
        ),
      );

      expect(find.text('PERFORMANS NASILDI?'), findsOneWidget);

      expect(find.text('BEĞEN'), findsOneWidget);
      expect(find.text('KARARSIZ'), findsOneWidget);
      expect(find.text('BEĞENME'), findsOneWidget);
    });

    testWidgets('calls onVote with "like" when like tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('BEĞEN'));
      await tester.pumpAndSettle();
      expect(votedValue, 'like');
    });

    testWidgets('calls onVote with "neutral" when kararsiz tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('KARARSIZ'));
      await tester.pumpAndSettle();
      expect(votedValue, 'neutral');
    });

    testWidgets('calls onVote with "dislike" when begenme tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('BEĞENME'));
      await tester.pumpAndSettle();
      expect(votedValue, 'dislike');
    });

    testWidgets('only allows one vote (second tap ignored)', (tester) async {
      int voteCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) => voteCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('BEĞEN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BEĞENME'));
      await tester.pumpAndSettle();
      expect(voteCount, 1);
    });

    testWidgets('after voting, other buttons are disabled and do not trigger onVote', (tester) async {
      int voteCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) => voteCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('BEĞEN'));
      await tester.pumpAndSettle();
      expect(voteCount, 1);

      await tester.tap(find.text('KARARSIZ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BEĞENME'));
      await tester.pumpAndSettle();
      expect(voteCount, 1);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v, {bool timedOut = false}) {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
