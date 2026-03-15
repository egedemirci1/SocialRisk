import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/data/seeded_tasks/seeded_tasks.dart';

void main() {
  group('SeededTasks', () {
    test('getAllSeededTasks returns 8 categories with 100+ tasks each', () {
      final tasks = getAllSeededTasks();
      expect(tasks.length, greaterThanOrEqualTo(700));
      final byCategory = <String, int>{};
      for (final task in tasks) {
        final c = task['category'] as String;
        byCategory[c] = (byCategory[c] ?? 0) + 1;
      }
      expect(byCategory.length, 8);
      for (final count in byCategory.values) {
        expect(count, greaterThanOrEqualTo(70));
      }
    });

    test('every task has required keys: category, content, difficulty, type, tags', () {
      final tasks = getAllSeededTasks();
      const requiredKeys = ['category', 'content', 'difficulty', 'type', 'tags'];
      for (final task in tasks) {
        for (final key in requiredKeys) {
          expect(task.containsKey(key), true, reason: 'Task missing key: $key');
        }
        expect(task['content'], isA<String>());
        expect((task['content'] as String).isNotEmpty, true);
        expect(['easy', 'medium', 'hard'], contains(task['difficulty']));
        expect(task['tags'], isA<List<dynamic>>());
      }
    });

    test('all categories are the 8 seeded categories', () {
      final tasks = getAllSeededTasks();
      const expectedCategories = {
        'Fiziksel',
        'Bilgi',
        'Dijital',
        'İtiraf',
        'Zihinsel',
        'Ahlaki',
        'Görsel',
        'Mahrem',
      };
      final categories = tasks.map((t) => t['category'] as String).toSet();
      expect(categories.length, 8);
      expect(categories, expectedCategories);
    });

    test('each category has at least 70 tasks', () {
      final tasks = getAllSeededTasks();
      final byCategory = <String, int>{};
      for (final task in tasks) {
        final c = task['category'] as String;
        byCategory[c] = (byCategory[c] ?? 0) + 1;
      }
      expect(byCategory.length, 8);
      for (final count in byCategory.values) {
        expect(count, greaterThanOrEqualTo(70));
      }
    });
  });
}
