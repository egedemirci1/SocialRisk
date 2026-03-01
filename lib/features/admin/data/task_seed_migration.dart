import 'package:cloud_firestore/cloud_firestore.dart';

/// Mevcut hardcoded görevleri Firestore'a yükleyen tek seferlik migration.
/// Çalıştırmak için: Admin paneline "Seed" butonu eklenecek.
///
/// Multiplier mapping:
///   1 → easy
///   2 → medium
///   3 → hard
///
/// Tüm mevcut görevler classic + adult preset ile etiketlenir.
class TaskSeedMigration {
  static final List<Map<String, dynamic>> seedData = [
    // ── CESARET ─────────────────────────────────
    {
      'category': 'Cesaret',
      'content': 'Telefondaki son aramanı herkese göster.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Yanındaki kişiye 1 dakika boyunca iltifat et.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Rastgele bir kişiyi ara ve "Seni özledim" de.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Gruptaki en komik anını anlat.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Telefonundaki son fotoğrafı herkese göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': '30 saniye boyunca robot gibi dans et.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Instagram hikayene "Bu oyun harika!" yaz ve paylaş.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── İTİRAF ──────────────────────────────────
    {
      'category': 'İtiraf',
      'content': 'Hayatında en çok utandığın anı anlat.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'En son ne hakkında yalan söyledin?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content':
          'Gruptaki birini seç ve onun hakkında düşündüğün bir şeyi söyle.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'En garip alışkanlığını itiraf et.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'İtiraf',
      'content': 'Hiç kopya çektin mi? Nasıl?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'En son kimi stalkladın?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Gizli bir yeteneğini göster veya anlat.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── TAKLİT ──────────────────────────────────
    {
      'category': 'Taklit',
      'content': 'Gruptaki birinin yürüyüşünü taklit et, herkes tahmin etsin.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Ünlü birinin konuşmasını taklit et.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Bir hayvanı ses ve hareketleriyle taklit et.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Bir film sahnesini canlandır, herkes tahmin etsin.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Gruptaki birinin ses tonuyla 30 saniye konuş.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── SOSYAL MEDYA ────────────────────────────
    {
      'category': 'Sosyal Medya',
      'content': 'WhatsApp son konuşmalarını 10 saniye göster.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Instagram keşfetini herkese göster.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Son beğendiğin 5 gönderiyi göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Ekran süren kaç saat? Herkese göster.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },

    // ── FİZİKSEL ────────────────────────────────
    {
      'category': 'Fiziksel',
      'content': '20 şınav çek.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': '1 dakika boyunca tek ayak üstünde dur.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Odanın etrafında 3 tur koş.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': '30 saniye plank yap.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── BİLGİ ───────────────────────────────────
    {
      'category': 'Bilgi',
      'content': '10 saniyede 5 başkent say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': '15 saniyede 10 hayvan ismi say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': "Tersten 100'den 7'şer say.",
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': '20 saniyede 5 ülke ve başkentini eşleştir.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Gruptaki herkesin burcunu tahmin et.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
  ];

  /// Firebase'e seed data yükler. Zaten yüklüyse tekrar yüklemez.
  static Future<int> run() async {
    final firestore = FirebaseFirestore.instance;
    final tasksRef = firestore.collection('tasks');

    // Zaten görev varsa skip
    final existing = await tasksRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return 0; // Zaten seed edilmiş
    }

    final batch = firestore.batch();
    for (final task in seedData) {
      final docRef = tasksRef.doc();
      batch.set(docRef, {
        ...task,
        'likes': 0,
        'dislikes': 0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return seedData.length;
  }
}
