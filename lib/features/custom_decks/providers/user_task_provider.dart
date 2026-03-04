import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firebase_user_task_source.dart';
import '../domain/user_task_entity.dart';

part 'user_task_provider.g.dart';

@Riverpod(keepAlive: true)
FirebaseUserTaskSource userTaskSource(Ref ref) {
  return FirebaseUserTaskSource();
}

@riverpod
Stream<List<UserTaskEntity>> watchCustomTasks(Ref ref, String uid) {
  return ref.watch(userTaskSourceProvider).watchUserTasks(uid);
}

@riverpod
class CustomTaskController extends _$CustomTaskController {
  @override
  FutureOr<void> build() {}

  Future<void> addTask({
    required String uid,
    required UserTaskEntity task,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(userTaskSourceProvider);
    final result = await AsyncValue.guard(
      () => repo.addTask(uid: uid, task: task),
    );
    if (!ref.mounted) return;
    state = result;
  }

  Future<void> updateTask({
    required String uid,
    required UserTaskEntity task,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(userTaskSourceProvider);
    final result = await AsyncValue.guard(
      () => repo.updateTask(uid: uid, task: task),
    );
    if (!ref.mounted) return;
    state = result;
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    state = const AsyncLoading();
    final repo = ref.read(userTaskSourceProvider);
    final result = await AsyncValue.guard(
      () => repo.deleteTask(uid: uid, taskId: taskId),
    );
    if (!ref.mounted) return;
    state = result;
  }
}
