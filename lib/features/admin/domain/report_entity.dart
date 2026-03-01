import 'package:cloud_firestore/cloud_firestore.dart';

class ReportEntity {
  final String id;
  final String reporterId;
  final String targetUserId;
  final String targetUserName;
  final String targetUserAvatar;
  final String reason;
  final DateTime createdAt;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserAvatar,
    required this.reason,
    required this.createdAt,
  });

  factory ReportEntity.fromJson(Map<String, dynamic> json, String documentId) {
    return ReportEntity(
      id: documentId,
      reporterId: json['reporterId'] as String? ?? '',
      targetUserId: json['targetUserId'] as String? ?? '',
      targetUserName: json['targetUserName'] as String? ?? 'Bilinmeyen Kullanıcı',
      targetUserAvatar: json['targetUserAvatar'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
