import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/task_item_entity.dart';
import '../domain/report_entity.dart';
import 'task_provider.dart';
import '../data/task_seed_migration.dart';

part 'admin_provider.g.dart';

// Admin UID Whitelist
const List<String> adminUids = [
  'y51M7E6YXZT5I04M9YFqGzSgZ7Y2',
  'hW42qgzVJIXr6sOLO0q1zPOdv6w1',
  'd7sLOX946mRfrmkYMRUOJXNa44l2', // Reze
];

bool isAdmin(String? uid) => uid != null && adminUids.contains(uid);

// -- Providers --
final adminTasksProvider = StreamProvider.autoDispose<List<TaskItemEntity>>((
  ref,
) {
  final source = ref.watch(taskSourceProvider);
  return source.watchAllTasks();
});

final watchReportsProvider = StreamProvider.autoDispose<List<ReportEntity>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => ReportEntity.fromJson(doc.data(), doc.id))
            .toList(),
      );
});

@Riverpod(keepAlive: true)
class AdminController extends _$AdminController {
  @override
  FutureOr<void> build() {}

  Future<void> addTask(TaskItemEntity task) async {
    state = const AsyncLoading();
    final source = ref.read(taskSourceProvider);
    state = await AsyncValue.guard(() async {
      await source.addTask(task);
    });
  }

  Future<void> updateTask(TaskItemEntity task) async {
    state = const AsyncLoading();
    final source = ref.read(taskSourceProvider);
    state = await AsyncValue.guard(() async {
      await source.updateTask(task);
    });
  }

  Future<void> toggleTaskActiveStatus(String taskId, bool isActive) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'isActive': isActive,
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> deleteTask(String taskId) async {
    final source = ref.read(taskSourceProvider);
    try {
      await source.deleteTask(taskId);
    } catch (e) {
      // ignore
    }
  }

  Future<void> seedTasks() async {
    state = const AsyncLoading();
    try {
      final source = ref.read(taskSourceProvider);
      final success = await source.seedTasks(
        TaskSeedMigration.seedData,
        clearAllFirst: true,
      );
      if (success == 0) {
        state = AsyncError(
          Exception('Zaten seed edilmiş veya hata oluştu.'),
          StackTrace.current,
        );
      } else {
        state = const AsyncData(null);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> seedCosmetics() async {
    state = const AsyncLoading();
    try {
      final cosmeticsRef = FirebaseFirestore.instance.collection('cosmetics');
      
      final items = {
        'frame_fire': {
          'name': 'Ateş Çerçevesi',
          'type': 'frame',
          'imageUrl': '🔥',
          'price': 500,
          'isActive': true,
        },
        'frame_ice': {
          'name': 'Buz Çerçevesi',
          'type': 'frame',
          'imageUrl': '🧊',
          'price': 500,
          'isActive': true,
        },
        'frame_flower': {
          'name': 'Çiçek Çerçevesi',
          'type': 'frame',
          'imageUrl': '🌸',
          'price': 400,
          'isActive': true,
        },
        'frame_shield': {
          'name': 'Kalkan Çerçevesi',
          'type': 'frame',
          'imageUrl': '🛡️',
          'price': 600,
          'isActive': true,
        },
        'title_king': {
          'name': 'Kral Unvanı',
          'type': 'title',
          'imageUrl': '👑',
          'price': 1000,
          'isActive': true,
        },
        'title_knight': {
          'name': 'Şövalye Unvanı',
          'type': 'title',
          'imageUrl': '⚔️',
          'price': 600,
          'isActive': true,
        },
        'title_mage': {
          'name': 'Büyücü Unvanı',
          'type': 'title',
          'imageUrl': '🔮',
          'price': 800,
          'isActive': true,
        },
        'title_assassin': {
          'name': 'Suikastçı Unvanı',
          'type': 'title',
          'imageUrl': '🗡️',
          'price': 700,
          'isActive': true,
        },
        'title_jester': {
          'name': 'Soytarı Unvanı',
          'type': 'title',
          'imageUrl': '🤡',
          'price': 200,
          'isActive': true,
        },
      };

      final batch = FirebaseFirestore.instance.batch();
      for (var entry in items.entries) {
        batch.set(cosmeticsRef.doc(entry.key), entry.value);
      }
      await batch.commit();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // --- Photo Moderation ---
  Future<void> approvePhoto(String targetUserId, String reportId) async {
    // Fotoğrafı onayla dersen raporu siliyoruz, flag vs koymuyoruz.
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .delete();
  }

  Future<void> banPhoto(String targetUserId, String reportId) async {
    // Kullanıcının avatarını kaldır ve avatarFlagged: true yap.
    final batch = FirebaseFirestore.instance.batch();

    batch.update(
      FirebaseFirestore.instance.collection('users').doc(targetUserId),
      {'avatarUrl': null, 'avatarFlagged': true},
    );

    // Raporu da kapat/sil
    batch.delete(
      FirebaseFirestore.instance.collection('reports').doc(reportId),
    );

    await batch.commit();
  }
}
