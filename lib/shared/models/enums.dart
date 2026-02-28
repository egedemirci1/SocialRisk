enum GameMode {
  classic,
  toxic,   // Gelecek planı
  custom   // Gelecek planı
}

enum GameStatus {
  waiting,
  playing,
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
