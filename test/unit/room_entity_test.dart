import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/room/domain/room_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 12, 0);

  group('RoomEntity', () {
    test('varsayılan değerlerle doğru oluşturulmalı', () {
      final room = RoomEntity(
        roomCode: 'ABC123',
        hostId: 'host_1',
        createdAt: fixedDate,
      );

      expect(room.roomCode, 'ABC123');
      expect(room.hostId, 'host_1');
      expect(room.createdAt, fixedDate);
      expect(room.mode, GameMode.classic);
      expect(room.status, GameStatus.waiting);
      expect(room.endConditionType, EndConditionType.score);
      expect(room.endConditionValue, 5000);
      expect(room.visibility, RoomVisibility.open);
      expect(room.players, isEmpty);
      expect(room.categories, isEmpty);
      expect(room.useCustomDeck, false);
      expect(room.gameId, isNull);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final players = [
        PlayerEntity(id: 'p1', displayName: 'Ali'),
        PlayerEntity(id: 'p2', displayName: 'Veli'),
      ];
      final room = RoomEntity(
        roomCode: 'XYZ789',
        hostId: 'host_2',
        mode: GameMode.economy,
        status: GameStatus.playing,
        endConditionType: EndConditionType.rounds,
        endConditionValue: 10,
        visibility: RoomVisibility.closed,
        players: players,
        categories: ['Fiziksel', 'Bilgi'],
        useCustomDeck: true,
        gameId: 'game_1',
        createdAt: fixedDate,
      );

      expect(room.roomCode, 'XYZ789');
      expect(room.mode, GameMode.economy);
      expect(room.status, GameStatus.playing);
      expect(room.endConditionType, EndConditionType.rounds);
      expect(room.endConditionValue, 10);
      expect(room.visibility, RoomVisibility.closed);
      expect(room.players, players);
      expect(room.categories, ['Fiziksel', 'Bilgi']);
      expect(room.useCustomDeck, isTrue);
      expect(room.gameId, 'game_1');
    });
  });

  group('PlayerEntity', () {
    test('varsayılan değerlerle doğru oluşturulmalı', () {
      final player = PlayerEntity(
        id: 'player_1',
        displayName: 'Test Oyuncu',
      );

      expect(player.id, 'player_1');
      expect(player.displayName, 'Test Oyuncu');
      expect(player.name, 'Test Oyuncu');
      expect(player.avatarUrl, isNull);
      expect(player.activeFrame, isNull);
      expect(player.activeTitle, isNull);
      expect(player.score, 0);
      expect(player.passStreak, 0);
      expect(player.isReady, false);
    });

    test('name getter displayName döndürmeli', () {
      const name = 'Özel İsim';
      final player = PlayerEntity(id: 'id', displayName: name);
      expect(player.name, name);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final player = PlayerEntity(
        id: 'p1',
        displayName: 'Skorlu Oyuncu',
        avatarUrl: 'https://example.com/avatar.png',
        activeFrame: 'frame_fire',
        activeTitle: 'Kral',
        score: 150,
        passStreak: 2,
        isReady: true,
      );

      expect(player.avatarUrl, 'https://example.com/avatar.png');
      expect(player.activeFrame, 'frame_fire');
      expect(player.activeTitle, 'Kral');
      expect(player.score, 150);
      expect(player.passStreak, 2);
      expect(player.isReady, isTrue);
    });
  });
}
