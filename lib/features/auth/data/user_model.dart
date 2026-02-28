import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int walletPoints;
  final String rank;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    this.walletPoints = 0,
    this.rank = 'Newbie',
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      uid: docId,
      displayName: json['displayName'] as String? ?? 'Misafir',
      avatarUrl: json['avatarUrl'] as String?,
      walletPoints: json['walletPoints'] as int? ?? 0,
      rank: json['rank'] as String? ?? 'Newbie',
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'walletPoints': walletPoints,
      'rank': rank,
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
    );
  }
}
