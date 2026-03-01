import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_task_entity.dart';
import '../../../shared/models/enums.dart';

class FirebaseUserTaskSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('custom_tasks');

  Stream<List<UserTaskEntity>> watchUserTasks(String uid) {
    return _userTasksRef(
      uid,
    ).orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) => _docToEntity(doc)).toList();
    });
  }

  Future<String> addTask({
    required String uid,
    required UserTaskEntity task,
  }) async {
    final doc = await _userTasksRef(uid).add({
      'category': task.category,
      'content': task.content,
      'difficulty': task.difficulty,
      'type': task.type.name,
      'tags': task.tags,
      'isActive': task.isActive,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateTask({
    required String uid,
    required UserTaskEntity task,
  }) async {
    await _userTasksRef(uid).doc(task.id).update({
      'category': task.category,
      'content': task.content,
      'difficulty': task.difficulty,
      'type': task.type.name,
      'tags': task.tags,
      'isActive': task.isActive,
    });
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    await _userTasksRef(uid).doc(taskId).delete();
  }

  UserTaskEntity _docToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserTaskEntity(
      id: doc.id,
      category: data['category'] as String? ?? 'Custom',
      content: data['content'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'medium',
      type: TaskType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TaskType.action,
      ),
      tags: List<String>.from(data['tags'] ?? ['custom']),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
