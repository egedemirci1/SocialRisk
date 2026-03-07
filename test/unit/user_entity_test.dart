import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/auth/domain/user_entity.dart';
import 'package:social_risk/core/constants/game_constants.dart';

void main() {
  group('Nullable', () {
    test('value ile oluşturulur', () {
      const n = Nullable<String>('test');
      expect(n.value, 'test');
    });

    test('null value kabul eder', () {
      const n = Nullable<String?>(null);
      expect(n.value, isNull);
    });
  });

  group('UserEntity', () {
    test('varsayılan değerlerle doğru oluşturulmalı', () {
      final user = UserEntity(
        uid: 'uid_1',
        displayName: 'Kullanıcı',
      );

      expect(user.uid, 'uid_1');
      expect(user.displayName, 'Kullanıcı');
      expect(user.avatarUrl, isNull);
      expect(user.walletPoints, 0);
      expect(user.rank, 'Çırak');
      expect(user.ownedCosmetics, isEmpty);
      expect(user.ownedCategories, GameConstants.defaultCategoriesConst);
      expect(user.activeFrame, isNull);
      expect(user.activeTitle, isNull);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final user = UserEntity(
        uid: 'u1',
        displayName: 'Tam Kullanıcı',
        avatarUrl: 'https://photo.jpg',
        walletPoints: 500,
        rank: 'Şövalye',
        ownedCosmetics: ['frame_fire'],
        ownedCategories: ['Fiziksel', 'Bilgi'],
        activeFrame: 'frame_ice',
        activeTitle: 'Kral',
      );

      expect(user.avatarUrl, 'https://photo.jpg');
      expect(user.walletPoints, 500);
      expect(user.rank, 'Şövalye');
      expect(user.ownedCosmetics, ['frame_fire']);
      expect(user.ownedCategories, ['Fiziksel', 'Bilgi']);
      expect(user.activeFrame, 'frame_ice');
      expect(user.activeTitle, 'Kral');
    });

    group('copyWith', () {
      test('parametre verilmezse mevcut değerler korunmalı', () {
        final user = UserEntity(
          uid: 'u1',
          displayName: 'Eski',
          walletPoints: 100,
        );
        final copy = user.copyWith();

        expect(copy.uid, 'u1');
        expect(copy.displayName, 'Eski');
        expect(copy.walletPoints, 100);
      });

      test('verilen alanlar güncellenmeli', () {
        final user = UserEntity(
          uid: 'u1',
          displayName: 'Eski',
          rank: 'Çırak',
        );
        final copy = user.copyWith(
          displayName: 'Yeni',
          walletPoints: 200,
          rank: 'Usta',
        );

        expect(copy.uid, 'u1');
        expect(copy.displayName, 'Yeni');
        expect(copy.walletPoints, 200);
        expect(copy.rank, 'Usta');
      });

      test('Nullable ile yeni değer atanabilmeli', () {
        final user = UserEntity(
          uid: 'u1',
          displayName: 'User',
          avatarUrl: null,
        );
        final copy = user.copyWith(
          avatarUrl: const Nullable<String>('https://new.png'),
        );

        expect(copy.avatarUrl, 'https://new.png');
      });

      test('Nullable ile activeFrame atanabilmeli', () {
        final user = UserEntity(
          uid: 'u1',
          displayName: 'User',
          activeFrame: null,
        );
        final copy = user.copyWith(
          activeFrame: const Nullable<String>('frame_fire'),
        );

        expect(copy.activeFrame, 'frame_fire');
      });
    });
  });
}
