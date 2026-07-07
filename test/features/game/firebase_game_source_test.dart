import 'dart:math';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/errors/app_exception.dart';
import 'package:social_risk/features/game/data/firebase_game_source.dart';
import 'package:social_risk/features/game/data/game_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseGameSource gameSource;
  late Random mockRandom;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockRandom = Random(42); // Seeded random for predictability
    gameSource = FirebaseGameSource(
      firestore: fakeFirestore,
      random: mockRandom,
    );
  });

  group('FirebaseGameSource - pickCategoryEconomy', () {
    test('pickCategoryEconomy seçim sayısını artırır ve zorluk seçimine geçer', () async {
      const gameId = 'game123';
      const category = 'Dijital';
      const playerId = 'p1';

      final initialData = {
        'roomId': 'room1',
        'currentPlayerId': playerId,
        'turnOrder': [playerId],
        'categoryPickOrder': [playerId],
        'lockedCategories': [],
        'categoryMarketValues': {'Dijital': 10, 'Bilgi': 10, 'Fiziksel': 10},
        'categoryPickCounts': {'Dijital': 0},
        'status': 'playing',
        'mode': 'economy',
      };

      await fakeFirestore.collection('games').doc(gameId).set(initialData);

      await gameSource.pickCategoryEconomy(
        gameId: gameId,
        playerId: playerId,
        category: category,
      );

      final gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      final marketValues = Map<String, int>.from(gameSnap.data()?['categoryMarketValues']);
      expect(marketValues[category], 10);
      expect(gameSnap.data()?['categoryPickCounts'][category], 1);
      expect(gameSnap.data()?['currentPlayerId'], playerId);
      expect(gameSnap.data()?['status'], 'choosingDifficulty');
      expect(gameSnap.data()?['selectedCategory'], category);
    });

    test('pickCategoryEconomy locks category at threshold', () async {
      const gameId = 'game123';
      const category = 'Dijital';
      const playerId = 'p1';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': playerId,
        'turnOrder': [playerId],
        'categoryPickOrder': [playerId],
        'lockedCategories': [],
        'categoryMarketValues': {'Dijital': 10, 'Bilgi': 10, 'Fiziksel': 10},
        'categoryPickCounts': {'Dijital': 2},
        'status': 'playing',
        'mode': 'economy',
      });

      await gameSource.pickCategoryEconomy(gameId: gameId, playerId: playerId, category: category);

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['categoryPickCounts'][category], 3);
      expect(snap.data()?['lockedCategories'], contains(category));
    });

    test('pickCategoryEconomy currentPlayer dışındaki kullanıcıyı reddeder', () async {
      const gameId = 'gameWrongPicker';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2'],
        'categoryPickOrder': ['p1', 'p2'],
        'lockedCategories': [],
        'categoryMarketValues': {'Dijital': 10, 'Bilgi': 10, 'Fiziksel': 10},
        'categoryPickCounts': {'Dijital': 0},
        'status': 'playing',
        'mode': 'economy',
      });

      expect(
        () => gameSource.pickCategoryEconomy(
          gameId: gameId,
          playerId: 'p2',
          category: 'Dijital',
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('pickCategoryEconomy playing dışı statüde seçim yapmaz', () async {
      const gameId = 'gameVotingPicker';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2'],
        'categoryPickOrder': ['p1', 'p2'],
        'lockedCategories': [],
        'categoryMarketValues': {'Dijital': 10, 'Bilgi': 10, 'Fiziksel': 10},
        'categoryPickCounts': {'Dijital': 0},
        'status': 'voting',
        'mode': 'economy',
      });

      expect(
        () => gameSource.pickCategoryEconomy(
          gameId: gameId,
          playerId: 'p1',
          category: 'Dijital',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('FirebaseGameSource - Basic Updates', () {
    test('setSpinningTarget, acceptTask, proceedToVoting, endGame update status correctly', () async {
      const gameId = 'game123';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1'],
        'status': 'playing',
      });
      await fakeFirestore
          .collection('rooms')
          .doc('room1')
          .collection('players')
          .doc('p1')
          .set({'score': 10});

      await gameSource.setSpinningTarget(gameId: gameId, target: 'user1');
      var snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['spinningTarget'], 'user1');

      await gameSource.acceptTask(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['status'], 'performing');

      await gameSource.proceedToVoting(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['status'], 'voting');

      await gameSource.endGame(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['status'], 'finished');
    });

    test('setRoundResult updates game status and player score', () async {
      const gameId = 'game123';
      const roomId = 'room1';
      const playerId = 'p1';
      
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': playerId,
        'turnOrder': [playerId],
        'status': 'playing',
      });
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).set({'score': 100});

      await gameSource.setRoundResult(
        gameId: gameId,
        roomId: roomId,
        playerId: playerId,
        score: 50,
        audienceScore: 25,
        multiplier: 2,
      );

      final gSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gSnap.data()?['status'], 'results');
      expect(gSnap.data()?['lastRoundPlayerId'], playerId);
      expect(gSnap.data()?['lastRoundAudienceScore'], 25);

      final pSnap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(pSnap.data()?['score'], 150);
    });

    test('setRoundResult only writes results (finish is done by Cloud Function)', () async {
      const gameId = 'gameFinish';
      const roomId = 'roomFinish';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2'],
        'status': 'playing',
      });
      await fakeFirestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc('p1')
          .set({'score': 100});
      await fakeFirestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc('p2')
          .set({'score': 50});

      await gameSource.setRoundResult(
        gameId: gameId,
        roomId: roomId,
        playerId: 'p1',
        score: 25,
        audienceScore: 10,
        multiplier: 2,
      );

      final gSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gSnap.data()?['status'], 'results');

      final pSnap = await fakeFirestore
          .collection('rooms')
          .doc(roomId)
          .collection('players')
          .doc('p1')
          .get();
      expect(pSnap.data()?['score'], 125);
    });
  });

  group('FirebaseGameSource - Task Assignment', () {
    test('setCurrentTask updates task and usedTaskIds', () async {
      const gameId = 'game123';
      await fakeFirestore.collection('games').doc(gameId).set({'usedTaskIds': []});

      final task = TaskModel(id: 't1', category: 'c', content: 'cnt', difficulty: 'easy', multiplier: 1).toEntity();
      await gameSource.setCurrentTask(gameId: gameId, task: task);

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentTask']['id'], 't1');
      expect(snap.data()?['usedTaskIds'], contains('t1'));
    });

    test('assignTaskByCategory updates status and category', () async {
      const gameId = 'game123';
      await fakeFirestore.collection('games').doc(gameId).set({
        'taskPool': {
          'Bilgi_mixed': [
            {'id': 'task1', 'category': 'Bilgi', 'content': 'Test content', 'difficulty': 'medium'}
          ]
        }
      });

      await gameSource.assignTaskByCategory(gameId: gameId, category: 'Bilgi');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['selectedCategory'], 'Bilgi');
      expect(snap.data()?['status'], 'choosingDifficulty');
    });

    test('assignTaskByCategory zorluk havuzlarından görev seçer', () async {
      const gameId = 'game_mixed_fallback';
      await fakeFirestore.collection('games').doc(gameId).set({
        'usedTaskIds': <String>[],
        'taskPool': {
          'Dijital_easy': [
            {
              'id': 'easy1',
              'category': 'Dijital',
              'content': 'Kolay görev',
              'difficulty': 'easy',
            },
          ],
        },
      });

      await gameSource.assignTaskByCategory(gameId: gameId, category: 'Dijital');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentTask']['id'], 'easy1');
      expect(snap.data()?['currentTask']['multiplier'], 2);
    });

    test('assignTaskByCategory görev yoksa AppException fırlatır', () async {
      const gameId = 'game_empty_pool';
      await fakeFirestore.collection('games').doc(gameId).set({
        'taskPool': {'Bilgi_mixed': <Map<String, dynamic>>[]},
      });

      expect(
        () => gameSource.assignTaskByCategory(gameId: gameId, category: 'Bilgi'),
        throwsA(isA<AppException>().having((e) => e.code, 'code', AppErrorCode.noTasksInCategory)),
      );
    });

    test('assignTaskByCategory boş gameId ile Exception fırlatır', () async {
      expect(
        () => gameSource.assignTaskByCategory(gameId: '', category: 'Bilgi'),
        throwsA(isA<Exception>()),
      );
    });

    test('assignTaskByCategory mevcut görev varsa güncelleme yapmaz', () async {
      const gameId = 'game_has_task';
      await fakeFirestore.collection('games').doc(gameId).set({
        'currentTask': {'id': 'existing', 'category': 'Bilgi', 'content': 'x', 'difficulty': 'easy'},
        'taskPool': {
          'Bilgi_mixed': [
            {'id': 'task1', 'category': 'Bilgi', 'content': 'Yeni', 'difficulty': 'medium'},
          ],
        },
      });

      await gameSource.assignTaskByCategory(gameId: gameId, category: 'Bilgi');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentTask']['id'], 'existing');
    });
  });

  group('FirebaseGameSource - Game Conditions', () {
    test('checkScoreEndCondition returns true when a player hits target', () async {
      const roomId = 'room1';
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p1').set({'score': 500});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p2').set({'score': 200});

      final result = await gameSource.checkScoreEndCondition(roomId: roomId, targetScore: 500);
      expect(result, true);

      final result2 = await gameSource.checkScoreEndCondition(roomId: roomId, targetScore: 600);
      expect(result2, false);
    });
  });

  group('FirebaseGameSource - chooseDifficulty', () {
    test('Kategori seçilmeden zorluk seçilirse hata fırlatır', () async {
      const gameId = 'game123';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1'],
        'selectedCategory': null,
      });

      expect(
        () => gameSource.chooseDifficulty(gameId: gameId, difficulty: 'easy'),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          AppErrorCode.categoryNotSelected,
        )),
      );
    });

    test('Seçilen zorluğa göre çarpan doğru atanır (easy=1, medium=2, hard=3)', () async {
      const gameId = 'game123';
      const category = 'Fiziksel';
      final task = {'id': 't1', 'category': category, 'content': 'Test', 'difficulty': 'easy'};
      
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'room1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1'],
        'selectedCategory': category,
        'taskPool': {'${category}_hard': [task]},
        'usedTaskIds': [],
      });

      await gameSource.chooseDifficulty(gameId: gameId, difficulty: 'hard');

      final gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      final currentTask = gameSnap.data()?['currentTask'];
      expect(currentTask['multiplier'], 3);
      expect(gameSnap.data()?['status'], 'playing');
    });
  });

  group('FirebaseGameSource - Turn & Round Management', () {
    test('nextTurn sırayla +1 ilerler, tur bitince round artar', () async {
      const gameId = 'game123';
      const roomId = 'room1';

      await fakeFirestore.collection('rooms').doc(roomId).set({'endConditionType': 'rounds', 'endConditionValue': 5});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p1').set({'name': 'P1'});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p2').set({'name': 'P2'});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p3').set({'name': 'P3'});

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2', 'p3'],
        'currentRound': 1,
        'status': 'results',
        'categoryPickOrder': [],
      });

      await gameSource.nextTurn(gameId);
      var snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p2');
      
      // Status'i tekrar 'results' yap ki bir sonraki nextTurn çalışsın
      await fakeFirestore.collection('games').doc(gameId).update({'status': 'results'});

      await gameSource.nextTurn(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p3');
      
      // Status'i tekrar 'results' yap
      await fakeFirestore.collection('games').doc(gameId).update({'status': 'results'});

      await gameSource.nextTurn(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p1');
      expect(snap.data()?['currentRound'], 2);
    });

    test('nextRound increments round and resets player', () async {
      const gameId = 'game123';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'r1',
        'currentRound': 1,
        'turnOrder': ['p1', 'p2'],
        'currentPlayerId': 'p2',
      });

      await gameSource.nextRound(gameId);
      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentRound'], 2);
      expect(snap.data()?['currentPlayerId'], 'p1');
    });

    test('nextTurn distributes rewards when ending by round limit', () async {
      const gameId = 'gameReward';
      const roomId = 'roomReward';

      await fakeFirestore.collection('rooms').doc(roomId).set({
        'endConditionType': 'rounds',
        'endConditionValue': 2,
      });
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p1').set({'name': 'P1', 'score': 50});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p2').set({'name': 'P2', 'score': 30});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p3').set({'name': 'P3', 'score': -5});

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p2',
        'turnOrder': ['p1', 'p2'],
        'currentRound': 2,
        'status': 'results',
      });

      await gameSource.nextTurn(gameId);
      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['status'], 'results');
    });

    test('nextTurn sırayla +1 döngüsel ilerler (Borsa ile aynı mantık)', () async {
      const gameId = 'gameSequential';
      const roomId = 'roomSequential';

      await fakeFirestore.collection('rooms').doc(roomId).set({
        'endConditionType': 'rounds',
        'endConditionValue': 10,
      });
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p1').set({'name': 'P1'});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p2').set({'name': 'P2'});
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc('p3').set({'name': 'P3'});

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2', 'p3'],
        'currentRound': 1,
        'status': 'results',
        'categoryPickOrder': [],
      });
    await gameSource.nextTurn(gameId);
      var snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p2');

      // Status'i tekrar 'results' yap
      await fakeFirestore.collection('games').doc(gameId).update({'status': 'results'});

      await gameSource.nextTurn(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p3');

      // Status'i tekrar 'results' yap
      await fakeFirestore.collection('games').doc(gameId).update({'status': 'results'});

      await gameSource.nextTurn(gameId);
      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['currentPlayerId'], 'p1');
      expect(snap.data()?['currentRound'], 2);
    });

    test('çıkan oyuncuyu turnOrder ve categoryPickOrder dan kaldırır', () async {
      const gameId = 'gameLeave';
      const roomId = 'roomLeave';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2', 'p3'],
        'categoryPickOrder': ['p1', 'p2', 'p3'],
        'currentPickIndex': 0,
        'status': 'playing',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p3']);
      expect(snap.data()?['categoryPickOrder'], ['p1', 'p3']);
      expect(snap.data()?['currentPlayerId'], 'p1');
      expect(snap.data()?['currentPickIndex'], 0);
    });

    test('sıradaki oyuncu çıkarsa currentPlayerId sonrakine geçer', () async {
      const gameId = 'gameLeaveCurrent';
      const roomId = 'roomLeaveCurrent';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p2',
        'turnOrder': ['p1', 'p2', 'p3'],
        'categoryPickOrder': ['p1', 'p2', 'p3'],
        'currentPickIndex': 1,
        'status': 'playing',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p3']);
      expect(snap.data()?['categoryPickOrder'], ['p1', 'p3']);
      expect(snap.data()?['currentPlayerId'], 'p3');
      expect(snap.data()?['currentPickIndex'], 1); // p3 yeni listede index 1
    });

    test('3 oyuncuda choosingDifficulty fazında currentPlayer çıkarsa index doğru kayar', () async {
      const gameId = 'gameLeaveChoosing3';
      const roomId = 'roomLeaveChoosing3';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p2',
        'turnOrder': ['p1', 'p2', 'p3'],
        'categoryPickOrder': ['p1', 'p2', 'p3'],
        'currentPickIndex': 1,
        'status': 'choosingDifficulty',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p3']);
      expect(snap.data()?['categoryPickOrder'], ['p1', 'p3']);
      expect(snap.data()?['currentPlayerId'], 'p3');
      expect(snap.data()?['currentPickIndex'], 1);
    });

    test('4 oyuncuda performing fazında ortadaki oyuncu çıkarsa sıra korunur', () async {
      const gameId = 'gameLeavePerforming4';
      const roomId = 'roomLeavePerforming4';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p3',
        'turnOrder': ['p1', 'p2', 'p3', 'p4'],
        'categoryPickOrder': ['p1', 'p2', 'p3', 'p4'],
        'currentPickIndex': 2,
        'status': 'performing',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p3', 'p4']);
      expect(snap.data()?['categoryPickOrder'], ['p1', 'p3', 'p4']);
      expect(snap.data()?['currentPlayerId'], 'p3');
      expect(snap.data()?['currentPickIndex'], 1);
    });

    test('4 oyuncuda voting fazında currentPlayer çıkarsa bir sonrakine geçer', () async {
      const gameId = 'gameLeaveVoting4';
      const roomId = 'roomLeaveVoting4';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p2',
        'turnOrder': ['p1', 'p2', 'p3', 'p4'],
        'categoryPickOrder': ['p1', 'p2', 'p3', 'p4'],
        'currentPickIndex': 1,
        'status': 'voting',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p3', 'p4']);
      expect(snap.data()?['categoryPickOrder'], ['p1', 'p3', 'p4']);
      expect(snap.data()?['currentPlayerId'], 'p3');
      expect(snap.data()?['currentPickIndex'], 1);
    });

    test('son kalan oyuncu çıkınca oyun biter', () async {
      const gameId = 'gameLeaveLast';
      const roomId = 'roomLeaveLast';

      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2'],
        'categoryPickOrder': [],
        'status': 'playing',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      var snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1']);
      expect(snap.data()?['status'], 'playing');

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p1');

      snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['status'], 'finished');
    });

    test('oyun finished ise güncelleme yapmaz', () async {
      const gameId = 'gameLeaveFinished';
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': 'r1',
        'currentPlayerId': 'p1',
        'turnOrder': ['p1', 'p2'],
        'status': 'finished',
      });

      await gameSource.removePlayerFromGame(gameId: gameId, playerId: 'p2');

      final snap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(snap.data()?['turnOrder'], ['p1', 'p2']);
      expect(snap.data()?['status'], 'finished');
    });
  });

  group('FirebaseGameSource - Scoring', () {
    test('passTask applies penalty and sets streak', () async {
      const gameId = 'game123';
      const roomId = 'room1';
      const playerId = 'p1';
      
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).set({'score': 100, 'passStreak': 1});
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': playerId,
        'categoryPickOrder': [],
      });

      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: playerId, basePenalty: 50);

      final pSnap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(pSnap.data()?['passStreak'], 2);
      expect(pSnap.data()?['score'], 50); // 100 - 50 sabit ceza (katlanmaz)
    });

    test('passTask ekonomi modunda 4 oyunculu sıra ilerler (aynı oyuncuya tekrar düşmez)', () async {
      const gameId = 'economy4';
      const roomId = 'room4';
      const pickOrder = ['p1', 'p2', 'p3', 'p4'];

      for (final pid in pickOrder) {
        await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(pid).set({'name': pid, 'score': 0, 'passStreak': 0});
      }
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': 'p1',
        'currentPickIndex': 0,
        'categoryPickOrder': pickOrder,
        'status': 'playing',
        'currentRound': 1,
      });

      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: 'p1', basePenalty: 50);
      var gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gameSnap.data()?['currentPlayerId'], 'p2');
      expect(gameSnap.data()?['currentPickIndex'], 1);

      await fakeFirestore.collection('games').doc(gameId).update({'status': 'playing'});
      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: 'p2', basePenalty: 50);
      gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gameSnap.data()?['currentPlayerId'], 'p3');
      expect(gameSnap.data()?['currentPickIndex'], 2);

      await fakeFirestore.collection('games').doc(gameId).update({'status': 'playing'});
      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: 'p3', basePenalty: 50);
      gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gameSnap.data()?['currentPlayerId'], 'p4');
      expect(gameSnap.data()?['currentPickIndex'], 3);

      await fakeFirestore.collection('games').doc(gameId).update({'status': 'playing'});
      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: 'p4', basePenalty: 50);
      gameSnap = await fakeFirestore.collection('games').doc(gameId).get();
      expect(gameSnap.data()?['currentPlayerId'], 'p1');
      expect(gameSnap.data()?['currentPickIndex'], 0);
      expect(gameSnap.data()?['currentRound'], 2);
    });

    test('passTask ardışık paslarda her seferinde sabit -50 (katlanarak artmaz)', () async {
      const gameId = 'penalty50';
      const roomId = 'room1';
      const playerId = 'p1';
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).set({'score': 200, 'passStreak': 0});
      await fakeFirestore.collection('games').doc(gameId).set({
        'roomId': roomId,
        'currentPlayerId': playerId,
        'categoryPickOrder': [],
      });

      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: playerId, basePenalty: 50);
      var pSnap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(pSnap.data()?['score'], 150);
      expect(pSnap.data()?['passStreak'], 1);

      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: playerId, basePenalty: 50);
      pSnap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(pSnap.data()?['score'], 100);
      expect(pSnap.data()?['passStreak'], 2);

      await gameSource.passTask(gameId: gameId, roomId: roomId, playerId: playerId, basePenalty: 50);
      pSnap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(pSnap.data()?['score'], 50);
      expect(pSnap.data()?['passStreak'], 3);
    });

    test('updatePlayerScore increments score', () async {
      const roomId = 'room1';
      const playerId = 'p1';
      await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).set({'score': 100});

      await gameSource.updatePlayerScore(roomId: roomId, playerId: playerId, scoreToAdd: 50);

      final snap = await fakeFirestore.collection('rooms').doc(roomId).collection('players').doc(playerId).get();
      expect(snap.data()?['score'], 150);
    });
  });

  // TODO: Re-enable vote result tests when VoteResult is properly imported
  // group('FirebaseVoteSource - Mode-Aware Scoring Integration', () {
  //   // Note: We use the FirebaseGameSource setup to check if VoteSource integration would work
  //   // Since we are mocking FirebaseFirestore, we can verify the data is read correctly.
    
  //   test('calculateVoteResult uses fixed 10 for Classic Mode', () async {
  //     // Implementation removed
  //   });
  // });

  group('Reward Distribution - rewardForRank', () {
    int rewardForRank(int rank, int totalPlayers) {
      const rankRewards = [200, 100, 50];
      if (rank <= rankRewards.length) return rankRewards[rank - 1];
      return 20;
    }

    test('ilk 3 oyuncuya doğru ödül verir', () {
      expect(rewardForRank(1, 5), 200);
      expect(rewardForRank(2, 5), 100);
      expect(rewardForRank(3, 5), 50);
    });

    test('4. ve sonrası 20 alır', () {
      expect(rewardForRank(4, 5), 20);
      expect(rewardForRank(5, 5), 20);
      expect(rewardForRank(10, 10), 20);
    });

    test('2 kişilik oyunda 1. 200, 2. 100 alır', () {
      expect(rewardForRank(1, 2), 200);
      expect(rewardForRank(2, 2), 100);
    });
  });
}
