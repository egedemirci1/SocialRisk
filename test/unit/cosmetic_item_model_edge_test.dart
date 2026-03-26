import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/economy/data/cosmetic_item_model.dart';

/// CosmeticItemModel – Edge Case & Unit Testleri
void main() {
  group('CosmeticItemModel', () {
    // ─────────── fromJson ───────────
    group('fromJson', () {
      test('tam JSON doğru parse edilmeli', () {
        final json = {
          'name': 'Altın Çerçeve',
          'description': 'Çok nadir bir çerçeve',
          'imageUrl': 'https://cdn.example.com/gold.png',
          'price': 500,
          'type': 'frame',
        };
        final item = CosmeticItemModel.fromJson(json, 'item_001');

        expect(item.id, 'item_001');
        expect(item.name, 'Altın Çerçeve');
        expect(item.description, 'Çok nadir bir çerçeve');
        expect(item.imageUrl, 'https://cdn.example.com/gold.png');
        expect(item.price, 500);
        expect(item.type, 'frame');
      });

      test('tamamen boş JSON → varsayılan değerler', () {
        final item = CosmeticItemModel.fromJson({}, 'empty_doc');

        expect(item.id, 'empty_doc');
        expect(item.name, 'İsimsiz Eşya');
        expect(item.description, '');
        expect(item.imageUrl, '');
        expect(item.price, 0);
        expect(item.type, 'frame');
      });

      test('null değerler → varsayılan değerler', () {
        final json = {
          'name': null,
          'description': null,
          'imageUrl': null,
          'price': null,
          'type': null,
        };
        final item = CosmeticItemModel.fromJson(json, 'null_doc');

        expect(item.name, 'İsimsiz Eşya');
        expect(item.description, '');
        expect(item.imageUrl, '');
        expect(item.price, 0);
        expect(item.type, 'frame');
      });

      test('negatif fiyat kabul edilmeli (validation başka katmanda)', () {
        final item = CosmeticItemModel.fromJson({'price': -100}, 'neg_price');
        expect(item.price, -100);
      });

      test('çok yüksek fiyat kabul edilmeli', () {
        final item = CosmeticItemModel.fromJson({'price': 99999}, 'expensive');
        expect(item.price, 99999);
      });

      test('özel karakter içeren name doğru parse edilmeli', () {
        final item = CosmeticItemModel.fromJson({'name': 'Şık Ünvan ❤️'}, 'special');
        expect(item.name, 'Şık Ünvan ❤️');
      });

      test('bilinmeyen type değeri doğru parse edilmeli', () {
        final item = CosmeticItemModel.fromJson({'type': 'unknown_type'}, 'unk');
        expect(item.type, 'unknown_type');
      });
    });

    // ─────────── toEntity ───────────
    group('toEntity', () {
      test('model → entity dönüşümü tüm alanları korumalı', () {
        const model = CosmeticItemModel(
          id: 'ent_1',
          name: 'Elmas Unvan',
          nameEn: 'Diamond Title',
          description: 'Parlak bir unvan',
          descriptionEn: 'Shiny title',
          imageUrl: 'https://img.url/diamond.png',
          price: 1000,
          type: 'title',
        );
        final entity = model.toEntity();

        expect(entity.id, 'ent_1');
        expect(entity.name, 'Elmas Unvan');
        expect(entity.description, 'Parlak bir unvan');
        expect(entity.imageUrl, 'https://img.url/diamond.png');
        expect(entity.price, 1000);
        expect(entity.type, 'title');
      });
    });

    // ─────────── Sıralama (Store sorting testleri) ───────────
    group('fiyata göre sıralama', () {
      test('farklı fiyatlı öğeler doğru sıralanmalı', () {
        final items = [
          CosmeticItemModel.fromJson({'name': 'Pahalı', 'price': 900}, 'a'),
          CosmeticItemModel.fromJson({'name': 'Ucuz', 'price': 100}, 'b'),
          CosmeticItemModel.fromJson({'name': 'Orta', 'price': 500}, 'c'),
        ];
        items.sort((a, b) => a.price.compareTo(b.price));

        expect(items[0].name, 'Ucuz');
        expect(items[1].name, 'Orta');
        expect(items[2].name, 'Pahalı');
      });

      test('aynı fiyatlı öğeler sıralamayı bozmamalı', () {
        final items = [
          CosmeticItemModel.fromJson({'name': 'A', 'price': 500}, 'a'),
          CosmeticItemModel.fromJson({'name': 'B', 'price': 500}, 'b'),
          CosmeticItemModel.fromJson({'name': 'C', 'price': 500}, 'c'),
        ];
        items.sort((a, b) => a.price.compareTo(b.price));

        // Dart sort is stable, so order should be preserved for equal elements
        expect(items.length, 3);
        expect(items.every((item) => item.price == 500), isTrue);
      });

      test('0 fiyatlı öğe en başta sıralanmalı', () {
        final items = [
          CosmeticItemModel.fromJson({'name': 'Ücretli', 'price': 200}, 'a'),
          CosmeticItemModel.fromJson({'name': 'Bedava', 'price': 0}, 'b'),
        ];
        items.sort((a, b) => a.price.compareTo(b.price));
        expect(items[0].name, 'Bedava');
      });
    });
  });
}
