enum GameMode {
  classic,
  economy, // Faz 10: Strateji modu
  toxic,   // Gelecek planı
  custom   // Gelecek planı
}

/// İçerik preset'i — odadaki görev havuzunu belirler.
enum GamePreset {
  classic,  // Tüm kategoriler, genel içerik
  family,   // Aile dostu (PG)
  couple,   // Sevgili modu
  adult     // Yetişkin (18+)
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
  choosingDifficulty, // Yeni: Çark/kategori sonrası zorluk seçimi
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
