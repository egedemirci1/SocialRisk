import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/errors/app_exception.dart';
import 'package:social_risk/features/economy/domain/economy_exceptions.dart';
import 'package:social_risk/l10n/app_localizations_en.dart';
import 'package:social_risk/shared/utils/error_message_utils.dart';

void main() {
  final l = AppLocalizationsEn();

  group('ErrorMessageUtils', () {
    test('maps Firebase permission-denied to localized message', () {
      final message = ErrorMessageUtils.formatUserError(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
        l,
      );
      expect(message, l.errorPermissionDenied);
    });

    test('maps Firebase unknown code to generic message', () {
      final message = ErrorMessageUtils.formatUserError(
        FirebaseException(
          plugin: 'firestore',
          code: 'internal',
          message: 'INTERNAL: server exploded',
        ),
        l,
      );
      expect(message, l.errorUnknown);
    });

    test('maps economy exceptions to localized messages', () {
      expect(
        ErrorMessageUtils.formatUserError(
          const InsufficientBalanceException(),
          l,
        ),
        l.insufficientBalance,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AlreadyOwnedCosmeticException(),
          l,
        ),
        l.errorAlreadyOwned,
      );
    });

    test('maps AppException connection errors to network message', () {
      final message = ErrorMessageUtils.formatUserError(
        const AppException(
          AppErrorCode.joinRoomConnectionError,
          {'message': 'UNAVAILABLE: backend down'},
        ),
        l,
      );
      expect(message, l.errorNetwork);
    });

    test('sanitizes raw technical exception text', () {
      final message = ErrorMessageUtils.formatUserError(
        Exception('FirebaseException: permission-denied'),
        l,
      );
      expect(message, l.errorPermissionDenied);
    });

    test('keeps user-facing domain messages', () {
      final message = ErrorMessageUtils.formatUserError(
        Exception('Bu kategori kilitli!'),
        l,
      );
      expect(message, 'Bu kategori kilitli!');
    });

    test('maps remaining AppException codes to localized messages', () {
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.categoryNotSelected),
          l,
        ),
        l.errorCategoryNotSelected,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.noTasksInCategory),
          l,
        ),
        l.errorNoTasksInCategory,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.gameNotFound),
          l,
        ),
        l.errorGameNotFound,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.categoryLocked),
          l,
        ),
        l.errorCategoryLocked,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.gameAlreadyStarted),
          l,
        ),
        l.errorGameAlreadyStarted,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.minPlayersToStart),
          l,
        ),
        l.errorMinPlayersToStart,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.roomNotFound, {'code': 'ABC123'}),
          l,
        ),
        l.errorRoomNotFound('ABC123'),
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.roomFull, {'max': 8}),
          l,
        ),
        l.errorRoomFull(8),
      );
      expect(
        ErrorMessageUtils.formatUserError(
          const AppException(AppErrorCode.emoteCooldown, {'seconds': 5}),
          l,
        ),
        l.sendEmoteCooldown(5),
      );
    });

    test('maps saveResults and leaveRoom with custom message', () {
      final save = ErrorMessageUtils.formatUserError(
        const AppException(AppErrorCode.saveResultsError, {'message': 'Kayıt hatası'}),
        l,
      );
      expect(save, l.errorSaveResults('Kayıt hatası'));

      final leave = ErrorMessageUtils.formatUserError(
        const AppException(AppErrorCode.leaveRoomError, {'message': 'Oda hatası'}),
        l,
      );
      expect(leave, l.errorLeaveRoom('Oda hatası'));
    });

    test('maps additional Firebase codes', () {
      expect(
        ErrorMessageUtils.formatUserError(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
          l,
        ),
        l.errorServiceUnavailable,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          FirebaseException(plugin: 'firestore', code: 'not-found'),
          l,
        ),
        l.errorNotFound,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          FirebaseException(plugin: 'firestore', code: 'deadline-exceeded'),
          l,
        ),
        l.errorRequestTimedOut,
      );
      expect(
        ErrorMessageUtils.formatUserError(
          FirebaseException(plugin: 'auth', code: 'network-request-failed'),
          l,
        ),
        l.errorNetwork,
      );
    });

    test('maps economy UserNotFoundException', () {
      expect(
        ErrorMessageUtils.formatUserError(const UserNotFoundException(), l),
        l.errorUserNotFound,
      );
    });

    test('parses emote cooldown from raw exception text', () {
      expect(
        ErrorMessageUtils.formatUserError(Exception('Cooldown:12'), l),
        l.sendEmoteCooldown(12),
      );
    });

    test('sanitizes network and permission raw messages', () {
      expect(
        ErrorMessageUtils.formatUserError(Exception('bağlantı koptu'), l),
        l.errorNetwork,
      );
      expect(
        ErrorMessageUtils.formatUserError(Exception('permission denied'), l),
        l.errorPermissionDenied,
      );
      expect(
        ErrorMessageUtils.formatUserError(Exception(''), l),
        l.errorUnknown,
      );
    });

    test('uses user-facing prefix when suffix is technical', () {
      expect(
        ErrorMessageUtils.formatUserError(
          Exception('Giriş başarısız: SocketException failed host lookup'),
          l,
        ),
        'Giriş başarısız',
      );
    });
  });
}
