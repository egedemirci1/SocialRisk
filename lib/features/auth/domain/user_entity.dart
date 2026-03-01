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
}
