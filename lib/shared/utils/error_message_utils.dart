import 'package:firebase_core/firebase_core.dart';

import '../../core/errors/app_exception.dart';
import '../../features/economy/domain/economy_exceptions.dart';
import '../../l10n/app_localizations.dart';

/// Kullanıcıya gösterilecek hata metinlerini normalize eder.
class ErrorMessageUtils {
  ErrorMessageUtils._();

  static final _technicalPattern = RegExp(
    r'(firebase|grpc|permission[-_ ]denied|unavailable|deadline[-_ ]exceeded|'
    r'not[-_ ]found|socketexception|clientexception|platformexception|'
    r'failed host lookup|connection (refused|reset|closed)|'
    r'unauthenticated|internal error|unknown error|status code|'
    r'\[cloud_firestore|\[firebase_auth|apiexception|sign_in_failed)',
    caseSensitive: false,
  );

  static String formatUserError(Object error, AppLocalizations l10n) {
    if (error is AppException) {
      return _localizeAppException(error, l10n);
    }

    if (error is EconomyException) {
      return _localizeEconomyException(error, l10n);
    }

    if (error is FirebaseException) {
      return _formatFirebaseException(error, l10n);
    }

    var message = error.toString();
    message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    message = message.replaceFirst(RegExp(r'^FirebaseException:\s*'), '');

    final cooldownSeconds = _parseEmoteCooldownSeconds(message);
    if (cooldownSeconds != null) {
      return l10n.sendEmoteCooldown(cooldownSeconds);
    }

    return _sanitizeRawMessage(message, l10n);
  }

  static String _localizeEconomyException(
    EconomyException error,
    AppLocalizations l10n,
  ) {
    if (error is InsufficientBalanceException) {
      return l10n.insufficientBalance;
    }
    if (error is AlreadyOwnedCosmeticException) {
      return l10n.errorAlreadyOwned;
    }
    if (error is UserNotFoundException) {
      return l10n.errorUserNotFound;
    }
    return l10n.errorUnknown;
  }

  static String _localizeAppException(
    AppException error,
    AppLocalizations l10n,
  ) {
    final message = _safeParam(_stringParam(error, 'message'));
    final detail = _safeParam(_stringParam(error, 'error'));
    final code = _stringParam(error, 'code');

    return switch (error.code) {
      AppErrorCode.categoryNotSelected => l10n.errorCategoryNotSelected,
      AppErrorCode.noTasksInCategory => l10n.errorNoTasksInCategory,
      AppErrorCode.taskSelectConnectionError => l10n.errorNetwork,
      AppErrorCode.saveResultsError => _withMessageOrFallback(
          message,
          l10n.errorSaveResults,
          l10n.errorUnknown,
        ),
      AppErrorCode.saveResultsUnexpectedError => _withMessageOrFallback(
          detail,
          l10n.errorSaveResultsUnexpected,
          l10n.errorUnknown,
        ),
      AppErrorCode.turnAdvanceConnectionError => l10n.errorNetwork,
      AppErrorCode.gameNotFound => l10n.errorGameNotFound,
      AppErrorCode.categoryLocked => l10n.errorCategoryLocked,
      AppErrorCode.categorySelectConnectionError => l10n.errorNetwork,
      AppErrorCode.assignCategoryConnectionError => l10n.errorNetwork,
      AppErrorCode.skipTaskError => _withMessageOrFallback(
          message,
          l10n.errorSkipTask,
          l10n.errorUnknown,
        ),
      AppErrorCode.skipTaskUnexpectedError => _withMessageOrFallback(
          detail,
          l10n.errorSkipTaskUnexpected,
          l10n.errorUnknown,
        ),
      AppErrorCode.removePlayerError => _withMessageOrFallback(
          message,
          l10n.errorRemovePlayer,
          l10n.errorUnknown,
        ),
      AppErrorCode.createRoomConnectionError => l10n.errorNetwork,
      AppErrorCode.createRoomFailed => _withMessageOrFallback(
          detail,
          l10n.errorCreateRoomFailed,
          l10n.errorUnknown,
        ),
      AppErrorCode.roomNotFound => l10n.errorRoomNotFound(code),
      AppErrorCode.roomFull => l10n.errorRoomFull(
          _intParam(error, 'max', fallback: 0),
        ),
      AppErrorCode.joinRoomConnectionError => l10n.errorNetwork,
      AppErrorCode.leaveRoomError => _withMessageOrFallback(
          message,
          l10n.errorLeaveRoom,
          l10n.errorUnknown,
        ),
      AppErrorCode.readyStatusError => _withMessageOrFallback(
          message,
          l10n.errorReadyStatus,
          l10n.errorUnknown,
        ),
      AppErrorCode.emoteCooldown => l10n.sendEmoteCooldown(
          _intParam(error, 'seconds', fallback: 0),
        ),
      AppErrorCode.emoteSendError => _withMessageOrFallback(
          message,
          l10n.errorEmoteSend,
          l10n.errorUnknown,
        ),
      AppErrorCode.roomVisibilityError => _withMessageOrFallback(
          message,
          l10n.errorRoomVisibility,
          l10n.errorUnknown,
        ),
      AppErrorCode.roomStatusError => _withMessageOrFallback(
          message,
          l10n.errorRoomStatus,
          l10n.errorUnknown,
        ),
      AppErrorCode.gameAlreadyStarted => l10n.errorGameAlreadyStarted,
      AppErrorCode.minPlayersToStart => l10n.errorMinPlayersToStart,
      AppErrorCode.startGameTransactionError => l10n.errorNetwork,
      AppErrorCode.startGameFailed => _withMessageOrFallback(
          detail,
          l10n.errorStartGameFailed,
          l10n.errorUnknown,
        ),
      _ => l10n.errorUnknown,
    };
  }

