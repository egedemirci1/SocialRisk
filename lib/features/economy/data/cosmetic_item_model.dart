import '../domain/cosmetic_item_entity.dart';

class CosmeticItemModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final String type;

  const CosmeticItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.type,
  });

  factory CosmeticItemModel.fromJson(Map<String, dynamic> json, String docId) {
    return CosmeticItemModel(
      id: docId,
      name: json['name'] as String? ?? 'İsimsiz Eşya',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      type: json['type'] as String? ?? 'frame',
    );
  }

  CosmeticItemEntity toEntity() {
    return CosmeticItemEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      type: type,
    );
  }
}
