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
    try {
      final callable = _functions.httpsCallable('buyCosmetic');
      await callable.call(<String, dynamic>{
        'cosmeticId': cosmeticId,
        'price': price,
        'uid': uid,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Satın alma sırasında hata oluştu');
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
      const CosmeticItemEntity(id: 'title_legend', name: 'Parti Efsanesi', nameEn: 'Party Legend', description: 'Masada anlatılan hikâyelerin kahramanı.', descriptionEn: 'The hero of table tales.', imageUrl: '⚡', price: 1200, type: 'title'),
      const CosmeticItemEntity(id: 'title_king', name: 'Masa Kralı', nameEn: 'Table King', description: 'Söz sende, tempo sende.', descriptionEn: 'You set the pace.', imageUrl: '👑', price: 1000, type: 'title'),
      const CosmeticItemEntity(id: 'title_chosen', name: 'Gecenin Seçilmişi', nameEn: 'Chosen of the Night', description: 'Şans mı, sezgi mi? Kim bilir.', descriptionEn: 'Luck or instinct? Who knows.', imageUrl: '🌟', price: 900, type: 'title'),
      const CosmeticItemEntity(id: 'title_emperor', name: 'Senaryo İmparatoru', nameEn: 'Scenario Emperor', description: 'Rol yapmanın zirvesi.', descriptionEn: 'Peak roleplay.', imageUrl: '�', price: 1500, type: 'title'),
      const CosmeticItemEntity(id: 'title_immortal', name: 'Bitmeyen Enerji', nameEn: 'Endless Energy', description: 'Oyun biter, sen bitmezsin.', descriptionEn: 'The game ends, you don’t.', imageUrl: '✨', price: 1800, type: 'title'),
      // ── SAVAŞÇI
      const CosmeticItemEntity(id: 'title_knight', name: 'Takım Kaptanı', nameEn: 'Team Captain', description: 'Herkesi aynı hedefe kilitler.', descriptionEn: 'Keeps everyone on target.', imageUrl: '⚔️', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_warrior', name: 'Hamle Savaşçısı', nameEn: 'Move Warrior', description: 'Kararlı oynar, pes etmez.', descriptionEn: 'Plays hard, never quits.', imageUrl: '🗡️', price: 400, type: 'title'),
      const CosmeticItemEntity(id: 'title_arena', name: 'Meydan Okuyan', nameEn: 'Challenger', description: 'Her tur yeni bir iddia.', descriptionEn: 'A new challenge each round.', imageUrl: '🏆', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_berserker', name: 'Kaos Ustası', nameEn: 'Chaos Bringer', description: 'Ortam ısınır, oyun kızışır.', descriptionEn: 'Turns up the heat.', imageUrl: '�', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_commander', name: 'Strateji Komutanı', nameEn: 'Strategy Commander', description: 'Plan yapar, masayı yönetir.', descriptionEn: 'Plans and leads the table.', imageUrl: '🎖️', price: 700, type: 'title'),
      // ── GİZEM
      const CosmeticItemEntity(id: 'title_mage', name: 'Blöf Büyücüsü', nameEn: 'Bluff Mage', description: 'Bir cümleyle tüm masayı çevirir.', descriptionEn: 'Flips the table with one line.', imageUrl: '🔮', price: 800, type: 'title'),
      const CosmeticItemEntity(id: 'title_shadow', name: 'Sessiz Gölge', nameEn: 'Silent Shadow', description: 'Az konuşur, çok iz bırakır.', descriptionEn: 'Few words, big impact.', imageUrl: '🌑', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_alchemist', name: 'Durum Simyacısı', nameEn: 'Situation Alchemist', description: 'Kötü turu avantaja çevirir.', descriptionEn: 'Turns bad rounds into wins.', imageUrl: '⚗️', price: 700, type: 'title'),
      const CosmeticItemEntity(id: 'title_phantom', name: 'Görünmez Oyuncu', nameEn: 'Invisible Player', description: 'Kimse anlamadan işi bitirir.', descriptionEn: 'Finishes the job unseen.', imageUrl: '👻', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_oracle', name: 'Sezgi Ustası', nameEn: 'Intuition Master', description: 'İpucunu görür, doğru hamleyi yapar.', descriptionEn: 'Sees the clue, makes the call.', imageUrl: '🔭', price: 900, type: 'title'),
      // ── EĞLENCELİ
      const CosmeticItemEntity(id: 'title_jester', name: 'Mizah Ustası', nameEn: 'Joke Master', description: 'Gerilim bile gülüşle çözülür.', descriptionEn: 'Even tension breaks with laughter.', imageUrl: '🤡', price: 200, type: 'title'),
      const CosmeticItemEntity(id: 'title_trickster', name: 'Kural Büken', nameEn: 'Rule Bender', description: 'Açık arar, fırsatı yakalar.', descriptionEn: 'Finds gaps and takes chances.', imageUrl: '🃏', price: 300, type: 'title'),
      const CosmeticItemEntity(id: 'title_showman', name: 'Sahne Senin', nameEn: 'All Eyes On You', description: 'Masayı şova çevirir.', descriptionEn: 'Turns the table into a show.', imageUrl: '🪩', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_comedian', name: 'Kahkaha Fabrikası', nameEn: 'Laugh Factory', description: 'Her tur bir espri, bir kahkaha.', descriptionEn: 'A joke and a laugh every round.', imageUrl: '😂', price: 250, type: 'title'),
      const CosmeticItemEntity(id: 'title_chameleon', name: 'Rol Değiştiren', nameEn: 'Role Shifter', description: 'Kimliğini saklar, role bürünür.', descriptionEn: 'Hides identity, shifts roles.', imageUrl: '🦎', price: 400, type: 'title'),
      // ── HAFİFMEŞREP
      const CosmeticItemEntity(id: 'title_daredevil', name: 'Risk Alan', nameEn: 'Risk Taker', description: 'Cesur oynar, büyük kazanır.', descriptionEn: 'Plays bold, wins big.', imageUrl: '🔥', price: 600, type: 'title'),
      const CosmeticItemEntity(id: 'title_nightowl', name: 'Gece Modu', description: 'Gece daha iyi oynar.', nameEn: 'Night Mode', descriptionEn: 'Plays better after dark.', imageUrl: '🦉', price: 450, type: 'title'),
      const CosmeticItemEntity(id: 'title_flirt', name: 'Tatlı Dilli', nameEn: 'Smooth Talker', description: 'İkna gücü yüksek.', descriptionEn: 'High persuasion power.', imageUrl: '😏', price: 350, type: 'title'),
      const CosmeticItemEntity(id: 'title_rebel', name: 'Kuralsız', nameEn: 'Rulebreaker', description: 'Alışılmışın dışında oynar.', descriptionEn: 'Plays outside the box.', imageUrl: '�', price: 500, type: 'title'),
      const CosmeticItemEntity(id: 'title_wild', name: 'Deli Dolu', nameEn: 'Wild Card', description: 'Ne yapacağı belli olmaz.', descriptionEn: 'Unpredictable to the end.', imageUrl: '🎭', price: 400, type: 'title'),
      // PREMIUM SENARYOLAR
      const CosmeticItemEntity(
        id: 'scenario_standup',
        name: 'Açık Mikrofon',
        nameEn: 'Open Mic Night',
        description: 'Stand-up, pazarlama ve karakter gösterileri ağırlıklı olarak çıkar.',
        descriptionEn:
            'Includes 120 tasks focused on stand-up bits, pitches, and character performances.',
        imageUrl: '🎤',
        price: 500,
        type: 'category',
        categoryName: 'Stand-Up',
      ),
      const CosmeticItemEntity(
        id: 'scenario_kivirma',
        name: 'Kıvırma Sanatı',
        nameEn: 'The Art of Wiggling Out',
        description: 'Kriz yönetimi, kaçış ve yalancılık görevleri ağırlıklı olarak çıkar.',
        descriptionEn:
            'Includes 120 tasks centered on crisis management, clever excuses, and escape moves.',
        imageUrl: '😅',
        price: 500,
        type: 'category',
        categoryName: 'Kıvırma',
      ),
      const CosmeticItemEntity(
        id: 'scenario_kaos',
        name: 'Kaos Mühendisi',
        nameEn: 'Chaos Engineer',
        description: 'Hayatta kalma ve yaratıcı kaçış görevleri ağırlıklı olarak çıkar.',
        descriptionEn:
            'Includes 120 tasks built around survival, improvisation, and creative problem-solving.',
        imageUrl: '🔧',
        price: 500,
        type: 'category',
        categoryName: 'Kaos Mühendisi',
      ),
      const CosmeticItemEntity(
        id: 'scenario_vaat',
        name: 'Boş Vaatler',
        nameEn: 'Empty Promises',
        description: 'Politik vaatler ve absürt yasaklar görevleri ağırlıklı olarak çıkar.',
        descriptionEn:
            'Includes 120 tasks featuring political promises, campaign drama, and absurd rule-making.',
        imageUrl: '💬',
        price: 500,
        type: 'category',
        categoryName: 'Boş Vaatler',
      ),
    ];
  }
}