  static String _formatFirebaseException(
    FirebaseException error,
    AppLocalizations l10n,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return l10n.errorPermissionDenied;
      case 'unavailable':
        return l10n.errorServiceUnavailable;
      case 'not-found':
        return l10n.errorNotFound;
      case 'deadline-exceeded':
        return l10n.errorRequestTimedOut;
      case 'unauthenticated':
        return l10n.errorPermissionDenied;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorUnknown;
    }
  }

  static String _sanitizeRawMessage(String message, AppLocalizations l10n) {
    if (message.isEmpty) return l10n.errorUnknown;

    if (_isNetworkMessage(message)) return l10n.errorNetwork;
    if (_isPermissionMessage(message)) return l10n.errorPermissionDenied;

    final colonMatch = RegExp(r'^(.+?):\s*(.+)$').firstMatch(message);
    if (colonMatch != null) {
      final prefix = colonMatch.group(1)!.trim();
      final suffix = colonMatch.group(2)!.trim();
      if (_isTechnical(suffix)) {
        if (_isNetworkMessage(prefix) || _isNetworkMessage(message)) {
          return l10n.errorNetwork;
        }
        if (!_isTechnical(prefix) && prefix.length <= 120) {
          return prefix;
        }
        return l10n.errorUnknown;
      }
    }

    if (_isTechnical(message)) return l10n.errorUnknown;

    return message;
  }

  static String _withMessageOrFallback(
    String message,
    String Function(String message) withMessage,
    String fallback,
  ) {
    if (message.isEmpty) return fallback;
    return withMessage(message);
  }

  static String _safeParam(String value) {
    if (value.isEmpty || _isTechnical(value)) return '';
    return value;
  }

  static int? _parseEmoteCooldownSeconds(String message) {
    final match = RegExp(r'Cooldown:(\d+)').firstMatch(message);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  static bool _isTechnical(String text) => _technicalPattern.hasMatch(text);

  static bool _isNetworkMessage(String text) {
    final lower = text.toLowerCase();
    return lower.contains('network') ||
        lower.contains('unavailable') ||
        lower.contains('connection') ||
        lower.contains('bağlantı') ||
        lower.contains('internet');
  }

  static bool _isPermissionMessage(String text) {
    final lower = text.toLowerCase();
    return lower.contains('permission') || lower.contains('yetki');
  }

  static String _stringParam(
    AppException error,
    String key, {
    String fallback = '',
  }) {
    final value = error.params[key];
    if (value == null) return fallback;
    return value.toString();
  }

  static int _intParam(
    AppException error,
    String key, {
    required int fallback,
  }) {
    final value = error.params[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
