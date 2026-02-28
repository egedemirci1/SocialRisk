import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
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
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/task',
      builder: (context, state) => const TaskScreen(),
    ),
    GoRoute(
      path: '/voting',
      builder: (context, state) => const VotingScreen(),
    ),
    GoRoute(
      path: '/waiting',
      builder: (context, state) => const WaitingScreen(),
    ),
    GoRoute(
      path: '/round-result',
      builder: (context, state) => const RoundResultScreen(),
    ),
    GoRoute(
      path: '/game-over',
      builder: (context, state) => const GameOverScreen(),
    ),
  ],
);
