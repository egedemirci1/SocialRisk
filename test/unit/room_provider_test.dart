import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/core/providers/lifecycle_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/features/room/providers/room_provider.dart';
import 'package:social_risk/shared/models/enums.dart';
import '../helpers/fake_room_repository.dart';
import '../helpers/fake_user_repository.dart';

void main() {
  group('RoomController (with FakeRoomRepository)', () {
    test('createRoom returns room code from fake repository', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(
            FakeRoomRepository(createdRoomCode: 'ABC123'),
          ),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      final code = await controller.createRoom(
        hostId: 'host1',
        hostName: 'Host',
        endConditionType: EndConditionType.score,
        endConditionValue: 5000,
        visibility: RoomVisibility.open,
        categories: ['Fiziksel', 'Bilgi'],
        mode: GameMode.classic,
        useCustomDeck: false,
      );

      expect(code, 'ABC123');
      expect(container.read(currentRoomTrackerProvider), 'ABC123');
    });

    test('leaveRoom clears current room tracker', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.createRoom(
        hostId: 'h',
        hostName: 'H',
        endConditionType: EndConditionType.score,
        endConditionValue: 5000,
        visibility: RoomVisibility.open,
        categories: [],
        mode: GameMode.classic,
        useCustomDeck: false,
      );
      expect(container.read(currentRoomTrackerProvider), isNotNull);

      await controller.leaveRoom(roomCode: 'FAKE01', playerId: 'h');
      expect(container.read(currentRoomTrackerProvider), isNull);
    });

    test('joinRoom updates room tracker', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.joinRoom(
        roomCode: 'JOIN01',
        playerId: 'p1',
        playerName: 'Player One',
      );
      expect(container.read(currentRoomTrackerProvider), 'JOIN01');
    });

    test('toggleReady completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.toggleReady(
        roomCode: 'R1',
        playerId: 'p1',
        isReady: true,
      );
    });

    test('startGame completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.startGame('ROOM1');
    });

    test('toggleVisibility completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.toggleVisibility(
        roomCode: 'R1',
        visibility: RoomVisibility.closed,
      );
    });

    test('cleanupZombies completes without error', () async {
      final container = ProviderContainer(
        overrides: [
          roomRepositoryProvider.overrideWithValue(FakeRoomRepository()),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(roomControllerProvider.notifier);
      await controller.cleanupZombies();
    });
  });
}
