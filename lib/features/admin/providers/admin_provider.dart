import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/task_item_entity.dart';
import '../domain/report_entity.dart';
import 'task_provider.dart';

part 'admin_provider.g.dart';

// Admin UID Whitelist
const List<String> adminUids = [
  'y51M7E6YXZT5I04M9YFqGzSgZ7Y2',
  'hW42qgzVJIXr6sOLO0q1zPOdv6w1',
  'd7sLOX946mRfrmkYMRUOJXNa44l2', // Reze
];

bool isAdmin(String? uid) => uid != null && adminUids.contains(uid);

// -- Providers --
final adminTasksProvider = StreamProvider.autoDispose<List<TaskItemEntity>>((ref) {
  final source = ref.watch(taskSourceProvider);
  return source.watchAllTasks();
});

final watchReportsProvider = StreamProvider.autoDispose<List<ReportEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ReportEntity.fromJson(doc.data(), doc.id)).toList());
});

@riverpod
class AdminController extends _$AdminController {
  @override
  FutureOr<void> build() {}

  Future<void> addTask(TaskItemEntity task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskSourceProvider).addTask(task);
    });
  }

  Future<void> updateTask(TaskItemEntity task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskSourceProvider).updateTask(task);
    });
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
      await ref.read(taskSourceProvider).deleteTask(taskId);
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
