/// Uygulama katmanında fırlatılan, l10n ile eşleşen hata kodları.
class AppErrorCode {
  AppErrorCode._();

  static const categoryNotSelected = 'category_not_selected';
  static const noTasksInCategory = 'no_tasks_in_category';
  static const taskSelectConnectionError = 'task_select_connection_error';
  static const saveResultsError = 'save_results_error';
  static const saveResultsUnexpectedError = 'save_results_unexpected_error';
  static const turnAdvanceConnectionError = 'turn_advance_connection_error';
  static const gameNotFound = 'game_not_found';
  static const categoryLocked = 'category_locked';
  static const categorySelectConnectionError = 'category_select_connection_error';
  static const assignCategoryConnectionError = 'assign_category_connection_error';
  static const skipTaskError = 'skip_task_error';
  static const skipTaskUnexpectedError = 'skip_task_unexpected_error';
  static const removePlayerError = 'remove_player_error';

  static const createRoomConnectionError = 'create_room_connection_error';
  static const createRoomFailed = 'create_room_failed';
  static const roomNotFound = 'room_not_found';
  static const roomFull = 'room_full';
  static const joinRoomConnectionError = 'join_room_connection_error';
  static const leaveRoomError = 'leave_room_error';
  static const readyStatusError = 'ready_status_error';
  static const emoteCooldown = 'emote_cooldown';
  static const emoteSendError = 'emote_send_error';
  static const roomVisibilityError = 'room_visibility_error';
  static const roomStatusError = 'room_status_error';
  static const gameAlreadyStarted = 'game_already_started';
  static const minPlayersToStart = 'min_players_to_start';
  static const startGameTransactionError = 'start_game_transaction_error';
  static const startGameFailed = 'start_game_failed';
}

class AppException implements Exception {
  final String code;
  final Map<String, Object?> params;

  const AppException(this.code, [this.params = const {}]);

  @override
  String toString() => code;
}
