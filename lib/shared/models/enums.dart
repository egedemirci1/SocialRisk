enum GameMode {
  classic,
  toxic,   // Gelecek planı
  custom   // Gelecek planı
}

enum GameDifficulty {
  easy,    // Kolay - multiplier 1
  medium,  // Orta - multiplier 2
  hard,    // Zor - multiplier 3
  mixed    // Karışık - hepsi
}

enum GameStatus {
  waiting,
  playing,
  performing,
  voting,
  results,
  finished
}

enum VoteValue {
  like,
  neutral,
  dislike
}

enum EndConditionType {
  score,
  rounds
}

enum RoomVisibility {
  open,   // İçerik önceden görünür
  closed  // Sadece kategori + çarpan görünür
}
