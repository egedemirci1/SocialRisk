import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/room/presentation/home_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/join_room_screen.dart';
import '../../features/room/presentation/lobby_screen.dart';
import '../../features/game/presentation/task_screen.dart';
import '../../features/game/presentation/waiting_screen.dart';
import '../../features/game/presentation/round_result_screen.dart';
import '../../features/game/presentation/game_over_screen.dart';
import '../../features/voting/presentation/voting_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final user = container.read(currentUserProvider);
    final loggingIn = state.matchedLocation == '/';

    if (user == null) {
      return loggingIn ? null : '/';
    }

    if (loggingIn) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create-room',
      builder: (context, state) => const CreateRoomScreen(),
    ),
    GoRoute(
      path: '/join-room',
      builder: (context, state) => const JoinRoomScreen(),
    ),
    GoRoute(
      path: '/lobby',
      builder: (context, state) {
        final roomCode = state.extra as String? ?? '';
        return LobbyScreen(roomCode: roomCode);
      },
    ),
    GoRoute(
      path: '/task',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return TaskScreen(
          gameId: extra['gameId'] ?? '',
          roomCode: extra['roomCode'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/voting',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return VotingScreen(
          gameId: extra['gameId'] ?? '',
          roomCode: extra['roomCode'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/waiting',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return WaitingScreen(
          gameId: extra['gameId'] ?? '',
          roomCode: extra['roomCode'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/round-result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return RoundResultScreen(
          gameId: extra['gameId'] as String? ?? '',
          roomCode: extra['roomCode'] as String? ?? '',
          earnedScore: extra['earnedScore'] as int? ?? 0,
          multiplier: extra['multiplier'] as int? ?? 1,
        );
      },
    ),
    GoRoute(
      path: '/game-over',
      builder: (context, state) {
        final extra = state.extra as String? ?? '';
        return GameOverScreen(roomCode: extra);
      },
    ),
  ],
);
