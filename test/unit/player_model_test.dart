import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/room/data/room_model.dart';

/// PlayerModel Unit Testleri
void main() {
  group('PlayerModel', () {
    // ─────────── fromJson ───────────
    group('fromJson', () {
      test('tam JSON verildiğinde tüm alanlar doğru parse edilmeli', () {
        final json = {
          'displayName': 'Ege',
          'avatarUrl': 'https://example.com/avatar.png',
          'activeFrame': 'gold_frame',
          'activeTitle': 'Şampiyon',
          'score': 150,
          'passStreak': 2,
          'isReady': true,
        };
        final player = PlayerModel.fromJson(json, 'uid_123');

        expect(player.id, 'uid_123');
        expect(player.displayName, 'Ege');
        expect(player.avatarUrl, 'https://example.com/avatar.png');
        expect(player.activeFrame, 'gold_frame');
        expect(player.activeTitle, 'Şampiyon');
        expect(player.score, 150);
        expect(player.passStreak, 2);
        expect(player.isReady, true);
      });

      test('eksik alanlar varsayılan değerlerle doldurulmalı', () {
        final player = PlayerModel.fromJson({}, 'uid_empty');

        expect(player.id, 'uid_empty');
        expect(player.displayName, 'Oyuncu'); // Varsayılan
        expect(player.avatarUrl, isNull);
        expect(player.activeFrame, isNull);
        expect(player.activeTitle, isNull);
        expect(player.score, 0);
        expect(player.passStreak, 0);
        expect(player.isReady, false);
      });

      test('displayName null gelirse "Oyuncu" varsayılmalı', () {
        final player = PlayerModel.fromJson({'displayName': null}, 'uid_null');
        expect(player.displayName, 'Oyuncu');
      });

      test('score null gelirse 0 varsayılmalı', () {
        final player = PlayerModel.fromJson({'score': null}, 'uid_score');
        expect(player.score, 0);
      });

      test('negatif score kabul edilmeli', () {
        final player = PlayerModel.fromJson({'score': -50}, 'uid_neg');
        expect(player.score, -50);
      });
    });

    // ─────────── toJson ───────────
    group('toJson', () {
      test('tüm alanları doğru JSON\'a serileştirmeli', () {
        const player = PlayerModel(
          id: 'uid_1',
          displayName: 'Test',
          avatarUrl: 'url',
          activeFrame: 'frame',
          activeTitle: 'title',
          score: 100,
          passStreak: 3,
          isReady: true,
        );
        final json = player.toJson();

        expect(json['displayName'], 'Test');
        expect(json['avatarUrl'], 'url');
        expect(json['activeFrame'], 'frame');
        expect(json['activeTitle'], 'title');
        expect(json['score'], 100);
        expect(json['passStreak'], 3);
        expect(json['isReady'], true);
        // id toJson'da olmamalı (docId olarak kullanılır)
        expect(json.containsKey('id'), isFalse);
      });

      test('null alanlar JSON\'da null olarak bulunmalı', () {
        const player = PlayerModel(
          id: 'uid_2',
          displayName: 'X',
        );
        final json = player.toJson();
        expect(json['avatarUrl'], isNull);
        expect(json['activeFrame'], isNull);
        expect(json['activeTitle'], isNull);
      });
    });

    // ─────────── toEntity ───────────
    group('toEntity', () {
      test('model → entity dönüşümü tüm alanları korumalı', () {
        const player = PlayerModel(
          id: 'uid_e',
          displayName: 'EntityTest',
          avatarUrl: 'http://img.png',
          activeFrame: 'frame_a',
          activeTitle: 'Kral',
          score: 250,
          passStreak: 1,
          isReady: true,
        );
        final entity = player.toEntity();

        expect(entity.id, 'uid_e');
        expect(entity.displayName, 'EntityTest');
        expect(entity.avatarUrl, 'http://img.png');
        expect(entity.activeFrame, 'frame_a');
        expect(entity.activeTitle, 'Kral');
        expect(entity.score, 250);
        expect(entity.passStreak, 1);
        expect(entity.isReady, true);
      });
    });

    // ─────────── Round-trip ───────────
    group('round-trip', () {
      test('fromJson → toJson tutarlılığı', () {
        final originalJson = {
          'displayName': 'RoundTrip',
          'avatarUrl': 'https://test.com/a.jpg',
          'activeFrame': null,
          'activeTitle': 'Veteran',
          'score': 500,
          'passStreak': 0,
          'isReady': false,
        };
        final player = PlayerModel.fromJson(originalJson, 'rt_uid');
        final outputJson = player.toJson();

        expect(outputJson['displayName'], originalJson['displayName']);
        expect(outputJson['avatarUrl'], originalJson['avatarUrl']);
        expect(outputJson['score'], originalJson['score']);
        expect(outputJson['passStreak'], originalJson['passStreak']);
        expect(outputJson['isReady'], originalJson['isReady']);
      });
    });
  });
}
