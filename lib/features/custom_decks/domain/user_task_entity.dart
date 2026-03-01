import '../../../shared/models/enums.dart';

class UserTaskEntity {
  final String id;
  final String category;
  final String content;
  final String difficulty;
  final TaskType type;
  final List<String> tags;
  final bool isActive;
  final DateTime? createdAt;

  const UserTaskEntity({
    required this.id,
    required this.category,
    required this.content,
    required this.difficulty,
    this.type = TaskType.action,
    this.tags = const ['custom'],
    this.isActive = true,
    this.createdAt,
  });
}
