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

  const UserEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Çırak',
    this.ownedCosmetics = const [],
    this.ownedCategories = GameConstants.defaultCategories,
    this.activeFrame,
    this.activeTitle,
  });

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
    );
  }
}
