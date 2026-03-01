import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_item_entity.dart';
import '../domain/report_entity.dart';
import 'task_provider.dart';

// Admin UID Whitelist
const List<String> adminUids = [
  'y51M7E6YXZT5I04M9YFqGzSgZ7Y2', // Örnek UID, gerçek admin UID'leri buraya eklenecek
];

bool isAdmin(String? uid) => uid != null && adminUids.contains(uid);

// -- Providers --
final adminTasksProvider = StreamProvider.autoDispose<List<TaskItemEntity>>((ref) {
  final source = ref.watch(taskFirestoreSourceProvider);
  return source.watchAllTasks();
});

final watchReportsProvider = StreamProvider.autoDispose<List<ReportEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ReportEntity.fromJson(doc.data(), doc.id)).toList());
});

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController(ref);
});

class AdminController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AdminController(this._ref) : super(const AsyncValue.data(null));

  Future<void> addTask(TaskItemEntity task) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(taskFirestoreSourceProvider).addTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTask(TaskItemEntity task) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(taskFirestoreSourceProvider).updateTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleTaskActiveStatus(String taskId, bool isActive) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'isActive': isActive});
    } catch (e) {
      // ignore
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _ref.read(taskFirestoreSourceProvider).deleteTask(taskId);
    } catch (e) {
      // ignore
    }
  }

  // --- Photo Moderation ---
  Future<void> approvePhoto(String targetUserId, String reportId) async {
    // Fotoğrafı onayla dersen raporu siliyoruz, flag vs koymuyoruz.
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
  }

  Future<void> banPhoto(String targetUserId, String reportId) async {
    // Kullanıcının avatarını kaldır ve avatarFlagged: true yap.
    final batch = FirebaseFirestore.instance.batch();
    
    batch.update(FirebaseFirestore.instance.collection('users').doc(targetUserId), {
      'avatarUrl': null,
      'avatarFlagged': true,
    });
    
    // Raporu da kapat/sil
    batch.delete(FirebaseFirestore.instance.collection('reports').doc(reportId));
    
    await batch.commit();
  }
}
