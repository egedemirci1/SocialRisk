import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/task_firestore_source.dart';
import '../domain/task_item_entity.dart';

part 'task_provider.g.dart';

@Riverpod(keepAlive: true)
TaskFirestoreSource taskSource(Ref ref) {
  return TaskFirestoreSource();
}

@riverpod
Stream<List<TaskItemEntity>> watchAllTasks(Ref ref) {
  return ref.watch(taskSourceProvider).watchAllTasks();
}

@riverpod
class TaskController extends _$TaskController {
  @override
  FutureOr<void> build() {}

  Future<void> submitFeedback({
    required String taskId,
    required String userId,
    required bool isLike,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskSourceProvider).submitFeedback(
        taskId: taskId,
        userId: userId,
        isLike: isLike,
      );
    });
  }
}
