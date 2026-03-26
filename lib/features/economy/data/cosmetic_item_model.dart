import '../domain/cosmetic_item_entity.dart';

class CosmeticItemModel {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String imageUrl;
  final int price;
  final String type;

  const CosmeticItemModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.imageUrl,
    required this.price,
    required this.type,
  });

  factory CosmeticItemModel.fromJson(Map<String, dynamic> json, String docId) {
    return CosmeticItemModel(
      id: docId,
      name: json['name'] as String? ?? 'İsimsiz Eşya',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? 'Unnamed Item',
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      type: json['type'] as String? ?? 'frame',
    );
  }

  CosmeticItemEntity toEntity() {
    return CosmeticItemEntity(
      id: id,
      name: name,
      nameEn: nameEn,
      description: description,
      descriptionEn: descriptionEn,
      imageUrl: imageUrl,
      price: price,
      type: type,
    );
  }
}
