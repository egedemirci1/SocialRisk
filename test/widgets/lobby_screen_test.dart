import 'dart:async';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_risk/features/auth/providers/auth_provider.dart';
import 'package:social_risk/features/auth/providers/user_provider.dart';
import 'package:social_risk/features/room/domain/room_entity.dart';
import 'package:social_risk/features/room/domain/room_repository.dart';
import 'package:social_risk/features/room/presentation/lobby_screen.dart';
import 'package:social_risk/features/room/providers/room_provider.dart';
import 'package:social_risk/features/economy/providers/economy_provider.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/shared/models/enums.dart';
import 'package:social_risk/shared/widgets/buttons/stage_button.dart';
import '../helpers/fake_user_repository.dart';
import '../helpers/fake_user_controller.dart';
import '../helpers/widget_test_app.dart';

// ---------------------------------------------------------------------------
// Mock: Gerçek Firebase'e gitmemek için RoomRepository mocklanıyor;
// toggleReady ve startGameInRoom çağrılarını verify edeceğiz.
// Not: lobby_screen.dart içinde "Oyunu Başlat" ve "Hazır" butonlarında
// Key tanımlı değil; bu yüzden find.widgetWithText(StageButton, '...') ve
// find.text('...') kullanıyoruz. İleride testler kırılmasın diye Key eklenebilir.
// ---------------------------------------------------------------------------
class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  const roomCode = 'ABC123';

  setUpAll(() {
    registerFallbackValue(GameMode.classic);
    registerFallbackValue(<String>[]);
  });

  // Sahte oda ve oyuncu listeleri (3 oyunculu senaryo için)
  final threePlayers = <PlayerEntity>[
    const PlayerEntity(id: 'host1', displayName: 'Host', isReady: true),
    const PlayerEntity(id: 'p2', displayName: 'Ali', isReady: false),
    const PlayerEntity(id: 'p3', displayName: 'Ayşe', isReady: false),
  ];

  final roomWithThreePlayers = RoomEntity(
    roomCode: roomCode,
    hostId: 'host1',
    status: GameStatus.waiting,
    createdAt: DateTime(2024, 1, 1),
    players: threePlayers,
  );

  /// ProviderScope + MaterialApp.router ile sarar; GoRouter sayesinde
  /// "Oyunu Başlat" tıklanınca context.go('/task') hata vermez.
  /// Geri butonu testi için / altında /lobby olacak şekilde rota verilirse pop çalışır.
  Widget buildLobby({
    required overrides,
    String? initialLocation,
    bool withParentRoute = false,
  }) {
    if (withParentRoute) {
      return wrapWithLocalizedRouter(
        overrides: overrides,
        routerConfig: GoRouter(
            initialLocation: initialLocation ?? '/lobby',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const SizedBox.shrink(),
                routes: [
                  GoRoute(
                    path: 'lobby',
                    builder: (_, __) => MediaQuery(
                      data: const MediaQueryData(size: Size(600, 900)),
                      child: LobbyScreen(roomCode: roomCode),
                    ),
                  ),
                ],
              ),
              GoRoute(path: '/task', builder: (_, __) => const SizedBox.shrink()),
              GoRoute(path: '/home', builder: (_, __) => const SizedBox.shrink()),
            ],
          ),
      );
    }
    return wrapWithLocalizedRouter(
      overrides: overrides,
      routerConfig: GoRouter(
        initialLocation: initialLocation ?? '/lobby',
        routes: [
          GoRoute(
            path: '/lobby',
            builder: (_, __) => MediaQuery(
              data: const MediaQueryData(size: Size(600, 900)),
              child: LobbyScreen(roomCode: roomCode),
            ),
          ),
          GoRoute(
            path: '/task',
            builder: (_, __) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  group('LobbyScreen', () {
    testWidgets('renders title and room code', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Lobi'), findsOneWidget);
      expect(find.text('ODA KODU'), findsOneWidget);
      expect(find.text(roomCode), findsOneWidget);
    });

    testWidgets('loading durumu: oda/oyuncu verisi gelmeden loading indikatörü görünür', (tester) async {
      final playersNeverEmits = StreamController<List<PlayerEntity>>();
      addTearDown(playersNeverEmits.close);

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'p2', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => playersNeverEmits.stream),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('oyuncu listesi: 3 kişilik sahte veri geldiğinde 3 oyuncu adı listelenir', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Host (Sen)'), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text('Ayşe'), findsOneWidget);
      expect(find.text('Hazırım!'), findsOneWidget);
      expect(find.text('Hazır Ol'), findsWidgets);
    });

    testWidgets('Hazır butonu (non-host): tıklanınca toggleReady tetiklenir', (tester) async {
      final mockRepo = MockRoomRepository();
      when(() => mockRepo.watchRoom(any())).thenAnswer((_) => Stream.value(roomWithThreePlayers));
      when(() => mockRepo.watchPlayers(any())).thenAnswer((_) => Stream.value(threePlayers));
      when(() => mockRepo.toggleReady(
        roomCode: any(named: 'roomCode'),
        playerId: any(named: 'playerId'),
        isReady: any(named: 'isReady'),
      )).thenAnswer((_) async {});

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'p2', isAnonymous: true)),
            roomRepositoryProvider.overrideWithValue(mockRepo),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Oyuncu host değilse "HENÜZ HAZIR DEĞİLİM" butonu görünür
      expect(find.text('HAZIR OL'), findsOneWidget);
      await tester.tap(find.widgetWithText(StageButton, 'HAZIR OL'));
      await tester.pump();

      verify(() => mockRepo.toggleReady(
        roomCode: roomCode,
        playerId: 'p2',
        isReady: true,
      )).called(1);
    });

    testWidgets('Kurucu değilse "Oyunu Başlat" butonu görünmez; sadece Hazır toggle vardır', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'p2', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('HAZIR OL'), findsOneWidget);
      expect(find.text('Oyunu Başlat'), findsNothing);
    });

    testWidgets('Kurucu ekranda ama herkes hazır değilse "Oyunu Başlat" pasif (tıklanınca startGame çağrılmaz)', (tester) async {
      final mockRepo = MockRoomRepository();
      when(() => mockRepo.watchRoom(any())).thenAnswer((_) => Stream.value(roomWithThreePlayers));
      when(() => mockRepo.watchPlayers(any())).thenAnswer((_) => Stream.value(threePlayers));
      when(() => mockRepo.startGameInRoom(
        roomCode: any(named: 'roomCode'),
        playerIds: any(named: 'playerIds'),
        mode: any(named: 'mode'),
        categories: any(named: 'categories'),
      )).thenAnswer((_) async => 'game-1');

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            roomRepositoryProvider.overrideWithValue(mockRepo),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // allReady false (p2, p3 hazır değil) → buton pasif (onPressed: () {})
      expect(find.text('Oyunu Başlat'), findsOneWidget);
      await tester.tap(find.text('Oyunu Başlat'));
      await tester.pump();

      verifyNever(() => mockRepo.startGameInRoom(
        roomCode: any(named: 'roomCode'),
        playerIds: any(named: 'playerIds'),
        mode: any(named: 'mode'),
        categories: any(named: 'categories'),
      ));
    });

    testWidgets('Herkes hazırken kurucu "Oyunu Başlat"a tıklayınca startGameInRoom tetiklenir', (tester) async {
      final allReadyPlayers = <PlayerEntity>[
        const PlayerEntity(id: 'host1', displayName: 'Host', isReady: true),
        const PlayerEntity(id: 'p2', displayName: 'Ali', isReady: true),
        const PlayerEntity(id: 'p3', displayName: 'Ayşe', isReady: true),
      ];
      final roomAllReady = RoomEntity(
        roomCode: roomCode,
        hostId: 'host1',
        status: GameStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
        players: allReadyPlayers,
      );

      final mockRepo = MockRoomRepository();
      when(() => mockRepo.watchRoom(any())).thenAnswer((_) => Stream.value(roomAllReady));
      when(() => mockRepo.watchPlayers(any())).thenAnswer((_) => Stream.value(allReadyPlayers));
      when(() => mockRepo.startGameInRoom(
        roomCode: any(named: 'roomCode'),
        playerIds: any(named: 'playerIds'),
        mode: any(named: 'mode'),
        categories: any(named: 'categories'),
      )).thenAnswer((_) async => 'game-123');

      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            roomRepositoryProvider.overrideWithValue(mockRepo),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Oyunu Başlat'), findsOneWidget);
      await tester.tap(find.widgetWithText(StageButton, 'Oyunu Başlat'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => mockRepo.startGameInRoom(
        roomCode: roomCode,
        playerIds: ['host1', 'p2', 'p3'],
        mode: GameMode.classic,
        categories: any(named: 'categories'),
      )).called(1);
    });

    testWidgets('copy butonu tıklanınca başarı mesajı gösterilir', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Kod kopyalandı!'), findsOneWidget);
      // Toast overlay 3 sn sonra kapanıyor; timer bitene kadar pump et (pending timer hatasını önler)
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('players stream hata verince hata mesajı gösterilir', (tester) async {
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.error(Exception('Network error'))),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Veriler yüklenemedi'), findsAtLeastNWidgets(1));
    });

    testWidgets('Geri (Çıkış) Butonu: onay sonrası leaveRoom tetiklenir', (tester) async {
      final mockRepo = MockRoomRepository();
      when(() => mockRepo.watchRoom(any())).thenAnswer((_) => Stream.value(roomWithThreePlayers));
      when(() => mockRepo.watchPlayers(any())).thenAnswer((_) => Stream.value(threePlayers));
      when(() => mockRepo.leaveRoom(
        roomCode: any(named: 'roomCode'),
        playerId: any(named: 'playerId'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            roomRepositoryProvider.overrideWithValue(mockRepo),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          withParentRoute: true,
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back_ios_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Partiden Ayrıl'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sil ve Çık'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      verify(() => mockRepo.leaveRoom(roomCode: roomCode, playerId: 'host1')).called(1);
    });

    testWidgets('Raporlama: Başka bir oyuncuya uzun basınca ReportDialog açılır', (tester) async {
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
            userControllerProvider.overrideWith(() => FakeUserController()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Ali'nin (p2) üzerine uzun bas (host1 kendisi, p2 başkası)
      await tester.longPress(find.text('Ali'));
      await tester.pumpAndSettle();

      expect(find.text('Kullanıcıyı Raporla'), findsOneWidget);
    });

    testWidgets('Teşvik Metni: Herkes hazır olduğunda kurucuda teşvik metni görünür', (tester) async {
      // 2 oyuncu, ikisi de hazır (host kendi tile'ında isReady: true gelmese de allReady mantığında p.id==hostId or p.isReady bakıyor)
      final allReadyPlayers = <PlayerEntity>[
        const PlayerEntity(id: 'host1', displayName: 'Host', isReady: true),
        const PlayerEntity(id: 'p2', displayName: 'Ali', isReady: true),
      ];
      final roomAllReady = RoomEntity(
        roomCode: roomCode,
        hostId: 'host1',
        status: GameStatus.waiting,
        createdAt: DateTime(2024, 1, 1),
        players: allReadyPlayers,
      );

      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomAllReady)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(allReadyPlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Haydi, herkes seni bekliyor!'), findsOneWidget);
    });

    testWidgets('Teşvik metni: Herkes hazır değilken "Diğer oyuncuların hazırlanmasını bekleyin..." görünür', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 900));
      await tester.pumpWidget(
        buildLobby(
          overrides: [
            currentUserProvider.overrideWithValue(MockUser(uid: 'host1', isAnonymous: true)),
            watchRoomProvider(roomCode).overrideWith((ref) => Stream.value(roomWithThreePlayers)),
            watchPlayersProvider(roomCode).overrideWith((ref) => Stream.value(threePlayers)),
            fetchCosmeticsProvider.overrideWith((ref) => Future.value(<CosmeticItemEntity>[])),
            userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Diğer oyuncuların hazırlanmasını bekleyin...'), findsOneWidget);
    });
  });
}
