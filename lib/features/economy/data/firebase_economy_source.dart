import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/economy_repository.dart';
import '../domain/cosmetic_item_entity.dart';
import 'cosmetic_item_model.dart';

class FirebaseEconomySource implements EconomyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {
    // Atomik işlemle mevcudun üstüne ekle (veya negatifse çıkar)
    await _userDoc(uid).update({
      'walletPoints': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    final docRef = _userDoc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("Kullanıcı bulunamadı.");
      }

      final currentPoints = snapshot.data()?['walletPoints'] as int? ?? 0;
      final ownedCosmetics =
          List<String>.from(snapshot.data()?['ownedCosmetics'] ?? []);

      if (ownedCosmetics.contains(cosmeticId)) {
        throw Exception("Bu eşyaya zaten sahipsiniz.");
      }

      if (currentPoints < price) {
        throw Exception("Yetersiz bakiye.");
      }

      // Parayı düş ve envantere ekle
      transaction.update(docRef, {
        'walletPoints': currentPoints - price,
        'ownedCosmetics': FieldValue.arrayUnion([cosmeticId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  }) async {
    await _userDoc(uid).update({
      'activeFrame': cosmeticId,
    });
  }

  @override
  Future<List<CosmeticItemEntity>> fetchCosmetics() async {
    final snapshot = await _firestore.collection('cosmetics').get();
    return snapshot.docs.map((doc) {
      final model = CosmeticItemModel.fromJson(doc.data(), doc.id);
      return model.toEntity();
    }).toList();
  }
}
