import 'dart:math';

class AppHelpers {
  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  static int calculatePenalty(int basePenalty, int passStreak) {
    if (passStreak <= 0) return 0;
    // penalty = basePenalty * (3 ^ (passStreak - 1))
    return basePenalty * pow(3, passStreak - 1).toInt();
  }

  static String formatTimestamp(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
