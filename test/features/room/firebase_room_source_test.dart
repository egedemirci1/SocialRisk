import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/game_constants.dart';
import 'package:social_risk/features/room/data/firebase_room_source.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('FirebaseRoomSource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseRoomSource roomSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      roomSource = FirebaseRoomSource(firestore: fakeFirestore);
    });

    test('createRoom creates room and host as first player', () async {
      final roomCode = await roomSource.createRoom(
        hostId: 'host1',
        hostName: 'Host',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );

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
      final roomCode = await roomSource.createRoom(
        hostId: 'host1',
        hostName: 'Host',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );

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
      final roomCode = await roomSource.createRoom(
        hostId: 'host1',
        hostName: 'Host',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );

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
      final roomCode = await roomSource.createRoom(
        hostId: 'host1',
        hostName: 'Host',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );
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
      final roomCode = await roomSource.createRoom(
        hostId: 'h1',
        hostName: 'H',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );

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
      final roomCode = await roomSource.createRoom(
        hostId: 'h1',
        hostName: 'H',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );

      final stream = roomSource.watchPlayers(roomCode);
      final values = <List<dynamic>>[];
      final sub = stream.listen(values.add);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(values, isNotEmpty);
      expect(values.last.length, 1);
      expect(values.last.first.displayName, 'H');
      await sub.cancel();
    });

    test('doesRoomExist returns true when room exists', () async {
      final roomCode = await roomSource.createRoom(
        hostId: 'h1',
        hostName: 'H',
        endConditionType: EndConditionType.score,
        endConditionValue: 500,
        visibility: RoomVisibility.open,
        categories: GameConstants.defaultCategoriesConst,
        mode: GameMode.classic,
        useCustomDeck: false,
      );
      expect(await roomSource.doesRoomExist(roomCode), isTrue);
    });

    test('doesRoomExist returns false when room does not exist', () async {
      expect(await roomSource.doesRoomExist('NONEX'), isFalse);
    });
  });
}
