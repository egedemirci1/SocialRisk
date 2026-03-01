import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/room/presentation/home_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/join_room_screen.dart';
import '../../features/room/presentation/lobby_screen.dart';
import '../../features/game/presentation/task_screen.dart';
import '../../features/game/presentation/performing_screen.dart';
import '../../features/game/presentation/waiting_screen.dart';
import '../../features/game/presentation/round_result_screen.dart';
import '../../features/game/presentation/game_over_screen.dart';
import '../../features/game/presentation/difficulty_choice_screen.dart';
import '../../features/voting/presentation/voting_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/economy/presentation/store_screen.dart';
import '../../features/game/presentation/economy_pick_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/task_editor_screen.dart';
import '../../features/admin/presentation/reported_photos_screen.dart';
import '../../features/admin/providers/admin_provider.dart';
import '../../features/admin/domain/task_item_entity.dart';

/// Listens to Firebase auth state so GoRouter re-evaluates redirect
/// automatically when the user signs in or out.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authRefreshNotifier = _AuthRefreshNotifier();

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isOnLoginPage = state.matchedLocation == '/';

    if (user == null) {
      // Not signed in — send to login if not already there
      return isOnLoginPage ? null : '/';
    }

    // Signed in — don't let them stay on login page
    if (isOnLoginPage) return '/home';

    // Admin pages guard
    if (state.matchedLocation.startsWith('/admin')) {
      if (!isAdmin(user.uid)) return '/home';
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
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/store',
      builder: (context, state) => const StoreScreen(),
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
      path: '/performing',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return PerformingScreen(
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
    GoRoute(
      path: '/difficulty',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final gameId = extra?['gameId'] as String? ?? '';
        final roomCode = extra?['roomCode'] as String? ?? '';

        return DifficultyChoiceScreen(gameId: gameId, roomCode: roomCode);
      },
    ),
    GoRoute(
      path: '/economy-pick',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return EconomyPickScreen(
          gameId: extra['gameId'] ?? '',
          roomCode: extra['roomCode'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/task-editor',
      builder: (context, state) {
        final task = state.extra as TaskItemEntity?;
        return TaskEditorScreen(taskToEdit: task);
      },
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const ReportedPhotosScreen(),
    ),
  ],
);
