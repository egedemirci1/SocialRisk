class CosmeticItemEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String type; // 'frame', 'badge', etc.

  const CosmeticItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.type,
  });
}
