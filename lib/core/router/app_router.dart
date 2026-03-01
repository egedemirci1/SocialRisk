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
import '../../features/profile/presentation/custom_deck_editor_screen.dart';
import '../../features/store/presentation/store_screen.dart';
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
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const LoginScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const HomeScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const ProfileScreen(),
        state: state,
      ),
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
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const StoreScreen(),
        state: state,
      ),
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
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const JoinRoomScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/lobby',
      pageBuilder: (context, state) {
        final roomCode = state.extra as String? ?? '';
        return _buildPageWithTransition(
          child: LobbyScreen(roomCode: roomCode),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/task',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return _buildPageWithTransition(
          child: TaskScreen(
            gameId: extra['gameId'] ?? '',
            roomCode: extra['roomCode'] ?? '',
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/performing',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return _buildPageWithTransition(
          child: PerformingScreen(
            gameId: extra['gameId'] ?? '',
            roomCode: extra['roomCode'] ?? '',
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/voting',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return _buildPageWithTransition(
          child: VotingScreen(
            gameId: extra['gameId'] ?? '',
            roomCode: extra['roomCode'] ?? '',
          ),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/waiting',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return _buildPageWithTransition(
          child: WaitingScreen(
            gameId: extra['gameId'] ?? '',
            roomCode: extra['roomCode'] ?? '',
          ),
          state: state,
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
      pageBuilder: (context, state) {
        final extra = state.extra as String? ?? '';
        return _buildPageWithTransition(
          child: GameOverScreen(roomCode: extra),
          state: state,
        );
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
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return _buildPageWithTransition(
          child: EconomyPickScreen(
            gameId: extra['gameId'] as String? ?? '',
            roomCode: extra['roomCode'] as String? ?? '',
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
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
          child: child,
        ),
      );
    },
  );
}
