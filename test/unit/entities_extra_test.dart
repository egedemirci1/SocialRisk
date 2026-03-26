import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/custom_decks/domain/user_task_entity.dart';
import 'package:social_risk/features/economy/domain/cosmetic_item_entity.dart';
import 'package:social_risk/features/admin/domain/task_item_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('UserTaskEntity', () {
    test('varsayılan değerlerle doğru oluşturulmalı', () {
      final entity = UserTaskEntity(
        id: 'ut1',
        category: 'Fiziksel',
        content: 'Görev içeriği',
        difficulty: 'easy',
      );

      expect(entity.id, 'ut1');
      expect(entity.category, 'Fiziksel');
      expect(entity.content, 'Görev içeriği');
      expect(entity.difficulty, 'easy');
      expect(entity.type, TaskType.action);
      expect(entity.tags, ['custom']);
      expect(entity.isActive, true);
      expect(entity.createdAt, isNull);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final createdAt = DateTime(2024, 1, 15);
      final entity = UserTaskEntity(
        id: 'ut2',
        category: 'Bilgi',
        content: 'Soru',
        difficulty: 'hard',
        type: TaskType.question,
        tags: const ['custom', 'party'],
        isActive: false,
        createdAt: createdAt,
      );

      expect(entity.type, TaskType.question);
      expect(entity.tags, ['custom', 'party']);
      expect(entity.isActive, false);
      expect(entity.createdAt, createdAt);
    });
  });

  group('CosmeticItemEntity', () {
    test('categoryName opsiyonel olmalı', () {
      final entity = CosmeticItemEntity(
        id: 'c1',
        name: 'Çerçeve',
        nameEn: 'Frame',
        description: 'Açıklama',
        descriptionEn: 'Description',
        imageUrl: '🔥',
        price: 500,
        type: 'frame',
      );
      expect(entity.categoryName, isNull);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final entity = CosmeticItemEntity(
        id: 'cat_bilgi',
        name: 'Bilgi Kategorisi',
        nameEn: 'Info Category',
        description: 'Bilgi soruları',
        descriptionEn: 'Info questions',
        imageUrl: '💡',
        price: 0,
        type: 'category',
        categoryName: 'Bilgi',
      );
      expect(entity.categoryName, 'Bilgi');
      expect(entity.type, 'category');
    });
  });

  group('TaskItemEntity', () {
    test('varsayılan değerlerle doğru oluşturulmalı', () {
      final entity = TaskItemEntity(
        id: 'ti1',
        category: 'Cesaret',
        content: 'İçerik',
        difficulty: 'medium',
      );

      expect(entity.type, TaskType.action);
      expect(entity.tags, ['classic']);
      expect(entity.likes, 0);
      expect(entity.dislikes, 0);
      expect(entity.isActive, true);
      expect(entity.createdAt, isNull);
    });

    test('tüm parametrelerle doğru oluşturulmalı', () {
      final createdAt = DateTime(2024, 2, 20);
      final entity = TaskItemEntity(
        id: 'ti2',
        category: 'İtiraf',
        content: 'İtiraf içeriği',
        difficulty: 'hard',
        type: TaskType.question,
        tags: const ['adult', 'couple'],
        likes: 10,
        dislikes: 2,
        isActive: false,
        createdAt: createdAt,
      );

      expect(entity.likes, 10);
      expect(entity.dislikes, 2);
      expect(entity.isActive, false);
      expect(entity.createdAt, createdAt);
    });
  });
}
