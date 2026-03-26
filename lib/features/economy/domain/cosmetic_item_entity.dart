class CosmeticItemEntity {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String imageUrl;
  final int price;
  final String type; // 'frame', 'badge', etc.
  final String? categoryName; // Eğer bu bir kategoriyse, oyundaki adı

  const CosmeticItemEntity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.imageUrl,
    required this.price,
    required this.type,
    this.categoryName,
  });
}
