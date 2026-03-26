import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../domain/economy_repository.dart';
import '../domain/cosmetic_item_entity.dart';
import '../domain/economy_exceptions.dart';

class FirebaseEconomySource implements EconomyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  FirebaseEconomySource({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

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

    try {
      final callable = _functions.httpsCallable('distributeRewards');
      await callable.call(<String, dynamic>{
        'playerRewards': playerRewards,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Ödül dağıtımı başarısız: ${e.message}');
    } on FirebaseException catch (e) {
      throw Exception('Ödül dağıtımı başarısız: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> buyCosmetic({
    required String uid,
    required String cosmeticId,
    required int price,
  }) async {
    print('=== BUY COSMETIC DEBUG ===');
    print('UID: $uid');
    print('Cosmetic ID: $cosmeticId');
    print('Price: $price');
    
    try {
      // Geçici olarak client-side yap
      final userRef = _userDoc(uid);
      final cosmeticRef = _firestore.collection('cosmetics').doc(cosmeticId);
      
      print('User ref: ${userRef.path}');
      print('Cosmetic ref: ${cosmeticRef.path}');
      
      await _firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        final cosmeticSnap = await transaction.get(cosmeticRef);
        
        print('User exists: ${userSnap.exists}');
        print('Cosmetic exists: ${cosmeticSnap.exists}');
        
        if (!userSnap.exists) {
          throw Exception('Kullanıcı bulunamadı');
        }
        
        // cosmetics collection'ı olmadığı için bu kontrolü atla
        // if (!cosmeticSnap.exists) {
        //   throw Exception('Kozmetik ürün bulunamadı');
        // }
        
        final userData = userSnap.data()!;
        final currentWallet = userData['walletPoints'] as int? ?? userData['wallet'] as int? ?? 0;
        final ownedCosmetics = List<String>.from(userData['ownedCosmetics'] ?? []);
        
        print('Current wallet: $currentWallet');
        print('Owned cosmetics: $ownedCosmetics');
        
        if (currentWallet < price) {
          throw Exception('Yetersiz bakiye');
        }
        
        if (ownedCosmetics.contains(cosmeticId)) {
          throw Exception('Bu ürün zaten sahip olduğunuz');
        }
        
        // Transaction ile güncelle
        transaction.update(userRef, {
          'walletPoints': currentWallet - price,
          'ownedCosmetics': FieldValue.arrayUnion([cosmeticId]),
        });
        
        print('Transaction completed successfully');
      });
    } on FirebaseException catch (e) {
      throw Exception('Kozmetik satın alınırken bağlantı hatası: ${e.message}');
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
      // ── EFSANELİK
      const CosmeticItemEntity(id: 'title_legend', name: 'Efsane', description: 'En güçlü ünvan.', imageUrl: '⚡', price: 1200, type: 'title'),
      const CosmeticItemEntity(id: 'title_king', name: 'Kral', description: 'Tüm alanların hükümdarı.', imageUrl: '👑', price: 1000, type: 'title'),
      const CosmeticItemEntity(id: 'title_chosen', name: 'Seçilmiş', description: 'Kader tarafından seçilmiş.', imageUrl: '🌟', price: 900, type: 'title'),
      const CosmeticItemEntity(id: 'title_emperor', name: 'İmparator', description: 'İmparatorluk tacı.', imageUrl: '🏛️', price: 1500, type: 'title'),
      const CosmeticItemEntity(id: 'title_immortal', name: 'Ölümsüz', description: 'Çağlar ötesi güç.', imageUrl: '✨', price: 1800, type: 'title'),
      // ── SAVAŞÇI
      const CosmeticItemEntity(id: 'title_knight', name: 'Şövalye', description: 'Onurlu savaşçı.', imageUrl: '⚔️', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_warrior', name: 'Savaşçı', description: 'Savaş alanının efendisi.', imageUrl: '🗡️', price: 400, type: 'title'),
      const CosmeticItemEntity(id: 'title_arena', name: 'Arena Şampiyonu', description: 'Arenada yenilmez.', imageUrl: '🏆', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_berserker', name: 'Zorba', description: 'Korkusuz savaşçı.', imageUrl: '💪', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_commander', name: 'Komutan', description: 'Orduların lideri.', imageUrl: '🎖️', price: 700, type: 'title'),
      // ── GİZEM
      const CosmeticItemEntity(id: 'title_mage', name: 'Büyücü', description: 'Gizem ustası.', imageUrl: '🔮', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_shadow', name: 'Gölge', description: 'Karanlıkta kaybolur.', imageUrl: '🌑', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_alchemist', name: 'Simyacı', description: 'Her şeyi dönüştürebilir.', imageUrl: '⚗️', price: 700, type: 'title'),
      const CosmeticItemEntity(id: 'title_phantom', name: 'Hayalet', description: 'Kimse göremez.', imageUrl: '👻', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_oracle', name: 'Kahin', description: 'Geleceği görür.', imageUrl: '🔭', price: 900, type: 'title'),
      // ── EĞLENCELİ
      const CosmeticItemEntity(id: 'title_jester', name: 'Soytarı', description: 'Her ortamın neşesi.', imageUrl: '🤡', price: 200, type: 'title'),
      const CosmeticItemEntity(id: 'title_trickster', name: 'Oyunbaz', description: 'Hep bir şeyler çevirir.', imageUrl: '🃏', price: 300, type: 'title'),
      const CosmeticItemEntity(id: 'title_showman', name: 'Parti Canavarı', description: 'Her parti onun için.', imageUrl: '🪩', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_comedian', name: 'Komedyen', description: 'Herkesi güldürür.', imageUrl: '😂', price: 250, type: 'title'),
      const CosmeticItemEntity(id: 'title_chameleon', name: 'Kameleon', description: 'Her role girer.', imageUrl: '🦎', price: 400, type: 'title'),
      // ── HAFİFMEŞREP
      const CosmeticItemEntity(id: 'title_daredevil', name: 'Pervasız', description: 'Hiçten korkmaz.', imageUrl: '🔥', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_nightowl', name: 'Gece Kuşu', description: 'Gece hayatının efendisi.', imageUrl: '🦉', price: 450, type: 'title'),
      const CosmeticItemEntity(id: 'title_flirt', name: 'Çapkın', description: 'Herkesi büyüler.', imageUrl: '😏', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_rebel', name: 'İsyancı', description: 'Kurallara meydan okur.', imageUrl: '💀', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_wild', name: 'Başıbozuk', description: 'Kontrol edilemez.', imageUrl: '🎭', price: 400, type: 'title'),
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
        name: 'Aşkın Dansı',
        description: 'Romantik ve duygusal temalı hikayeler.',
        imageUrl: '❤️',
        price: 1000,
        type: 'category',
        categoryName: 'Aşkın Dansı',
      ),
      const CosmeticItemEntity(
        id: 'scenario_mystery',
        name: 'Gizemli Parti',
        description: 'Gerilim ve gizem dolu hikayeler.',
        imageUrl: '🔍',
        price: 1200,
        type: 'category',
        categoryName: 'Gizemli Parti',
      ),
    ];
  }
}
