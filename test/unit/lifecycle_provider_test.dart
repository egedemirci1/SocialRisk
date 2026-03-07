import 'dart:async';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_risk/core/providers/lifecycle_provider.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/room/providers/room_provider.dart';

/// Oda kodu 'ODA_123' dönen tracker — lifecycle testinde kullanıcının odada olduğunu simüle eder.
class _FakeCurrentRoomTracker extends CurrentRoomTracker {
  @override
  String? build() => 'ODA_123';
}

/// leaveRoom çağrılarını kaydeden sahte controller — verify için.
class _FakeRoomControllerForLifecycle extends RoomController {
  final List<({String roomCode, String playerId})> leaveRoomCalls = [];

  @override
  FutureOr<String?> build() => null;

  @override
  Future<void> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    leaveRoomCalls.add((roomCode: roomCode, playerId: playerId));
  }
}

void main() {
  group('CurrentRoomTracker', () {
    test('build returns null initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(currentRoomTrackerProvider), isNull);
    });

    test('updateRoom sets state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(currentRoomTrackerProvider.notifier).updateRoom('ROOM1');
      expect(container.read(currentRoomTrackerProvider), 'ROOM1');

      container.read(currentRoomTrackerProvider.notifier).updateRoom('ROOM2');
      expect(container.read(currentRoomTrackerProvider), 'ROOM2');

      container.read(currentRoomTrackerProvider.notifier).updateRoom(null);
      expect(container.read(currentRoomTrackerProvider), isNull);
    });
  });

  group('AppLifecycleManager', () {
    testWidgets('uygulama arka plana atıldığında (hidden) odadan çıkış tetiklenir', (tester) async {
      final mockUser = MockUser(uid: 'oyuncu_1', isAnonymous: true);
      final fakeRoomController = _FakeRoomControllerForLifecycle();

      final container = ProviderContainer(
        overrides: [
          currentRoomTrackerProvider.overrideWith(() => _FakeCurrentRoomTracker()),
          currentUserProvider.overrideWithValue(mockUser),
          roomControllerProvider.overrideWith(() => fakeRoomController),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLifecycleManagerProvider);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeRoomController.leaveRoomCalls.length, 1);
      expect(fakeRoomController.leaveRoomCalls.first.roomCode, 'ODA_123');
      expect(fakeRoomController.leaveRoomCalls.first.playerId, 'oyuncu_1');
    });

    testWidgets('onDetach tetiklendiğinde de leaveRoom çağrılır', (tester) async {
      final mockUser = MockUser(uid: 'p2', isAnonymous: true);
      final fakeRoomController = _FakeRoomControllerForLifecycle();

      final container = ProviderContainer(
        overrides: [
          currentRoomTrackerProvider.overrideWith(() => _FakeCurrentRoomTracker()),
          currentUserProvider.overrideWithValue(mockUser),
          roomControllerProvider.overrideWith(() => fakeRoomController),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLifecycleManagerProvider);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);

      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeRoomController.leaveRoomCalls.length, 1);
      expect(fakeRoomController.leaveRoomCalls.first.roomCode, 'ODA_123');
      expect(fakeRoomController.leaveRoomCalls.first.playerId, 'p2');
    });

    testWidgets('kullanıcı yoksa (null) leaveRoom çağrılmaz', (tester) async {
      final fakeRoomController = _FakeRoomControllerForLifecycle();

      final container = ProviderContainer(
        overrides: [
          currentRoomTrackerProvider.overrideWith(() => _FakeCurrentRoomTracker()),
          currentUserProvider.overrideWithValue(null),
          roomControllerProvider.overrideWith(() => fakeRoomController),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLifecycleManagerProvider);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeRoomController.leaveRoomCalls.length, 0);
    });

    testWidgets('oda kodu yoksa (null) leaveRoom çağrılmaz', (tester) async {
      final mockUser = MockUser(uid: 'oyuncu_1', isAnonymous: true);
      final fakeRoomController = _FakeRoomControllerForLifecycle();

      final container = ProviderContainer(
        overrides: [
          currentRoomTrackerProvider.overrideWith(() => CurrentRoomTracker()),
          currentUserProvider.overrideWithValue(mockUser),
          roomControllerProvider.overrideWith(() => fakeRoomController),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLifecycleManagerProvider);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeRoomController.leaveRoomCalls.length, 0);
    });

    test('container dispose edildiğinde manager dispose olur', () {
      final container = ProviderContainer();
      container.read(appLifecycleManagerProvider);
      container.dispose();
    });
  });
}
