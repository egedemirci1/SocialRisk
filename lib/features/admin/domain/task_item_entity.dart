/// Firestore'daki görev dokümanını temsil eden entity.
/// Admin paneli ve oyun içi görev çekme için kullanılır.
class TaskItemEntity {
  final String id;
  final String category;
  final String content;
  final String difficulty; // easy, medium, hard
  final List<String> presets; // classic, family, couple, adult
  final int likes;
  final int dislikes;
  final bool isActive;
  final DateTime? createdAt;

  const TaskItemEntity({
    required this.id,
    required this.category,
    required this.content,
    required this.difficulty,
    this.presets = const ['classic'],
    this.likes = 0,
    this.dislikes = 0,
    this.isActive = true,
    this.createdAt,
  });
}
