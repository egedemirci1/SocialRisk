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
    await _userDoc(uid).set({
      'walletPoints': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
    // Return hardcoded cosmetics instead of pulling from Firestore
    final items = {
      'frame_fire': {
        'name': 'Ateş Çerçevesi',
        'type': 'frame',
        'imageUrl': '🔥',
        'price': 500,
      },
      'frame_ice': {
        'name': 'Buz Çerçevesi',
        'type': 'frame',
        'imageUrl': '🧊',
        'price': 500,
      },
      'frame_flower': {
        'name': 'Çiçek Çerçevesi',
        'type': 'frame',
        'imageUrl': '🌸',
        'price': 400,
      },
      'frame_shield': {
        'name': 'Kalkan Çerçevesi',
        'type': 'frame',
        'imageUrl': '🛡️',
        'price': 600,
      },
      'title_king': {
        'name': 'Kral',
        'type': 'title',
        'imageUrl': '👑',
        'price': 1000,
      },
      'title_knight': {
        'name': 'Şövalye',
        'type': 'title',
        'imageUrl': '⚔️',
        'price': 600,
      },
      'title_mage': {
        'name': 'Büyücü',
        'type': 'title',
        'imageUrl': '🔮',
        'price': 800,
      },
      'title_assassin': {
        'name': 'Suikastçı',
        'type': 'title',
        'imageUrl': '🗡️',
        'price': 700,
      },
      'title_jester': {
        'name': 'Soytarı',
        'type': 'title',
        'imageUrl': '🤡',
        'price': 200,
      },
      'title_champion': {
        'name': 'Şampiyon',
        'type': 'title',
        'imageUrl': '🏆',
        'price': 1200,
      },
      'title_legend': {
        'name': 'Efsane',
        'type': 'title',
        'imageUrl': '🐉',
        'price': 2000,
      },
      'title_leader': {
        'name': 'Lider',
        'type': 'title',
        'imageUrl': '🌟',
        'price': 1500,
      },
      'title_shadow': {
        'name': 'Gölge',
        'type': 'title',
        'imageUrl': '🥷',
        'price': 1000,
      },
      'frame_ivy': {
        'name': 'Sarmaşık Çerçevesi',
        'type': 'frame',
        'imageUrl': '🌿',
        'price': 450,
      },
      'frame_neon': {
        'name': 'Neon Çerçevesi',
        'type': 'frame',
        'imageUrl': '⚡',
        'price': 700,
      },
      'frame_stars': {
        'name': 'Yıldız Yağmuru Çerçevesi',
        'type': 'frame',
        'imageUrl': '⭐',
        'price': 900,
      },
      'frame_lightning': {
        'name': 'Yıldırım Çerçevesi',
        'type': 'frame',
        'imageUrl': '🌩️',
        'price': 800,
      },
    };

    return items.entries.map((entry) {
      final docData = entry.value;
      return CosmeticItemModel(
        id: entry.key,
        name: docData['name'] as String,
        description: '',
        imageUrl: docData['imageUrl'] as String,
        price: docData['price'] as int,
        type: docData['type'] as String,
      ).toEntity();
    }).toList();
  }
}
