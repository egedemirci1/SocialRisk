class UserEntity {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int walletPoints;
  final String rank;
  final List<String> ownedCosmetics;
  final String? activeFrame;
  final String? activeTitle;

  const UserEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Newbie',
    this.ownedCosmetics = const [],
    this.activeFrame,
    this.activeTitle,
  });

  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? avatarUrl,
    int? walletPoints,
    String? rank,
    List<String>? ownedCosmetics,
    String? activeFrame,
    String? activeTitle,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      walletPoints: walletPoints ?? this.walletPoints,
      rank: rank ?? this.rank,
      ownedCosmetics: ownedCosmetics ?? this.ownedCosmetics,
      activeFrame: activeFrame ?? this.activeFrame,
      activeTitle: activeTitle ?? this.activeTitle,
    );
  }
}
