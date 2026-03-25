import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';
import '../../../core/constants/game_constants.dart';

class UserModel {
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
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Utangaç (Çaylak)',
    this.ownedCosmetics = const [],
    this.ownedCategories = GameConstants.defaultCategoriesConst,
    this.activeFrame,
    this.activeTitle,
    this.stats = const {},
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      uid: docId,
      displayName: json['displayName'] as String? ?? 'Misafir',
      avatarUrl: json['avatarUrl'] as String?,
      walletPoints: json['walletPoints'] as int? ?? 0,
      rank: json['rank'] as String? ?? 'Newbie',
      ownedCosmetics:
          (json['ownedCosmetics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ownedCategories:
          (json['ownedCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          GameConstants.defaultCategories,
      activeFrame: json['activeFrame'] as String?,
      activeTitle: json['activeTitle'] as String?,
      stats: json['stats'] != null 
          ? Map<String, int>.from(json['stats'] as Map)
          : const {},
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'walletPoints': walletPoints,
      'rank': rank,
      'ownedCosmetics': ownedCosmetics,
      'ownedCategories': ownedCategories,
      'activeFrame': activeFrame,
      'activeTitle': activeTitle,
      'stats': stats,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      displayName: displayName,
      avatarUrl: avatarUrl,
      walletPoints: walletPoints,
      rank: rank,
      ownedCosmetics: ownedCosmetics,
      ownedCategories: ownedCategories,
      activeFrame: activeFrame,
      activeTitle: activeTitle,
      stats: stats,
    );
  }
}
