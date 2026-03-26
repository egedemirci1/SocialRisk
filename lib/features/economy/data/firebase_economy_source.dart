import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../domain/economy_repository.dart';
import '../domain/cosmetic_item_entity.dart';

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
        nameEn: 'Fire Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🔥',
        price: 500,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_ice',
        name: 'Buz Çerçevesi',
        nameEn: 'Ice Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🧊',
        price: 500,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_flower',
        name: 'Çiçek Çerçevesi',
        nameEn: 'Flower Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🌸',
        price: 400,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_shield',
        name: 'Kalkan Çerçevesi',
        nameEn: 'Shield Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🛡️',
        price: 600,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_ivy',
        name: 'Doğa Çerçevesi',
        nameEn: 'Nature Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🌿',
        price: 400,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_neon',
        name: 'Neon Çerçeve',
        nameEn: 'Neon Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '⚡',
        price: 700,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_stars',
        name: 'Yıldız Çerçevesi',
        nameEn: 'Star Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '⭐',
        price: 800,
        type: 'frame',
      ),
      const CosmeticItemEntity(
        id: 'frame_lightning',
        name: 'Şimşek Çerçevesi',
        nameEn: 'Lightning Frame',
        description: '',
        descriptionEn: '',
        imageUrl: '🌩️',
        price: 600,
        type: 'frame',
      ),
      // ── EFSANELİK
      const CosmeticItemEntity(id: 'title_legend', name: 'Efsane', nameEn: 'Legend', description: 'En güçlü ünvan.', descriptionEn: 'The most powerful title.', imageUrl: '⚡', price: 1200, type: 'title'),
      const CosmeticItemEntity(id: 'title_king', name: 'Kral', nameEn: 'King', description: 'Tüm alanların hükümdarı.', descriptionEn: 'Ruler of all realms.', imageUrl: '👑', price: 1000, type: 'title'),
      const CosmeticItemEntity(id: 'title_chosen', name: 'Seçilmiş', nameEn: 'Chosen One', description: 'Kader tarafından seçilmiş.', descriptionEn: 'Chosen by fate.', imageUrl: '🌟', price: 900, type: 'title'),
      const CosmeticItemEntity(id: 'title_emperor', name: 'İmparator', nameEn: 'Emperor', description: 'İmparatorluk tacı.', descriptionEn: 'Imperial crown.', imageUrl: '🏛️', price: 1500, type: 'title'),
      const CosmeticItemEntity(id: 'title_immortal', name: 'Ölümsüz', nameEn: 'Immortal', description: 'Çağlar ötesi güç.', descriptionEn: 'Power beyond ages.', imageUrl: '✨', price: 1800, type: 'title'),
      // ── SAVAŞÇI
      const CosmeticItemEntity(id: 'title_knight', name: 'Şövalye', nameEn: 'Knight', description: 'Onurlu savaşçı.', descriptionEn: 'Honorable warrior.', imageUrl: '⚔️', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_warrior', name: 'Savaşçı', nameEn: 'Warrior', description: 'Savaş alanının efendisi.', descriptionEn: 'Master of the battlefield.', imageUrl: '🗡️', price: 400, type: 'title'),
      const CosmeticItemEntity(id: 'title_arena', name: 'Arena Şampiyonu', nameEn: 'Arena Champion', description: 'Arenada yenilmez.', descriptionEn: 'Invincible in the arena.', imageUrl: '🏆', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_berserker', name: 'Zorba', nameEn: 'Berserker', description: 'Korkusuz savaşçı.', descriptionEn: 'Fearless warrior.', imageUrl: '💪', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_commander', name: 'Komutan', nameEn: 'Commander', description: 'Orduların lideri.', descriptionEn: 'Leader of armies.', imageUrl: '🎖️', price: 700, type: 'title'),
      // ── GİZEM
      const CosmeticItemEntity(id: 'title_mage', name: 'Büyücü', nameEn: 'Mage', description: 'Gizem ustası.', descriptionEn: 'Master of mystery.', imageUrl: '🔮', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_shadow', name: 'Gölge', nameEn: 'Shadow', description: 'Karanlıkta kaybolur.', descriptionEn: 'Lost in the dark.', imageUrl: '🌑', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_alchemist', name: 'Simyacı', nameEn: 'Alchemist', description: 'Her şeyi dönüştürebilir.', descriptionEn: 'Can transform anything.', imageUrl: '⚗️', price: 700, type: 'title'),
      const CosmeticItemEntity(id: 'title_phantom', name: 'Hayalet', nameEn: 'Phantom', description: 'Kimse göremez.', descriptionEn: 'No one can see.', imageUrl: '👻', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_oracle', name: 'Kahin', nameEn: 'Oracle', description: 'Geleceği görür.', descriptionEn: 'Sees the future.', imageUrl: '🔭', price: 900, type: 'title'),
      // ── EĞLENCELİ
      const CosmeticItemEntity(id: 'title_jester', name: 'Soytarı', nameEn: 'Jester', description: 'Her ortamın neşesi.', descriptionEn: 'Joy of every environment.', imageUrl: '🤡', price: 200, type: 'title'),
      const CosmeticItemEntity(id: 'title_trickster', name: 'Oyunbaz', nameEn: 'Trickster', description: 'Hep bir şeyler çevirir.', descriptionEn: 'Always up to something.', imageUrl: '🃏', price: 300, type: 'title'),
      const CosmeticItemEntity(id: 'title_showman', name: 'Parti Canavarı', nameEn: 'Party Animal', description: 'Her parti onun için.', descriptionEn: 'Every party is for them.', imageUrl: '🪩', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_comedian', name: 'Komedyen', nameEn: 'Comedian', description: 'Herkesi güldürür.', descriptionEn: 'Makes everyone laugh.', imageUrl: '😂', price: 250, type: 'title'),
      const CosmeticItemEntity(id: 'title_chameleon', name: 'Kameleon', nameEn: 'Chameleon', description: 'Her role girer.', descriptionEn: 'Fits every role.', imageUrl: '🦎', price: 400, type: 'title'),
      // ── HAFİFMEŞREP
      const CosmeticItemEntity(id: 'title_daredevil', name: 'Pervasız', nameEn: 'Daredevil', description: 'Hiçten korkmaz.', descriptionEn: 'Afraid of nothing.', imageUrl: '🔥', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_nightowl', name: 'Gece Kuşu', description: 'Gece hayatının efendisi.', nameEn: 'Night Owl', descriptionEn: 'Master of nightlife.', imageUrl: '🦉', price: 450, type: 'title'),
      const CosmeticItemEntity(id: 'title_flirt', name: 'Çapkın', nameEn: 'Flirt', description: 'Herkesi büyüler.', descriptionEn: 'Enchants everyone.', imageUrl: '😏', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_rebel', name: 'İsyancı', nameEn: 'Rebel', description: 'Kurallara meydan okur.', descriptionEn: 'Challenges rules.', imageUrl: '💀', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_wild', name: 'Başıbozuk', nameEn: 'Wild One', description: 'Kontrol edilemez.', descriptionEn: 'Uncontrollable.', imageUrl: '🎭', price: 400, type: 'title'),
      const CosmeticItemEntity(
        id: 'scenario_18',
        name: 'Kapalı Gişe (18+)',
        nameEn: 'Sold Out (18+)',
        description: 'Daha cesur ve yetişkinlere yönelik hikayeler.',
        descriptionEn: 'Bolder and adult-oriented stories.',
        imageUrl: '🔞',
        price: 1500,
        type: 'category',
        categoryName: 'Kapalı Gişe',
      ),
      const CosmeticItemEntity(
        id: 'scenario_romance',
        name: 'Aşkın Dansı',
        nameEn: 'Dance of Love',
        description: 'Romantik ve duygusal temalı hikayeler.',
        descriptionEn: 'Romantic and emotional themed stories.',
        imageUrl: '❤️',
        price: 1000,
        type: 'category',
        categoryName: 'Aşkın Dansı',
      ),
      const CosmeticItemEntity(
        id: 'scenario_mystery',
        name: 'Gizemli Parti',
        nameEn: 'Mystery Party',
        description: 'Gerilim ve gizem dolu hikayeler.',
        descriptionEn: 'Stories full of suspense and mystery.',
        imageUrl: '🔍',
        price: 1200,
        type: 'category',
        categoryName: 'Gizemli Parti',
      ),
      const CosmeticItemEntity(
        id: 'scenario_comedy',
        name: 'Fars Komedisi',
        nameEn: 'Farce Comedy',
        description: 'Komik ve eğlenceli görevler ağırlıklı olarak çıkar.',
        descriptionEn: 'Funny and entertaining tasks appear predominantly.',
        imageUrl: '🎭',
        price: 800,
        type: 'category',
        categoryName: 'Fars Komedisi',
      ),
      const CosmeticItemEntity(
        id: 'scenario_tragedy',
        name: 'Antik Trajedi',
        nameEn: 'Ancient Tragedy',
        description: 'Dramatik ve cesur görevler ağırlıklı olarak çıkar.',
        descriptionEn: 'Dramatic and bold tasks appear predominantly.',
        imageUrl: '💀',
        price: 1200,
        type: 'category',
        categoryName: 'Antik Trajedi',
      ),
      const CosmeticItemEntity(
        id: 'scenario_sci_fi',
        name: 'Geleceğin Rolü',
        nameEn: 'Role of the Future',
        description: 'Bilimkurgu temalı görevler ağırlıklı olarak çıkar.',
        descriptionEn: 'Science fiction themed tasks appear predominantly.',
        imageUrl: '🚀',
        price: 1300,
        type: 'category',
        categoryName: 'Geleceğin Rolü',
      ),
    ];
  }
}
