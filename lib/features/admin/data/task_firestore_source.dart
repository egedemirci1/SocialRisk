import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_item_entity.dart';
import '../../../shared/models/enums.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/data/seeded_tasks/seeded_tasks.dart';

/// Firestore'daki görevleri yöneten data source.
/// CRUD + oyun içi görev çekme + feedback.
class TaskFirestoreSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection('tasks');

  CollectionReference<Map<String, dynamic>> get _feedbackRef =>
      _firestore.collection('taskFeedback');

  // ── Görev Çekme (Oyun İçi) ───────────────────────────

  /// Belirli kategori + zorluk + preset filtresiyle aktif görev çeker.
  /// Kullanılmış görevleri hariç tutar.
  Future<TaskItemEntity?> getRandomTask({
    required String category,
    required String difficulty,
    List<String> usedTaskIds = const [],
    bool includeCustomDeck = false,
    String? hostId,
  }) async {
    List<DocumentSnapshot<Map<String, dynamic>>> allAvailableDocs = [];

    List<DocumentSnapshot<Map<String, dynamic>>> customAvailable = [];

    // 1. Özel görevleri çek
    if (includeCustomDeck && hostId != null) {
      final customSnap = await _firestore
          .collection('users')
          .doc(hostId)
          .collection('custom_tasks')
          .where('category', isEqualTo: category)
          .where('difficulty', isEqualTo: difficulty)
          .get();

      customAvailable = customSnap.docs
          .where((doc) => !usedTaskIds.contains(doc.id))
          .toList();

      allAvailableDocs.addAll(customAvailable);
    }

    // 2. Normal görevleri çek
    Query<Map<String, dynamic>> query = _tasksRef
        .where('category', isEqualTo: category)
        .where('difficulty', isEqualTo: difficulty)
        .where('isActive', isEqualTo: true);

    final snap = await query.get();

    // Normal kullanılmış olanları filtrele
    final available = snap.docs
        .where((doc) => !usedTaskIds.contains(doc.id))
        .toList();

    allAvailableDocs.addAll(available);

    // 3. Akıllı Harmanlama: Özel görevlere öncelik ver (%40 şansla sadece özelleri seçer)
    if (customAvailable.isNotEmpty && _random.nextInt(100) < 40) {
      final randomDoc =
          customAvailable[_random.nextInt(customAvailable.length)];
      return _docToEntity(randomDoc);
    }

    // 4. Normal havuzdan rastgele birini seç (Özeller de dahil)
    if (allAvailableDocs.isEmpty) {
      // Fallback: Kullanılmışları da dahil et
      if (snap.docs.isNotEmpty) {
        final randomDoc = snap.docs[_random.nextInt(snap.docs.length)];
        return _docToEntity(randomDoc);
      }
      return null;
    }

    final randomDoc =
        allAvailableDocs[_random.nextInt(allAvailableDocs.length)];
    return _docToEntity(randomDoc);
  }

  // ── Görev Ön-Yükleme Havuzu (İyileştirme) ────────────────────

  /// Local (seeded) görevleri kategori_zorluk key'ine göre gruplar.
  /// Firebase'e yazmadan oyun havuzunu doldurmak için kullanılır.
  static Map<String, List<Map<String, dynamic>>> _localPoolByCombo() {
    final all = getAllSeededTasks();
    final combo = <String, List<Map<String, dynamic>>>{};
    for (var i = 0; i < all.length; i++) {
      final t = all[i];
      final cat = t['category'] as String? ?? '';
      final diff = t['difficulty'] as String? ?? 'easy';
      final key = '${cat}_$diff';
      combo.putIfAbsent(key, () => []);
      combo[key]!.add({
        'id': 'local_${cat}_${diff}_$i',
        'category': cat,
        'content': t['content'] ?? '',
        'difficulty': diff,
      });
    }
    return combo;
  }

  /// Oyun başında tüm kategori×zorluk kombinasyonları için görevleri
  /// tek seferde çeker. Önce local (800 soru), isteğe bağlı Firestore eklenir.
  Future<Map<String, List<Map<String, dynamic>>>> fetchTaskPool({
    bool includeCustomDeck = false,
    String? hostId,
    List<String>? categories,
  }) async {
    final cats = categories ?? GameConstants.defaultCategories;
    final diffs = GameConstants.defaultDifficulties;
    final poolSize = GameConstants.taskPoolSizePerCombo;
    final pool = <String, List<Map<String, dynamic>>>{};
    final localByCombo = _localPoolByCombo();

    for (final category in cats) {
      for (final difficulty in diffs) {
        final poolKey = '${category}_$difficulty';
        final List<Map<String, dynamic>> tasksForCombo = [];

        // 1. Local (seeded) görevleri ekle — Firebase zorunlu değil
        final localList = localByCombo[poolKey] ?? [];
        if (localList.isNotEmpty) {
          localList.shuffle(_random);
          tasksForCombo.addAll(
            localList.take(poolSize),
          );
        }

        // 2. İsteğe bağlı: Firestore'dan da çek (admin eklediyse)
        final snap = await _tasksRef
            .where('category', isEqualTo: category)
            .where('difficulty', isEqualTo: difficulty)
            .where('isActive', isEqualTo: true)
            .limit(poolSize)
            .get();

        for (final doc in snap.docs) {
          final data = doc.data();
          tasksForCombo.add({
            'id': doc.id,
            'category': data['category'] ?? category,
            'content': data['content'] ?? '',
            'difficulty': data['difficulty'] ?? difficulty,
          });
        }

        // 3. Özel görevleri ekle
        if (includeCustomDeck && hostId != null) {
          final customSnap = await _firestore
              .collection('users')
              .doc(hostId)
              .collection('custom_tasks')
              .where('category', isEqualTo: category)
              .where('difficulty', isEqualTo: difficulty)
              .limit(poolSize)
              .get();

          for (final doc in customSnap.docs) {
            final data = doc.data();
            tasksForCombo.add({
              'id': 'custom_${doc.id}',
              'category': data['category'] ?? category,
              'content': data['content'] ?? '',
              'difficulty': data['difficulty'] ?? difficulty,
            });
          }
        }

        // 4. Karıştır ve havuz boyutuna indir
        tasksForCombo.shuffle(_random);

        if (tasksForCombo.isNotEmpty) {
          pool[poolKey] = tasksForCombo.take(poolSize).toList();
        }
      }
    }

    return pool;
  }

  // ── CRUD (Admin Paneli) ──────────────────────────────

  /// Tüm görevleri çeker (admin listesi için).
  Stream<List<TaskItemEntity>> watchAllTasks() {
    return _tasksRef.orderBy('category').snapshots().map((snap) {
      return snap.docs.map((doc) => _docToEntity(doc)).toList();
    });
  }

  /// Yeni görev ekler.
  Future<String> addTask(TaskItemEntity task) async {
    final doc = await _tasksRef.add({
      'category': task.category,
      'content': task.content,
      'difficulty': task.difficulty,
      'type': task.type.name,
      'tags': task.tags,
      'likes': 0,
      'dislikes': 0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Görevi günceller.
  Future<void> updateTask(TaskItemEntity task) async {
    await _tasksRef.doc(task.id).update({
      'category': task.category,
      'content': task.content,
      'difficulty': task.difficulty,
      'type': task.type.name,
      'tags': task.tags,
      'isActive': task.isActive,
    });
  }

  /// Görevi soft-delete (isActive: false).
  Future<void> deactivateTask(String taskId) async {
    await _tasksRef.doc(taskId).update({'isActive': false});
  }

  /// Görevi kalıcı siler.
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  // ── Feedback ─────────────────────────────────────────

  /// Oyuncu görev hakkında feedback verir (beğendim/beğenmedim).
  /// Her oyuncu her görev için sadece bir kez.
  Future<void> submitFeedback({
    required String taskId,
    required String userId,
    required bool isLike,
  }) async {
    final feedbackId = '${taskId}_$userId';
    final existingDoc = await _feedbackRef.doc(feedbackId).get();

    if (existingDoc.exists) return; // Zaten oy vermiş

    // Feedback kaydını oluştur
    await _feedbackRef.doc(feedbackId).set({
      'taskId': taskId,
      'userId': userId,
      'isLike': isLike,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Sayacı artır
    final field = isLike ? 'likes' : 'dislikes';
    await _tasksRef.doc(taskId).update({field: FieldValue.increment(1)});
  }

  // ── Seed Migration ───────────────────────────────────

  /// Mevcut hardcoded görevleri Firestore'a yükler (bir kerelik).
  /// [clearAllFirst] true ise, önce tasks koleksiyonunu tamamen boşaltır (duplicate'leri silmek için).
  Future<int> seedTasks(
    List<Map<String, dynamic>> tasks, {
    bool clearAllFirst = false,
  }) async {
    if (clearAllFirst) {
      await deleteAllTasksFromCollection();
    } else {
      // Sadece 'içerik' kontrolü yaparak ekle (Duplicate önleme)
      final existingSnap = await _tasksRef.get();
      final existingContents = existingSnap.docs
          .map((doc) => doc.data()['content'] as String?)
          .where((content) => content != null)
          .toSet();

      final newTasks = tasks
          .where((t) => !existingContents.contains(t['content']))
          .toList();
      if (newTasks.isEmpty) return 0;

      final batch = _firestore.batch();
      for (final task in newTasks) {
        final docRef = _tasksRef.doc();
        batch.set(docRef, {
          ...task,
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      return newTasks.length;
    }

    // Eğer clearAllFirst yapıldıysa sıfırdan doldur (batch 500 limiti ile):
    int count = 0;
    for (var i = 0; i < tasks.length; i += 500) {
      final batch = _firestore.batch();
      final chunk = tasks.skip(i).take(500);
      for (final task in chunk) {
        final docRef = _tasksRef.doc();
        batch.set(docRef, {
          ...task,
          'likes': 0,
          'dislikes': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
      }
      await batch.commit();
    }
    return count;
  }

  /// Tüm tasks koleksiyonunu uçurur (Admin/Seed temizliği için).
  Future<void> deleteAllTasksFromCollection() async {
    final snap = await _tasksRef.get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Helper ───────────────────────────────────────────

  TaskItemEntity _docToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskItemEntity(
      id: doc.id,
      category: data['category'] as String? ?? '',
      content: data['content'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'easy',
      type: TaskType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TaskType.action,
      ),
      tags: List<String>.from(data['tags'] ?? ['classic']),
      likes: data['likes'] as int? ?? 0,
      dislikes: data['dislikes'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
