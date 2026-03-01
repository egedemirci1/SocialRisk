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
    state = await AsyncValue.guard(
      () => ref.read(userTaskSourceProvider).addTask(uid: uid, task: task),
    );
  }

  Future<void> updateTask({
    required String uid,
    required UserTaskEntity task,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userTaskSourceProvider).updateTask(uid: uid, task: task),
    );
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(userTaskSourceProvider).deleteTask(uid: uid, taskId: taskId),
    );
  }
}
