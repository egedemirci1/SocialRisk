import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_item_entity.dart';
import '../../../shared/models/enums.dart';

/// Firestore'daki görevleri yöneten data source.
/// CRUD + oyun içi görev çekme + feedback.
class TaskFirestoreSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    required String preset,
    List<String> usedTaskIds = const [],
  }) async {
    // Firestore'dan filtreli sorgu
    Query<Map<String, dynamic>> query = _tasksRef
        .where('category', isEqualTo: category)
        .where('difficulty', isEqualTo: difficulty)
        .where('isActive', isEqualTo: true)
        .where('tags', arrayContains: preset);

    final snap = await query.get();

    // Kullanılmış olanları filtrele
    final available = snap.docs
        .where((doc) => !usedTaskIds.contains(doc.id))
        .toList();

    if (available.isEmpty) {
      // Fallback: Kullanılmışları da dahil et
      if (snap.docs.isNotEmpty) {
        final randomDoc =
            snap.docs[DateTime.now().millisecond % snap.docs.length];
        return _docToEntity(randomDoc);
      }

      // Zorluk filtresi olmadan dene
      final fallbackSnap = await _tasksRef
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .where('tags', arrayContains: preset)
          .get();

      final fallbackAvailable = fallbackSnap.docs
          .where((doc) => !usedTaskIds.contains(doc.id))
          .toList();

      if (fallbackAvailable.isNotEmpty) {
        final randomDoc =
            fallbackAvailable[DateTime.now().millisecond %
                fallbackAvailable.length];
        return _docToEntity(randomDoc);
      }

      if (fallbackSnap.docs.isNotEmpty) {
        final randomDoc = fallbackSnap
            .docs[DateTime.now().millisecond % fallbackSnap.docs.length];
        return _docToEntity(randomDoc);
      }

      return null; // Hiç görev yok
    }

    // Rastgele birini seç
    final randomDoc = available[DateTime.now().millisecond % available.length];
    return _docToEntity(randomDoc);
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

    // Eğer clearAllFirst yapıldıysa sıfırdan doldur:
    final batch = _firestore.batch();
    int count = 0;
    for (final task in tasks) {
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
