import '../../room/domain/room_entity.dart';
import 'game_entity.dart';
import '../../../shared/models/enums.dart';

/// Tek noktadan "oyun bu tur sonunda bitmeli mi?" kararını verir.
class GameEndUtils {
  static int comparePlayersForFinalRanking(
    PlayerEntity a,
    PlayerEntity b,
  ) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    final likesCompare = b.totalLikes.compareTo(a.totalLikes);
    if (likesCompare != 0) return likesCompare;
    return a.id.compareTo(b.id);
  }

  static bool shouldEndAfterRound({
    required GameEntity game,
    required RoomEntity room,
    required List<PlayerEntity> players,
  }) {
    if (room.endConditionType == EndConditionType.rounds) {
      final activePlayerIds = players.map((p) => p.id).toSet();
      final orderSource = game.mode == GameMode.economy
          ? game.categoryPickOrder
          : game.turnOrder;
      final activeOrder =
          orderSource.where((id) => activePlayerIds.contains(id)).toList();
      final roundPlayerId = game.lastRoundPlayerId ?? game.currentPlayerId;
      final isLastActive = activeOrder.isNotEmpty && activeOrder.last == roundPlayerId;
      return game.currentRound >= room.endConditionValue && isLastActive;
    }

    final activePlayerIds = players.map((p) => p.id).toSet();
    final orderSource = game.mode == GameMode.economy
        ? game.categoryPickOrder
        : game.turnOrder;
    final activeOrder =
        orderSource.where((id) => activePlayerIds.contains(id)).toList();
    final roundPlayerId = game.lastRoundPlayerId ?? game.currentPlayerId;
    final isLastActive = activeOrder.isNotEmpty && activeOrder.last == roundPlayerId;

    return isLastActive && players.any((p) => p.score >= room.endConditionValue);
  }
}
