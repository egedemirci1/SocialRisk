/// Singleton class to hold a pending toast message that should be shown
/// after navigation completes (e.g., after login redirects to home).
class PendingToast {
  PendingToast._();
  static final PendingToast instance = PendingToast._();

  String? _message;
  bool _isSuccess = true;

  void setSuccess(String message) {
    _message = message;
    _isSuccess = true;
  }

  void setError(String message) {
    _message = message;
    _isSuccess = false;
  }

  /// Returns the pending message and clears it.
  (String, bool)? consume() {
    if (_message == null) return null;
    final msg = _message!;
    final success = _isSuccess;
    _message = null;
    return (msg, success);
  }
}
