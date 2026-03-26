import '../../../core/constants/game_constants.dart';

/// Sentinel class to distinguish between "not passed" and "explicitly null".
class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}

class UserEntity {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int walletPoints;
  final String rank;
  final List<String> ownedCosmetics;
  final List<String> ownedCategories;
  final String? activeFrame;
  final String? activeTitle;
  final Map<String, int> stats;

  const UserEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Çırak',
    this.ownedCosmetics = const [],
    this.ownedCategories = GameConstants.defaultCategoriesConst,
    this.activeFrame,
    this.activeTitle,
    this.stats = const {},
  });

  /// 5 Kategorinin toplam seviye değerine göre dinamik Parti Rütbesini hesaplar.
  String get calculatedRank {
    // İngilizce çeviri için
    final rankEn = calculatedRankEn;
    return rankEn;
  }

  // İngilizce rütbeler
  String get calculatedRankEn {
    int totalLevels = 0;

    // Görev Ustası (Özel Görevler)
    final customTasks = stats['custom_tasks_created'] ?? 0;
    if (customTasks >= 50) totalLevels += 4;
    else if (customTasks >= 20) totalLevels += 3;
    else if (customTasks >= 5) totalLevels += 2;
    // 0 is not tier 1, tier 1 requires 1 task.
    else if (customTasks >= 1) totalLevels += 1;

    // Sosyal İkon (Eşyalar)
    final itemsCount = ownedCosmetics.length;
    if (itemsCount >= 10) totalLevels += 4;
    else if (itemsCount >= 5) totalLevels += 3;
    else if (itemsCount >= 3) totalLevels += 2;
    else if (itemsCount >= 1) totalLevels += 1;

    // Parti Canavarı (Oynanan Oyun)
    final gamesPlayed = stats['games_played'] ?? 0;
    if (gamesPlayed >= 50) totalLevels += 4;
    else if (gamesPlayed >= 25) totalLevels += 3;
    else if (gamesPlayed >= 10) totalLevels += 2;
    else if (gamesPlayed >= 1) totalLevels += 1;

    // VIP (Güncel Bakiye)
    final balance = walletPoints;
    if (balance >= 5000) totalLevels += 4;
    else if (balance >= 1000) totalLevels += 3;
    else if (balance >= 500) totalLevels += 2;
    else if (balance >= 100) totalLevels += 1;

    // Halkın Sesi (Verilen Oylar)
    final votesGiven = stats['votes_given'] ?? 0;
    if (votesGiven >= 100) totalLevels += 4;
    else if (votesGiven >= 50) totalLevels += 3;
    else if (votesGiven >= 20) totalLevels += 2;
    else if (votesGiven >= 5) totalLevels += 1;

    // İngilizce Rütbe Kararı
    if (totalLevels >= 18) return 'Legend';
    if (totalLevels >= 13) return 'King';
    if (totalLevels >= 7) return 'Star';
    if (totalLevels >= 3) return 'Fun';
    return 'Beginner';
  }

  // Türkçe rütbeler (locale için)
  String get calculatedRankTr {
    int totalLevels = 0;

    // Görev Ustası (Özel Görevler)
    final customTasks = stats['custom_tasks_created'] ?? 0;
    if (customTasks >= 50) totalLevels += 4;
    else if (customTasks >= 20) totalLevels += 3;
    else if (customTasks >= 5) totalLevels += 2;
    // 0 is not tier 1, tier 1 requires 1 task.
    else if (customTasks >= 1) totalLevels += 1;

    // Sosyal İkon (Eşyalar)
    final itemsCount = ownedCosmetics.length;
    if (itemsCount >= 10) totalLevels += 4;
    else if (itemsCount >= 5) totalLevels += 3;
    else if (itemsCount >= 3) totalLevels += 2;
    else if (itemsCount >= 1) totalLevels += 1;

    // Parti Canavarı (Oynanan Oyun)
    final gamesPlayed = stats['games_played'] ?? 0;
    if (gamesPlayed >= 50) totalLevels += 4;
    else if (gamesPlayed >= 25) totalLevels += 3;
    else if (gamesPlayed >= 10) totalLevels += 2;
    else if (gamesPlayed >= 1) totalLevels += 1;

    // VIP (Güncel Bakiye)
    final balance = walletPoints;
    if (balance >= 5000) totalLevels += 4;
    else if (balance >= 1000) totalLevels += 3;
    else if (balance >= 500) totalLevels += 2;
    else if (balance >= 100) totalLevels += 1;

    // Halkın Sesi (Verilen Oylar)
    final votesGiven = stats['votes_given'] ?? 0;
    if (votesGiven >= 100) totalLevels += 4;
    else if (votesGiven >= 50) totalLevels += 3;
    else if (votesGiven >= 20) totalLevels += 2;
    else if (votesGiven >= 5) totalLevels += 1;

    // Türkçe Rütbe Kararı
    if (totalLevels >= 18) return 'Efsane';
    if (totalLevels >= 13) return 'Kral';
    if (totalLevels >= 7) return 'Yıldız';
    if (totalLevels >= 3) return 'Eğlenceli';
    return 'Çaylak';
  }

  UserEntity copyWith({
    String? uid,
    String? displayName,
    Nullable<String>? avatarUrl,
    int? walletPoints,
    String? rank,
    List<String>? ownedCosmetics,
    List<String>? ownedCategories,
    Nullable<String>? activeFrame,
    Nullable<String>? activeTitle,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl != null ? avatarUrl.value : this.avatarUrl,
      walletPoints: walletPoints ?? this.walletPoints,
      rank: rank ?? this.rank,
      ownedCosmetics: ownedCosmetics ?? this.ownedCosmetics,
      ownedCategories: ownedCategories ?? this.ownedCategories,
      activeFrame: activeFrame != null ? activeFrame.value : this.activeFrame,
      activeTitle: activeTitle != null ? activeTitle.value : this.activeTitle,
      stats: this.stats, // Default stats logic
    );
  }
}
