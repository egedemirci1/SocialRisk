import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/economy_repository.dart';
import '../domain/cosmetic_item_entity.dart';

class FirebaseEconomySource implements EconomyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<void> addPointsToWallet({
    required String uid,
    required int points,
  }) async {
    try {
      // Atomik işlemle mevcudun üstüne ekle (veya negatifse çıkar)
      await _userDoc(uid).set({
        'walletPoints': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Cüzdana puan eklenirken hata: ${e.message}');
    }
  }

  @override
  Future<void> distributeRewards(Map<String, int> playerRewards) async {
    if (playerRewards.isEmpty) return;

    final batch = _firestore.batch();
    playerRewards.forEach((uid, points) {
      if (points != 0) {
        batch.set(_userDoc(uid), {
          'walletPoints': FieldValue.increment(points),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Ödül dağıtımı başarısız: ${e.message}');
    }
  }

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    try {
      final docRef = _userDoc(uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Kullanıcı bulunamadı.");
        }

        final currentPoints = snapshot.data()?['walletPoints'] as int? ?? 0;
        final ownedCosmetics = List<String>.from(
          snapshot.data()?['ownedCosmetics'] ?? [],
        );

        if (ownedCosmetics.contains(cosmeticId)) {
          throw Exception("Bu eşyaya zaten sahipsiniz.");
        }

        if (currentPoints < price) {
          throw Exception("Yetersiz bakiye.");
        }

        // Parayı düş ve envantere ekle
        final Map<String, dynamic> updates = {
          'walletPoints': currentPoints - price,
          'ownedCosmetics': FieldValue.arrayUnion([cosmeticId]),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Eğer kategori ise ownedCategories listesine de ekle
        final cosmeticDoc = await transaction.get(
          _firestore.collection('cosmetics').doc(cosmeticId),
        );
        if (cosmeticDoc.exists) {
          final data = cosmeticDoc.data()!;
          final type = data['type'] as String?;
          if (type == 'category') {
            final categoryName =
                data['categoryName'] as String? ?? data['name'] as String?;
            if (categoryName != null) {
              updates['ownedCategories'] = FieldValue.arrayUnion([
                categoryName,
              ]);
            }
          }
        }

        transaction.update(docRef, updates);
      });
    } on FirebaseException catch (e) {
      throw Exception('Satın alma işlemi başarısız: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> setActiveFrame({
    required String uid,
    required String? cosmeticId,
  }) async {
    await _userDoc(uid).update({'activeFrame': cosmeticId});
  }

  @override
  Future<void> setActiveTitle({
    required String uid,
    required String? cosmeticId,
  }) async {
    await _userDoc(uid).update({'activeTitle': cosmeticId});
  }

  @override
  Future<List<CosmeticItemEntity>> fetchCosmetics() async {
    try {
      final snapshot = await _firestore.collection('cosmetics').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CosmeticItemEntity(
          id: doc.id,
          name: data['name'] as String? ?? 'Adsız',
          description: data['description'] as String? ?? '',
          imageUrl: data['imageUrl'] as String? ?? '📦',
          price: data['price'] as int? ?? 0,
          type: data['type'] as String? ?? 'frame',
          categoryName: data['categoryName'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Kozmetik ürünler çekilirken hata: $e');
      return [];
    }
  }
}
