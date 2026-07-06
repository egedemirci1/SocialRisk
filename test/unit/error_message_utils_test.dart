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
  });
}
