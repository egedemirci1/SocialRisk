import '../../../shared/models/enums.dart';

/// Firestore'daki görev dokümanını temsil eden entity.
/// Admin paneli ve oyun içi görev çekme için kullanılır.
class TaskItemEntity {
  final String id;
  final String category;
  final String content;
  final String difficulty; // easy, medium, hard
  final TaskType type;
  final List<String> tags; // classic, family, couple, adult, vb.
  final String? answer; // Sadece Bilgi kategorisi için doğru cevap
  final int likes;
  final int dislikes;
  final bool isActive;
  final DateTime? createdAt;

  const TaskItemEntity({
    required this.id,
    required this.category,
    required this.content,
    required this.difficulty,
    this.type = TaskType.action,
    this.tags = const ['classic'],
    this.likes = 0,
    this.dislikes = 0,
    this.isActive = true,
    this.createdAt,
    this.answer,
  });
}
