import 'dart:math';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/core/constants/game_constants.dart';
import 'package:social_risk/features/admin/data/task_firestore_source.dart';
import 'package:social_risk/features/admin/domain/task_item_entity.dart';
import 'package:social_risk/shared/models/enums.dart';

void main() {
  group('TaskFirestoreSource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TaskFirestoreSource taskSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      taskSource = TaskFirestoreSource(firestore: fakeFirestore);
    });

    TaskItemEntity taskEntity({
      String id = 'task1',
      String category = 'Fiziksel',
      String content = 'Test görevi',
      String difficulty = 'easy',
      TaskType type = TaskType.action,
      List<String> tags = const ['classic'],
      bool isActive = true,
    }) {
      return TaskItemEntity(
        id: id,
        category: category,
        content: content,
        difficulty: difficulty,
        type: type,
        tags: tags,
        isActive: isActive,
      );
    }

    group('addTask', () {
      test('yeni görev ekler ve doc id döner', () async {
        final task = taskEntity(id: '', content: 'Yeni görev içeriği');
        final docId = await taskSource.addTask(task);

        expect(docId, isNotEmpty);

        final doc = await fakeFirestore.collection('tasks').doc(docId).get();
        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['category'], 'Fiziksel');
        expect(data['content'], 'Yeni görev içeriği');
        expect(data['difficulty'], 'easy');
        expect(data['type'], 'action');
        expect(data['tags'], ['classic']);
        expect(data['likes'], 0);
        expect(data['dislikes'], 0);
        expect(data['isActive'], true);
      });
    });

    group('updateTask', () {
      test('var olan görevi günceller', () async {
        final addTask = taskEntity(id: '', content: 'Eski içerik');
        final docId = await taskSource.addTask(addTask);

        final updated = taskEntity(
          id: docId,
          content: 'Güncel içerik',
          difficulty: 'medium',
          isActive: false,
        );
        await taskSource.updateTask(updated);

        final doc = await fakeFirestore.collection('tasks').doc(docId).get();
        expect(doc.data()!['content'], 'Güncel içerik');
        expect(doc.data()!['difficulty'], 'medium');
        expect(doc.data()!['isActive'], false);
      });
    });

    group('deleteTask', () {
      test('görevi kalıcı siler', () async {
        final task = taskEntity(id: '', content: 'Silinecek');
        final docId = await taskSource.addTask(task);
        expect((await fakeFirestore.collection('tasks').doc(docId).get()).exists, isTrue);

        await taskSource.deleteTask(docId);

        final doc = await fakeFirestore.collection('tasks').doc(docId).get();
        expect(doc.exists, isFalse);
      });
    });

    group('deactivateTask', () {
      test('görevi soft-delete yapar (isActive: false)', () async {
        final task = taskEntity(id: '', content: 'Deaktif');
        final docId = await taskSource.addTask(task);

        await taskSource.deactivateTask(docId);

        final doc = await fakeFirestore.collection('tasks').doc(docId).get();
        expect(doc.data()!['isActive'], false);
      });
    });

    group('watchAllTasks', () {
      test('tüm görevleri stream olarak döner', () async {
        await taskSource.addTask(taskEntity(id: '', content: 'A'));
        await taskSource.addTask(taskEntity(id: '', content: 'B'));

        final stream = taskSource.watchAllTasks();
        final list = await stream.first;

        expect(list.length, 2);
        expect(list.any((t) => t.content == 'A'), true);
        expect(list.any((t) => t.content == 'B'), true);
      });

      test('boş koleksiyonda boş liste döner', () async {
        final stream = taskSource.watchAllTasks();
        final list = await stream.first;
        expect(list, isEmpty);
      });
    });

    group('getRandomTask', () {
      test('var olan görevi çeker (tek görev varsa onu döner)', () async {
        await fakeFirestore.collection('tasks').add({
          'category': 'Bilgi',
          'content': 'Rastgele seçilecek',
          'difficulty': 'medium',
          'type': 'question',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        final result = await taskSource.getRandomTask(
          category: 'Bilgi',
          difficulty: 'medium',
        );

        expect(result, isNotNull);
        expect(result!.content, 'Rastgele seçilecek');
        expect(result.category, 'Bilgi');
        expect(result.difficulty, 'medium');
      });

      test('kullanılmış id ler hariç tutulur', () async {
        final ref = await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Kullanılmış',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });
        await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Kullanılmamış',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        final result = await taskSource.getRandomTask(
          category: 'Fiziksel',
          difficulty: 'easy',
          usedTaskIds: [ref.id],
        );

        expect(result, isNotNull);
        expect(result!.content, 'Kullanılmamış');
      });

      test('uygun görev yoksa null döner', () async {
        final result = await taskSource.getRandomTask(
          category: 'OlmayanKategori',
          difficulty: 'hard',
        );
        expect(result, isNull);
      });

      test('includeCustomDeck ve hostId ile özel görevlerden seçer', () async {
        final hostId = 'host1';
        await fakeFirestore
            .collection('users')
            .doc(hostId)
            .collection('custom_tasks')
            .add({
          'category': 'Fiziksel',
          'content': 'Özel görev',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
        });

        final sourceWithFixedRandom = TaskFirestoreSource(
          firestore: fakeFirestore,
          random: Random(42),
        );
        final result = await sourceWithFixedRandom.getRandomTask(
          category: 'Fiziksel',
          difficulty: 'easy',
          includeCustomDeck: true,
          hostId: hostId,
        );
        expect(result, isNotNull);
        expect(result!.content, 'Özel görev');
      });
    });

    group('fetchTaskPool', () {
      test('firestore boşken local havuz döner (en az bazı combo lar dolu)', () async {
        final pool = await taskSource.fetchTaskPool(
          categories: GameConstants.defaultCategoriesConst.take(2).toList(),
        );
        expect(pool, isNotEmpty);
        for (final entry in pool.entries) {
          expect(entry.value, isNotEmpty);
          expect(entry.value.length, lessThanOrEqualTo(GameConstants.taskPoolSizePerCombo));
        }
      });

      test('firestore taki aktif görevler havuza eklenir', () async {
        // Seeded listede olmayan kategori kullanıyoruz; böylece havuzda sadece
        // Firestore'dan eklenen görev kalır (shuffle/take(5) sonrası kaybolmaz).
        const category = 'FirestoreHavuzTest';
        await fakeFirestore.collection('tasks').add({
          'category': category,
          'content': 'Firestore görevi',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        final pool = await taskSource.fetchTaskPool(
          categories: [category],
        );
        final key = '${category}_easy';
        expect(pool.containsKey(key), isTrue);
        final hasFirestoreTask = pool[key]!.any((t) => t['content'] == 'Firestore görevi');
        expect(hasFirestoreTask, isTrue);
      });

      test('includeCustomDeck ve hostId ile özel görevler havuza eklenir', () async {
        const hostId = 'host2';
        // Seeded görevlerde olmayan kategori kullanıyoruz; böylece havuzda sadece
        // custom_tasks'tan gelen görev kalır (shuffle sonrası ilk 5’e kesin girer).
        const category = 'ÖzelHavuzTest';
        await fakeFirestore
            .collection('users')
            .doc(hostId)
            .collection('custom_tasks')
            .add({
          'category': category,
          'content': 'Özel havuz görevi',
          'difficulty': 'medium',
        });

        final pool = await taskSource.fetchTaskPool(
          categories: [category],
          includeCustomDeck: true,
          hostId: hostId,
        );
        const key = 'ÖzelHavuzTest_medium';
        expect(pool.containsKey(key), isTrue);
        final hasCustom = pool[key]!.any((t) => t['content'] == 'Özel havuz görevi');
        expect(hasCustom, isTrue);
      });
    });

    group('submitFeedback', () {
      test('feedback yazar ve likes artar', () async {
        final ref = await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Feedback görevi',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        await taskSource.submitFeedback(
          taskId: ref.id,
          userId: 'user1',
          isLike: true,
        );

        final feedbackDoc = await fakeFirestore
            .collection('taskFeedback')
            .doc('${ref.id}_user1')
            .get();
        expect(feedbackDoc.exists, isTrue);
        expect(feedbackDoc.data()!['isLike'], true);

        final taskDoc = await fakeFirestore.collection('tasks').doc(ref.id).get();
        expect(taskDoc.data()!['likes'], 1);
      });

      test('dislike ile dislikes artar', () async {
        final ref = await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Dislike görevi',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        await taskSource.submitFeedback(
          taskId: ref.id,
          userId: 'user2',
          isLike: false,
        );

        final taskDoc = await fakeFirestore.collection('tasks').doc(ref.id).get();
        expect(taskDoc.data()!['dislikes'], 1);
      });

      test('aynı kullanıcı ikinci kez oy verirse tekrar yazmaz', () async {
        final ref = await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Double vote',
          'difficulty': 'easy',
          'type': 'action',
          'tags': ['classic'],
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': DateTime.now(),
        });

        await taskSource.submitFeedback(
          taskId: ref.id,
          userId: 'user3',
          isLike: true,
        );
        await taskSource.submitFeedback(
          taskId: ref.id,
          userId: 'user3',
          isLike: true,
        );

        final taskDoc = await fakeFirestore.collection('tasks').doc(ref.id).get();
        expect(taskDoc.data()!['likes'], 1);
      });
    });

    group('seedTasks', () {
      test('yeni görevleri ekler ve eklenen sayıyı döner', () async {
        final tasks = [
          {'category': 'Fiziksel', 'content': 'Seed 1', 'difficulty': 'easy'},
          {'category': 'Bilgi', 'content': 'Seed 2', 'difficulty': 'medium'},
        ];
        final count = await taskSource.seedTasks(tasks);
        expect(count, 2);

        final snap = await fakeFirestore.collection('tasks').get();
        expect(snap.docs.length, 2);
      });

      test('clearAllFirst true ise önce siler sonra ekler', () async {
        await fakeFirestore.collection('tasks').add({
          'category': 'X',
          'content': 'Eski',
          'difficulty': 'easy',
          'isActive': true,
        });
        final tasks = [
          {'category': 'Y', 'content': 'Yeni tek', 'difficulty': 'easy'},
        ];
        final count = await taskSource.seedTasks(tasks, clearAllFirst: true);
        expect(count, 1);

        final snap = await fakeFirestore.collection('tasks').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['content'], 'Yeni tek');
      });

      test('aynı content zaten varsa duplicate eklemez', () async {
        await fakeFirestore.collection('tasks').add({
          'category': 'Fiziksel',
          'content': 'Var olan içerik',
          'difficulty': 'easy',
          'isActive': true,
        });
        final tasks = [
          {'category': 'Fiziksel', 'content': 'Var olan içerik', 'difficulty': 'easy'},
          {'category': 'Fiziksel', 'content': 'Yeni içerik', 'difficulty': 'easy'},
        ];
        final count = await taskSource.seedTasks(tasks);
        expect(count, 1);
        final snap = await fakeFirestore.collection('tasks').get();
        expect(snap.docs.length, 2);
      });
    });

    group('deleteAllTasksFromCollection', () {
      test('tüm görevleri siler', () async {
        await fakeFirestore.collection('tasks').add({'content': 'A'});
        await fakeFirestore.collection('tasks').add({'content': 'B'});

        await taskSource.deleteAllTasksFromCollection();

        final snap = await fakeFirestore.collection('tasks').get();
        expect(snap.docs, isEmpty);
      });
    });

    group('reports (reports koleksiyonu)', () {
      test('reports koleksiyonu Firestore da doğru yazılır (auth tarafı senaryosu)', () async {
        await fakeFirestore.collection('reports').add({
          'reporterId': 'r1',
          'targetUserId': 't1',
          'reason': 'Spam',
          'createdAt': DateTime.now(),
        });
        final snap = await fakeFirestore.collection('reports').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['reason'], 'Spam');
      });
    });
  });
}
