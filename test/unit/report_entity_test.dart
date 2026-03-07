import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/admin/domain/report_entity.dart';

void main() {
  group('ReportEntity', () {
    test('fromJson tüm alanları doğru parse etmeli', () {
      final createdAt = DateTime(2024, 5, 10, 14, 30);
      final json = {
        'reporterId': 'rep_1',
        'targetUserId': 'target_1',
        'targetUserName': 'Hedef Kullanıcı',
        'targetUserAvatar': 'https://avatar.png',
        'reason': 'Spam',
        'createdAt': Timestamp.fromDate(createdAt),
      };

      final entity = ReportEntity.fromJson(json, 'report_doc_1');

      expect(entity.id, 'report_doc_1');
      expect(entity.reporterId, 'rep_1');
      expect(entity.targetUserId, 'target_1');
      expect(entity.targetUserName, 'Hedef Kullanıcı');
      expect(entity.targetUserAvatar, 'https://avatar.png');
      expect(entity.reason, 'Spam');
      expect(entity.createdAt, createdAt);
    });

    test('fromJson eksik alanlarda varsayılan değer kullanmalı', () {
      final entity = ReportEntity.fromJson({}, 'doc_id');

      expect(entity.id, 'doc_id');
      expect(entity.reporterId, '');
      expect(entity.targetUserId, '');
      expect(entity.targetUserName, 'Bilinmeyen Kullanıcı');
      expect(entity.targetUserAvatar, '');
      expect(entity.reason, '');
      expect(entity.createdAt, isA<DateTime>());
    });

    test('fromJson createdAt yoksa DateTime.now kullanmalı', () {
      final before = DateTime.now();
      final entity = ReportEntity.fromJson({
        'reporterId': 'r',
        'targetUserId': 't',
        'targetUserName': 'X',
        'targetUserAvatar': '',
        'reason': 'R',
      }, 'id');
      final after = DateTime.now();

      expect(
        entity.createdAt.isAfter(before.subtract(const Duration(seconds: 1))) &&
            entity.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
