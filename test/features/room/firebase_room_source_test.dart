import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/game_constants.dart';
import 'package:social_risk/features/admin/data/task_firestore_source.dart';
import 'package:social_risk/features/room/data/firebase_room_source.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('FirebaseRoomSource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseRoomSource roomSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      roomSource = FirebaseRoomSource(
        firestore: fakeFirestore,
        taskSource: TaskFirestoreSource(firestore: fakeFirestore),
      );
    });

    Future<String> createRoomAndGetCode() => roomSource.createRoom(
          hostId: 'host1',
          hostName: 'Host',
          endConditionType: EndConditionType.score,
          endConditionValue: 500,
          visibility: RoomVisibility.open,
          categories: GameConstants.defaultCategoriesConst,
          mode: GameMode.classic,
          useCustomDeck: false,
        );

    test('createRoom creates room and host as first player', () async {
      final roomCode = await createRoomAndGetCode();

      expect(roomCode, isNotEmpty);
      expect(roomCode.length, 6);

      final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
      expect(roomDoc.exists, isTrue);
      expect(roomDoc.data()!['hostId'], 'host1');
      expect(roomDoc.data()!['status'], 'waiting');

      final playersSnap = await fakeFirestore
          .collection('rooms')
          .doc(roomCode)
          .collection('players')
          .get();
      expect(playersSnap.docs.length, 1);
      expect(playersSnap.docs.first.id, 'host1');
      expect(playersSnap.docs.first.data()['displayName'], 'Host');
    });

    test('joinRoom adds player successfully', () async {
      final roomCode = await createRoomAndGetCode();

      await roomSource.joinRoom(
        roomCode: roomCode,
        playerId: 'player2',
        playerName: 'İkinci Oyuncu',
      );

      final playersSnap = await fakeFirestore
          .collection('rooms')
          .doc(roomCode)
          .collection('players')
          .get();
      expect(playersSnap.docs.length, 2);
      final player2Docs = playersSnap.docs.where((d) => d.id == 'player2').toList();
      expect(player2Docs.length, 1);
      expect(player2Docs.first.data()['displayName'], 'İkinci Oyuncu');
    });

    test('joinRoom throws when room does not exist', () async {
      expect(
        () => roomSource.joinRoom(
          roomCode: 'NONEX',
          playerId: 'p1',
          playerName: 'P',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Oda bulunamadı'),
        )),
      );
    });

    test('last player leaves -> room document and related data deleted', () async {
      final roomCode = await createRoomAndGetCode();

      await roomSource.leaveRoom(roomCode: roomCode, playerId: 'host1');

      final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
      expect(roomDoc.exists, isFalse);

      final playersSnap = await fakeFirestore
          .collection('rooms')
          .doc(roomCode)
          .collection('players')
          .get();
      expect(playersSnap.docs.length, 0);
    });

    test('non-host leaves when last player -> room deleted', () async {
      final roomCode = await createRoomAndGetCode();
      await roomSource.joinRoom(
        roomCode: roomCode,
        playerId: 'player2',
        playerName: 'Second',
      );

      await roomSource.leaveRoom(roomCode: roomCode, playerId: 'host1');
      await roomSource.leaveRoom(roomCode: roomCode, playerId: 'player2');

      final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
      expect(roomDoc.exists, isFalse);
    });

    test('leaveRoom when room already deleted does not throw', () async {
      await roomSource.leaveRoom(roomCode: 'MISSING', playerId: 'any');
    });

    test('watchRoom emits null when room does not exist', () async {
      final stream = roomSource.watchRoom('NONEX');
      final values = <dynamic>[];
      final sub = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(values, isNotEmpty);
      expect(values.last, isNull);
      await sub.cancel();
    });

    test('watchRoom emits room entity when room exists', () async {
      final roomCode = await createRoomAndGetCode();

      final stream = roomSource.watchRoom(roomCode);
      final values = <dynamic>[];
      final sub = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(values, isNotEmpty);
      expect(values.last, isNotNull);
      expect(values.last.roomCode, roomCode);
      expect(values.last.players.length, 1);
      await sub.cancel();
    });

    test('watchPlayers emits player list', () async {
      final roomCode = await createRoomAndGetCode();

      final stream = roomSource.watchPlayers(roomCode);
      final values = <List<dynamic>>[];
      final sub = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(values, isNotEmpty);
      expect(values.last.length, 1);
      expect(values.last.first.displayName, 'Host');
      await sub.cancel();
    });

    test('doesRoomExist returns true when room exists', () async {
      final roomCode = await createRoomAndGetCode();
      expect(await roomSource.doesRoomExist(roomCode), isTrue);
    });

    test('doesRoomExist returns false when room does not exist', () async {
      expect(await roomSource.doesRoomExist('NONEX'), isFalse);
    });

    group('startGameInRoom', () {
      test('transaction sonunda games koleksiyonunda döküman oluşur, oda status playing olur, taskPool dolu', () async {
        final roomCode = await createRoomAndGetCode();
        await roomSource.joinRoom(
          roomCode: roomCode,
          playerId: 'player2',
          playerName: 'P2',
        );
        final playerIds = ['host1', 'player2'];

        final gameId = await roomSource.startGameInRoom(
          roomCode: roomCode,
          playerIds: playerIds,
          mode: GameMode.classic,
        );

        expect(gameId, isNotEmpty);

        final gameDoc = await fakeFirestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists, isTrue);
        final gameData = gameDoc.data()!;
        expect(gameData['roomId'], roomCode);
        expect(gameData['status'], 'playing');
        expect(gameData['mode'], 'classic');

        final taskPool = gameData['taskPool'];
        expect(taskPool, isNotNull);
        expect(taskPool, isA<Map<String, dynamic>>());
        final poolMap = taskPool as Map<String, dynamic>;
        expect(poolMap.isNotEmpty, isTrue);
        for (final entry in poolMap.entries) {
          expect(entry.value, isA<List>());
          expect((entry.value as List).isNotEmpty, isTrue);
        }

        final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
        expect(roomDoc.exists, isTrue);
        expect(roomDoc.data()!['status'], 'playing');
        expect(roomDoc.data()!['gameId'], gameId);
      });
    });

    group('joinRoom oda doluluk', () {
      test('oda maxPlayers doluyken joinRoom doğru Exception fırlatır', () async {
        final roomCode = await createRoomAndGetCode();
        for (var i = 2; i <= GameConstants.maxPlayers; i++) {
          await roomSource.joinRoom(
            roomCode: roomCode,
            playerId: 'player$i',
            playerName: 'Oyuncu $i',
          );
        }

        expect(
          () => roomSource.joinRoom(
            roomCode: roomCode,
            playerId: 'extra',
            playerName: 'Fazla',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Oda dolu'),
          )),
        );

        final playersSnap = await fakeFirestore
            .collection('rooms')
            .doc(roomCode)
            .collection('players')
            .get();
        expect(playersSnap.docs.length, GameConstants.maxPlayers);
      });
    });

    group('cleanupZombieRoomsAndGames', () {
      test('24 saatten eski oda ve oyuncuları silinir', () async {
        final oldDate = DateTime.now().subtract(const Duration(hours: 25));
        const roomCode = 'ZOMBIE01';
        await fakeFirestore.collection('rooms').doc(roomCode).set({
          'roomCode': roomCode,
          'hostId': 'h1',
          'mode': 'classic',
          'status': 'waiting',
          'endConditionType': 'score',
          'endConditionValue': 500,
          'visibility': 'open',
          'categories': GameConstants.defaultCategoriesConst,
          'useCustomDeck': false,
          'createdAt': Timestamp.fromDate(oldDate),
        });
        await fakeFirestore
            .collection('rooms')
            .doc(roomCode)
            .collection('players')
            .doc('h1')
            .set({'displayName': 'Host', 'isReady': true});

        await roomSource.cleanupZombieRoomsAndGames();

        final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
        expect(roomDoc.exists, isFalse);
        final playersSnap = await fakeFirestore
            .collection('rooms')
            .doc(roomCode)
            .collection('players')
            .get();
        expect(playersSnap.docs, isEmpty);
      });
    });

    group('durum güncellemeleri', () {
      test('toggleReady Firestore isReady değerini günceller', () async {
        final roomCode = await createRoomAndGetCode();
        await roomSource.joinRoom(
          roomCode: roomCode,
          playerId: 'p2',
          playerName: 'P2',
        );

        await roomSource.toggleReady(
          roomCode: roomCode,
          playerId: 'p2',
          isReady: true,
        );
        var playerDoc = await fakeFirestore
            .collection('rooms')
            .doc(roomCode)
            .collection('players')
            .doc('p2')
            .get();
        expect(playerDoc.data()!['isReady'], true);

        await roomSource.toggleReady(
          roomCode: roomCode,
          playerId: 'p2',
          isReady: false,
        );
        playerDoc = await fakeFirestore
            .collection('rooms')
            .doc(roomCode)
            .collection('players')
            .doc('p2')
            .get();
        expect(playerDoc.data()!['isReady'], false);
      });

      test('toggleVisibility Firestore visibility değerini günceller', () async {
        final roomCode = await createRoomAndGetCode();
        expect(
            (await fakeFirestore.collection('rooms').doc(roomCode).get())
                .data()!['visibility'],
            'open');

        await roomSource.toggleVisibility(
          roomCode: roomCode,
          visibility: RoomVisibility.closed,
        );
        final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
        expect(roomDoc.data()!['visibility'], 'closed');
      });

      test('updateRoomStatus Firestore status değerini günceller', () async {
        final roomCode = await createRoomAndGetCode();
        expect(
            (await fakeFirestore.collection('rooms').doc(roomCode).get())
                .data()!['status'],
            'waiting');

        await roomSource.updateRoomStatus(
          roomCode: roomCode,
          status: GameStatus.playing,
        );
        final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
        expect(roomDoc.data()!['status'], 'playing');
      });
    });

    group('oda silme (gameId edge case)', () {
      test('host ayrılınca gameId varsa oyun dökümanı da silinir', () async {
        final roomCode = await createRoomAndGetCode();
        await roomSource.joinRoom(
          roomCode: roomCode,
          playerId: 'player2',
          playerName: 'P2',
        );
        final gameId = await roomSource.startGameInRoom(
          roomCode: roomCode,
          playerIds: ['host1', 'player2'],
          mode: GameMode.classic,
        );

        var gameDoc = await fakeFirestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists, isTrue);

        await roomSource.leaveRoom(roomCode: roomCode, playerId: 'host1');

        final roomDoc = await fakeFirestore.collection('rooms').doc(roomCode).get();
        expect(roomDoc.exists, isFalse);
        gameDoc = await fakeFirestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists, isFalse);
      });
    });
  });
}
