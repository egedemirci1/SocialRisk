/// Base exception for economy-related errors.
sealed class EconomyException implements Exception {
  final String message;
  const EconomyException(this.message);
  @override
  String toString() => message;
}

/// Thrown when user has insufficient wallet balance for a purchase.
final class InsufficientBalanceException extends EconomyException {
  const InsufficientBalanceException([super.message = 'Yetersiz bakiye.']);
}

/// Thrown when user already owns the cosmetic item.
final class AlreadyOwnedCosmeticException extends EconomyException {
  const AlreadyOwnedCosmeticException(
      [super.message = 'Bu eşyaya zaten sahipsiniz.']);
}

/// Thrown when the user document is not found.
final class UserNotFoundException extends EconomyException {
  const UserNotFoundException([super.message = 'Kullanıcı bulunamadı.']);
}
