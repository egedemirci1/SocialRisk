class UserEntity {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int walletPoints;
  final String rank;

  const UserEntity({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Newbie',
  });
}
