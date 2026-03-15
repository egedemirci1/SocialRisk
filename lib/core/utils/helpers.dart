import 'dart:math';

class AppHelpers {
  static final Random _rng = Random();

  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (index) => chars[_rng.nextInt(chars.length)],
    ).join();
  }

  /// Pas geçme cezası: her zaman sabit basePenalty (katlanmaz).
  /// Task: -50 katlanarak artma hatası — hep -50 kalmalı.
  static int calculatePenalty(int basePenalty, int passStreak) {
    if (passStreak <= 0) return 0;
    return basePenalty;
  }

  static String formatTimestamp(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
