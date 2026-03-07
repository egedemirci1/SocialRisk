import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/economy/data/cosmetic_item_model.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';

void main() {
  group('CosmeticItemModel', () {
    test('fromJson tüm alanları doğru parse etmeli', () {
      final json = {
        'name': 'Ateş Çerçevesi',
        'description': 'Alevli çerçeve',
        'imageUrl': '🔥',
        'price': 500,
        'type': 'frame',
      };

      final model = CosmeticItemModel.fromJson(json, 'frame_fire');

      expect(model.id, 'frame_fire');
      expect(model.name, 'Ateş Çerçevesi');
      expect(model.description, 'Alevli çerçeve');
      expect(model.imageUrl, '🔥');
      expect(model.price, 500);
      expect(model.type, 'frame');
    });

    test('fromJson eksik alanlarda varsayılan kullanmalı', () {
      final model = CosmeticItemModel.fromJson({}, 'id');

      expect(model.name, 'İsimsiz Eşya');
      expect(model.description, '');
      expect(model.imageUrl, '');
      expect(model.price, 0);
      expect(model.type, 'frame');
    });

    test('toEntity doğru entity döndürmeli', () {
      final model = CosmeticItemModel(
        id: 'title_king',
        name: 'Kral',
        description: 'Kral unvanı',
        imageUrl: '👑',
        price: 1000,
        type: 'title',
      );

      final entity = model.toEntity();

      expect(entity, isA<CosmeticItemEntity>());
      expect(entity.id, 'title_king');
      expect(entity.name, 'Kral');
      expect(entity.description, 'Kral unvanı');
      expect(entity.imageUrl, '👑');
      expect(entity.price, 1000);
      expect(entity.type, 'title');
      expect(entity.categoryName, isNull);
    });
  });
}
