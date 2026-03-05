import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Return hardcoded local list instead of fetching from Firestore
    return [
      const CosmeticItemEntity(
        id: 'frame_fire',
        name: 'Ateş Çerçevesi',
        description: '',
        imageUrl: '🔥',
        price: 500,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_ice',
        name: 'Buz Çerçevesi',
        description: '',
        imageUrl: '🧊',
        price: 500,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_flower',
        name: 'Çiçek Çerçevesi',
        description: '',
        imageUrl: '🌸',
        price: 400,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_shield',
        name: 'Kalkan Çerçevesi',
        description: '',
        imageUrl: '🛡️',
        price: 600,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_ivy',
        name: 'Doğa Çerçevesi',
        description: '',
        imageUrl: '🌿',
        price: 400,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_neon',
        name: 'Neon Çerçeve',
        description: '',
        imageUrl: '⚡',
        price: 700,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_stars',
        name: 'Yıldız Çerçevesi',
        description: '',
        imageUrl: '⭐',
        price: 800,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_lightning',
        name: 'Şimşek Çerçevesi',
        description: '',
        imageUrl: '🌩️',
        price: 600,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'title_king',
        name: 'Kral Unvanı',
        description: '',
        imageUrl: '👑',
        price: 1000,
        type: 'title',
      ),
      const CosmeticItemEntity(
        id: 'title_knight',
        name: 'Şövalye Unvanı',
        description: '',
        imageUrl: '⚔️',
        price: 600,
        type: 'title',
      ),
      const CosmeticItemEntity(
        id: 'title_mage',
        name: 'Büyücü Unvanı',
        description: '',
        imageUrl: '🔮',
        price: 800,
        type: 'title',
      ),
      const CosmeticItemEntity(
        id: 'title_assassin',
        name: 'Suikastçı Unvanı',
        description: '',
        imageUrl: '🗡️',
        price: 700,
        type: 'title',
      ),
      const CosmeticItemEntity(
        id: 'title_jester',
        name: 'Soytarı Unvanı',
        description: '',
        imageUrl: '🤡',
        price: 200,
        type: 'title',
      ),
      const CosmeticItemEntity(
        id: 'scenario_18',
        name: 'Kapalı Gişe (18+)',
        description: 'Daha cesur ve yetişkinlere yönelik hikayeler.',
        imageUrl: '🔞',
        price: 1500,
        type: 'category',
        categoryName: 'Kapalı Gişe',
      ),
      const CosmeticItemEntity(
        id: 'scenario_romance',
        name: 'Aşkın Sahnesi',
        description: 'Romantik ve duygusal temalı hikayeler.',
        imageUrl: '❤️',
        price: 1000,
        type: 'category',
        categoryName: 'Aşkın Sahnesi',
      ),
      const CosmeticItemEntity(
        id: 'scenario_mystery',
        name: 'Gizemli Perde',
        description: 'Gerilim ve gizem dolu hikayeler.',
        imageUrl: '🔍',
        price: 1200,
        type: 'category',
        categoryName: 'Gizemli Perde',
      ),
    ];
  }
}
