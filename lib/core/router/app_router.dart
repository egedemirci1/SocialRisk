import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/room/presentation/home_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/join_room_screen.dart';
import '../../features/room/presentation/lobby_screen.dart';
import '../../features/room/presentation/settings_screen.dart';
import '../../features/game/presentation/task_screen.dart';
import '../../features/game/presentation/performing_screen.dart';
import '../../features/game/presentation/waiting_screen.dart';
import '../../features/game/presentation/round_result_screen.dart';
import '../../features/game/presentation/game_over_screen.dart';
import '../../features/game/presentation/difficulty_choice_screen.dart';
import '../../features/voting/presentation/voting_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/profile/presentation/custom_deck_editor_screen.dart';
import '../../features/store/presentation/store_screen.dart';
import '../../features/game/presentation/economy_pick_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/task_editor_screen.dart';
import '../../features/admin/presentation/reported_photos_screen.dart';
import '../../features/admin/providers/admin_provider.dart';
import '../../features/admin/domain/task_item_entity.dart';
import '../../shared/widgets/guards/active_game_guard.dart';

/// Listens to Firebase auth state so GoRouter re-evaluates redirect
/// automatically when the user signs in or out.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authRefreshNotifier = _AuthRefreshNotifier();

String? _redirectIfMissingRouteExtra(GoRouterState state) {
  switch (state.matchedLocation) {
    case '/lobby':
      final roomCode = state.extra;
      if (roomCode is! String || roomCode.isEmpty) return '/home';
      return null;
    case '/game-over':
      final roomCode = state.extra;
      if (roomCode is! String || roomCode.isEmpty) return '/home';
      return null;
    case '/task':
    case '/performing':
    case '/voting':
    case '/waiting':
    case '/round-result':
    case '/difficulty':
    case '/economy-pick':
      final extra = state.extra;
      if (extra is! Map) return '/home';
      final gameId = extra['gameId'];
      final roomCode = extra['roomCode'];
      if (gameId is! String || gameId.isEmpty) return '/home';
      if (roomCode is! String || roomCode.isEmpty) return '/home';
      return null;
    default:
      return null;
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final location = state.matchedLocation;
    if (location == '/splash') return null;

    final user = FirebaseAuth.instance.currentUser;
    final isOnLoginPage = location == '/';

    if (user == null) {
      return isOnLoginPage ? null : '/';
    }
    if (isOnLoginPage) return '/home';

    final missingExtraRedirect = _redirectIfMissingRouteExtra(state);
    if (missingExtraRedirect != null) return missingExtraRedirect;

    if (location.startsWith('/admin')) {
      if (!isAdmin(user.uid)) return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const SplashScreen(), state: state),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const LoginScreen(), state: state),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const HomeScreen(), state: state),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const ProfileScreen(), state: state),
    ),
    GoRoute(
      path: '/custom-deck',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const CustomDeckEditorScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/store',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const StoreScreen(), state: state),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const SettingsScreen(), state: state),
    ),
    GoRoute(
      path: '/create-room',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const CreateRoomScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/join-room',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const JoinRoomScreen(), state: state),
    ),
    GoRoute(
      path: '/lobby',
      pageBuilder: (context, state) {
        final roomCode = state.extra! as String;
        return _buildPageWithTransition(
          child: LobbyScreen(roomCode: roomCode),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/task',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: TaskScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/performing',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: PerformingScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/voting',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: VotingScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/waiting',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: WaitingScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/round-result',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: RoundResultScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/game-over',
      pageBuilder: (context, state) {
        final roomCode = state.extra! as String;
        return _buildPageWithTransition(
          child: GameOverScreen(roomCode: roomCode),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/difficulty',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final gameId = extra['gameId'] as String;
        final roomCode = extra['roomCode'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: DifficultyChoiceScreen(gameId: gameId, roomCode: roomCode),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/economy-pick',
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        final roomCode = extra['roomCode'] as String;
        final gameId = extra['gameId'] as String;
        return _buildPageWithTransition(
          child: ActiveGameGuard(
            roomCode: roomCode,
            child: EconomyPickScreen(
              gameId: gameId,
              roomCode: roomCode,
            ),
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const AdminDashboardScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/admin/task-editor',
      pageBuilder: (context, state) {
        final task = state.extra as TaskItemEntity?;
        return _buildPageWithTransition(
          child: TaskEditorScreen(taskToEdit: task),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/admin/reported-photos',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const ReportedPhotosScreen(),
        state: state,
      ),
    ),
  ],
);

/// A utility to build standard fade/slide transition pages
CustomTransitionPage<void> _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.03),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
