import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_seed_migration.data1.part.dart';
part 'task_seed_migration.data2.part.dart';
part 'task_seed_migration.data3.part.dart';

class TaskSeedMigration {
  static final List<Map<String, dynamic>> seedData = [
    ..._taskSeedData1,
    ..._taskSeedData2,
    ..._taskSeedData3,
  ];

  /// Firebase'e seed data yükler. Zaten yüklüyse tekrar yüklemez.
  static Future<int> run() async {
    final firestore = FirebaseFirestore.instance;
    final tasksRef = firestore.collection('tasks');

    // Zaten görev varsa skip
    final existing = await tasksRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return 0; // Zaten seed edilmiş
    }

    final batch = firestore.batch();
    for (final task in seedData) {
      final docRef = tasksRef.doc();
      batch.set(docRef, {
        ...task,
        'likes': 0,
        'dislikes': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return seedData.length;
  }
}