import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/game_constants.dart';
import 'package:social_risk/features/auth/data/user_model.dart';

void main() {
  final fixedDate = DateTime(2024, 4, 10, 8, 0);

  group('UserModel', () {
    test('fromJson tüm alanları doğru parse etmeli', () {
      final json = {
        'displayName': 'Test Kullanıcı',
        'avatarUrl': 'https://photo.jpg',
        'walletPoints': 750,
        'rank': 'Usta',
        'ownedCosmetics': ['frame_fire', 'title_king'],
        'ownedCategories': ['Fiziksel', 'Bilgi', 'Dijital'],
        'activeFrame': 'frame_ice',
        'activeTitle': 'Kral',
        'updatedAt': Timestamp.fromDate(fixedDate),
      };

      final model = UserModel.fromJson(json, 'user_doc_1');

      expect(model.uid, 'user_doc_1');
      expect(model.displayName, 'Test Kullanıcı');
      expect(model.avatarUrl, 'https://photo.jpg');
      expect(model.walletPoints, 750);
      expect(model.rank, 'Usta');
      expect(model.ownedCosmetics, ['frame_fire', 'title_king']);
      expect(model.ownedCategories, ['Fiziksel', 'Bilgi', 'Dijital']);
      expect(model.activeFrame, 'frame_ice');
      expect(model.activeTitle, 'Kral');
      expect(model.updatedAt, fixedDate);
    });

    test('fromJson eksik alanlarda varsayılan kullanmalı', () {
      final model = UserModel.fromJson({}, 'uid');

      expect(model.displayName, 'Misafir');
      expect(model.avatarUrl, isNull);
      expect(model.walletPoints, 0);
      expect(model.rank, 'Newbie');
      expect(model.ownedCosmetics, isEmpty);
      expect(model.ownedCategories, GameConstants.defaultCategories);
      expect(model.activeFrame, isNull);
      expect(model.activeTitle, isNull);
      expect(model.updatedAt, isA<DateTime>());
    });

    test('toJson tüm anahtarları içermeli', () {
      final model = UserModel(
        uid: 'u1',
        displayName: 'X',
        walletPoints: 100,
        rank: 'R',
        ownedCosmetics: const ['c1'],
        ownedCategories: GameConstants.defaultCategoriesConst,
        updatedAt: fixedDate,
      );
      final json = model.toJson();

      expect(json['displayName'], 'X');
      expect(json['walletPoints'], 100);
      expect(json['rank'], 'R');
      expect(json['ownedCosmetics'], ['c1']);
      expect(json.containsKey('updatedAt'), isTrue);
    });

    test('toEntity doğru entity döndürmeli', () {
      final model = UserModel(
        uid: 'u1',
        displayName: 'Entity User',
        avatarUrl: 'https://a.png',
        walletPoints: 500,
        rank: 'Çırak',
        ownedCosmetics: const ['frame_fire'],
        ownedCategories: GameConstants.defaultCategoriesConst,
        activeFrame: 'frame_ice',
        activeTitle: 'Şövalye',
        updatedAt: fixedDate,
      );

      final entity = model.toEntity();

      expect(entity.uid, 'u1');
      expect(entity.displayName, 'Entity User');
      expect(entity.avatarUrl, 'https://a.png');
      expect(entity.walletPoints, 500);
      expect(entity.rank, 'Çırak');
      expect(entity.ownedCosmetics, ['frame_fire']);
      expect(entity.activeFrame, 'frame_ice');
      expect(entity.activeTitle, 'Şövalye');
    });
  });
}
