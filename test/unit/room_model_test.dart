import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/room/data/room_model.dart';
import 'package:social_risk/features/room/domain/room_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  final fixedDate = DateTime(2024, 3, 1, 12, 0);

  group('RoomModel', () {
    test('fromJson tüm alanları doğru parse etmeli', () {
      final json = {
        'roomCode': 'ABC123',
        'hostId': 'host_1',
        'mode': 'economy',
        'status': 'playing',
        'endConditionType': 'rounds',
        'endConditionValue': 10,
        'visibility': 'closed',
        'categories': ['Fiziksel', 'Bilgi'],
        'useCustomDeck': true,
        'gameId': 'game_1',
        'createdAt': Timestamp.fromDate(fixedDate),
      };

      final model = RoomModel.fromJson(json);

      expect(model.roomCode, 'ABC123');
      expect(model.hostId, 'host_1');
      expect(model.mode, 'economy');
      expect(model.status, 'playing');
      expect(model.endConditionType, 'rounds');
      expect(model.endConditionValue, 10);
      expect(model.visibility, 'closed');
      expect(model.categories, ['Fiziksel', 'Bilgi']);
      expect(model.useCustomDeck, true);
      expect(model.gameId, 'game_1');
      expect(model.createdAt, fixedDate);
    });

    test('fromJson eksik alanlarda varsayılan kullanmalı', () {
      final model = RoomModel.fromJson({
        'roomCode': 'X',
        'hostId': 'H',
        'createdAt': Timestamp.fromDate(fixedDate),
      });

      expect(model.mode, 'classic');
      expect(model.status, 'waiting');
      expect(model.endConditionType, 'score');
      expect(model.endConditionValue, 500);
      expect(model.visibility, 'open');
      expect(model.categories, isEmpty);
      expect(model.useCustomDeck, false);
      expect(model.gameId, isNull);
    });

    test('toJson tüm anahtarları içermeli', () {
      final model = RoomModel(
        roomCode: 'CODE',
        hostId: 'host',
        mode: 'classic',
        status: 'waiting',
        endConditionType: 'score',
        endConditionValue: 5000,
        createdAt: fixedDate,
      );
      final json = model.toJson();

      expect(json['roomCode'], 'CODE');
      expect(json['hostId'], 'host');
      expect(json['mode'], 'classic');
      expect(json['status'], 'waiting');
      expect(json['endConditionType'], 'score');
      expect(json['endConditionValue'], 5000);
      expect(json['visibility'], 'open');
      expect(json['categories'], isEmpty);
      expect(json['useCustomDeck'], false);
      expect(json['gameId'], isNull);
      expect(json.containsKey('createdAt'), isTrue);
    });

    test('toEntity doğru entity döndürmeli', () {
      final players = [
        PlayerEntity(id: 'p1', displayName: 'Ali'),
        PlayerEntity(id: 'p2', displayName: 'Veli'),
      ];
      final model = RoomModel(
        roomCode: 'ROOM1',
        hostId: 'h1',
        mode: 'economy',
        status: 'playing',
        endConditionType: 'rounds',
        endConditionValue: 8,
        visibility: 'closed',
        categories: ['Bilgi'],
        useCustomDeck: true,
        gameId: 'g1',
        createdAt: fixedDate,
      );

      final entity = model.toEntity(players);

      expect(entity.roomCode, 'ROOM1');
      expect(entity.hostId, 'h1');
      expect(entity.mode, GameMode.economy);
      expect(entity.status, GameStatus.playing);
      expect(entity.endConditionType, EndConditionType.rounds);
      expect(entity.endConditionValue, 8);
      expect(entity.visibility, RoomVisibility.closed);
      expect(entity.players, players);
      expect(entity.categories, ['Bilgi']);
      expect(entity.useCustomDeck, true);
      expect(entity.gameId, 'g1');
      expect(entity.createdAt, fixedDate);
    });
  });

  group('PlayerModel', () {
    test('fromJson tüm alanları doğru parse etmeli', () {
      final json = {
        'displayName': 'Oyuncu Adı',
        'avatarUrl': 'https://avatar.png',
        'activeFrame': 'frame_fire',
        'activeTitle': 'Kral',
        'score': 100,
        'passStreak': 2,
        'isReady': true,
      };

      final model = PlayerModel.fromJson(json, 'player_doc_id');

      expect(model.id, 'player_doc_id');
      expect(model.displayName, 'Oyuncu Adı');
      expect(model.avatarUrl, 'https://avatar.png');
      expect(model.activeFrame, 'frame_fire');
      expect(model.activeTitle, 'Kral');
      expect(model.score, 100);
      expect(model.passStreak, 2);
      expect(model.isReady, true);
    });

    test('fromJson eksik alanlarda varsayılan kullanmalı', () {
      final model = PlayerModel.fromJson({}, 'id');

      expect(model.displayName, 'Oyuncu');
      expect(model.avatarUrl, isNull);
      expect(model.activeFrame, isNull);
      expect(model.activeTitle, isNull);
      expect(model.score, 0);
      expect(model.passStreak, 0);
      expect(model.isReady, false);
    });

    test('toJson round-trip tutarlı olmalı', () {
      final model = PlayerModel(
        id: 'p1',
        displayName: 'Test',
        avatarUrl: 'url',
        score: 50,
        passStreak: 1,
        isReady: true,
      );
      final json = model.toJson();

      expect(json['displayName'], 'Test');
      expect(json['avatarUrl'], 'url');
      expect(json['score'], 50);
      expect(json['passStreak'], 1);
      expect(json['isReady'], true);
    });

    test('toEntity doğru entity döndürmeli', () {
      final model = PlayerModel(
        id: 'p1',
        displayName: 'Entity Test',
        avatarUrl: 'https://x.png',
        activeFrame: 'f1',
        activeTitle: 'Şövalye',
        score: 200,
        passStreak: 3,
        isReady: true,
      );

      final entity = model.toEntity();

      expect(entity.id, 'p1');
      expect(entity.displayName, 'Entity Test');
      expect(entity.avatarUrl, 'https://x.png');
      expect(entity.activeFrame, 'f1');
      expect(entity.activeTitle, 'Şövalye');
      expect(entity.score, 200);
      expect(entity.passStreak, 3);
      expect(entity.isReady, true);
    });
  });
}
