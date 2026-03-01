class GameConstants {
  static const int minPlayers = 2;
  static const int maxPlayers = 8;
  
  static const int defaultTargetScore = 500;
  static const int defaultMaxRounds = 10;
  
  static const int basePenalty = 50;
  static const int voteMultiplierLike = 2;
  static const int voteMultiplierNeutral = 1;
  static const int voteMultiplierDislike = 0;
  
  static const Duration voteDuration = Duration(seconds: 15);
  static const Duration lobbyRefreshRate = Duration(seconds: 2);
}
