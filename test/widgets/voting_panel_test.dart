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
              onVote: (_) {},
            ),
          ),
        ),
      );

      // Panel title
      expect(find.text('Nasıl buldun?'), findsOneWidget);

      // Three vote buttons
      expect(find.text('Beğendim'), findsOneWidget);
      expect(find.text('Nötr'), findsOneWidget);
      expect(find.text('Beğenmedim'), findsOneWidget);
    });

    testWidgets('calls onVote with "like" when like tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('👍'));
      expect(votedValue, 'like');
    });

    testWidgets('calls onVote with "neutral" when nötr tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('😐'));
      expect(votedValue, 'neutral');
    });

    testWidgets('calls onVote with "dislike" when dislike tapped', (tester) async {
      String? votedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (v) => votedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('👎'));
      expect(votedValue, 'dislike');
    });

    testWidgets('only allows one vote (second tap ignored)', (tester) async {
      int voteCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (_) => voteCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('👍'));
      await tester.tap(find.text('👎'));
      expect(voteCount, 1); // only first vote counts
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VotingPanel(
              onVote: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
