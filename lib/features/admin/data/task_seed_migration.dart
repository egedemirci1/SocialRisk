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
    // ── CESARET - EASY ─────────────────────────────────
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
      'content': 'Gruptaki en komik anını anlat.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'En sevdiğin şarkıyı 10 saniye yüksek sesle söyle.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Birisine rastgele bir emoji gönder ve açıklama yapma.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content':
          'Gözlerini kapat ve yanındaki kişinin yüzüne dokunarak kim olduğunu tahmin et.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Sağındaki kişiye sımsıkı sarıl.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Bir sonraki turuna kadar fısıldayarak konuş.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': '5 saniye boyunca çok yüksek sesle gül.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content': 'Solundaki kişinin saçını hafifçe okşa.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── CESARET - MEDIUM ───────────────────────────────
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
      'content': 'Rehberinden rastgele birine "Seni seviyorum" yaz.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Bir bardak suyu hiç durmadan iç.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Cesaret',
      'content':
          'Instagram\'da karşına çıkan ilk fotoğrafa ateşli bir yorum at.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Sağındaki kişiyle kıyafetinin bir parçasını değiştir.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'En son attığın 3 mesajı yüksek sesle oku.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Gruptaki birine 1 dakika boyunca masaj yap.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Son yaptığın Google aramasını herkese göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content':
          'Odadan çıkıp kapıyı çal ve farklı bir karakter olarak içeri gir.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── CESARET - HARD ─────────────────────────────────
    {
      'category': 'Cesaret',
      'content': 'Rastgele bir kişiyi ara ve "Seni özledim" de.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Instagram hikayene "Bu oyun harika!" yaz ve paylaş.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Rehberindeki 5. kişiyi ara ve ona şarkı söyle.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Eski sevgiline veya flörtüne sadece selam yaz.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Galendeki ilk 5 fotoğrafı herkese tek tek açıkla.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content':
          'Sessizce birini seç ve 1 dakika boyunca gözlerinin içine bak.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content':
          'Gruptaki herkes sana bir soru sorsun, hepsine doğru cevap ver.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Bir kaşık acı sos veya en sevmediğin bir şeyi ye.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Whatsapp\'taki son grubuna anlamsız bir fotoğraf at.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Cesaret',
      'content': 'Oyun bitene kadar aksanlı (ör. İngiliz, Fransız) konuş.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── İTİRAF - EASY ──────────────────────────────────
    {
      'category': 'İtiraf',
      'content': 'Gizli bir yeteneğini göster veya anlat.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
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
      'content': 'Çocukken en çok korktuğun şey neydi?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'İtiraf',
      'content': 'En büyük irrasyonel korkun nedir?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'İtiraf',
      'content': 'Gizlice dinlemekten hoşlandığın utanç verici şarkı nedir?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'İtiraf',
      'content': 'En son ne zaman ve neden ağladın?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Kendinle ilgili en sevmediğin fiziksel özellik?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Daha önce bir yere izinsiz girdin mi?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Hiç çaktırmadan gaz çıkardın mı?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── İTİRAF - MEDIUM ────────────────────────────────
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
      'content': 'En son kimi stalkladın?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Grupta kimi ilk tanıştığında hiç sevmemiştin?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'En berbat randevun nasıldı?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Birinin sırrını başkasına anlattın mı? Ne zaman?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Ailenden sakladığın en büyük sır nedir?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Hayatın film olsa şu anki bölümün adı ne olurdu?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'İtiraf',
      'content': 'Fake sosyal medya hesabın var mı? Ne için kullanıyorsun?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Eğer yasak olmasaydı kesin yapacağın bir suç?',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },

    // ── İTİRAF - HARD ──────────────────────────────────
    {
      'category': 'İtiraf',
      'content':
          'Gruptaki birini seç ve onun hakkında düşündüğün gizli bir şeyi söyle.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Telefonundaki en utanç verici arama geçmişini oku.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Bu odadaki birini öpecek olsan kimi öperdin?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Hiç aldatıldın mı veya aldattın mı? Detay ver.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'En derin fantezini anlat (seviyene göre).',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Grupta fiziksel olarak en çekici bulduğun kişi kim?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Geçmişte yaptığın ve en çok pişman olduğun yasadışı şey?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Sevmediğin ama mecburen görüştüğün o kişi kim?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content':
          'En son hangi yalanı ailenin gözünün içine baka baka söyledin?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'İtiraf',
      'content': 'Gruptan birinin arkasından en son ne konuştun?',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },

    // ── TAKLİT - EASY ──────────────────────────────────
    {
      'category': 'Taklit',
      'content': 'Bir hayvanı ses ve hareketleriyle taklit et.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Üşümüş bir penguen gibi yürü.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Sessiz sinema: Sadece hareketlerle "Ağaç" kelimesini anlat.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Çok acı biber yemiş gibi tepki ver.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Korkmuş bir kedi gibi ses çıkar.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Zombi gibi odanın içinde dolaş.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Görünmez bir sandalyeye otur ve 10 saniye bekle.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Bir bebek gibi ağlama numarası yap.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Yavaş çekimde koşuyormuş gibi yap.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Görünmez bir duvarı itmeye çalış.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── TAKLİT - MEDIUM ────────────────────────────────
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
      'content': 'Bir film sahnesini canlandır, herkes tahmin etsin.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Çöpçatanlık programındaki bir adayı canlandır.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content': 'Çok sarhoş birini taklit ederek bir şeyler anlat.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['adult'],
    },
    {
      'category': 'Taklit',
      'content': 'Aşırı heyecanlı bir haber sunucusu ol.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Bir stand-up komedyeni gibi 1 dakikalık şaka yap.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content': 'Trafikte çok sinirlenmiş bir taksiciyi oyna.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Klasik bir Türk dizisi anne tavrını sergile.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content':
          'Miden bulanıyormuş ama kusmamaya çalışıyormuş gibi taklit yap.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── TAKLİT - HARD ──────────────────────────────────
    {
      'category': 'Taklit',
      'content': 'Gruptaki birinin ses tonuyla 30 saniye konuş.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content':
          'Karşındaki kişinin her hareketini ayna gibi taklit et (30sn).',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content':
          'Sessiz sinemada en karmaşık filmi seç ve hareketlerinle anlat.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content':
          'Gruptaki birinin en ikonik anını sadece mimiklerle canlandır.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content':
          'Bir politikacının çok ciddi açıklama yapıp pot kırdığı anı oyna.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content':
          'Bir spor müsabakasını spiker olarak çok hızlı ve heyecanlı anlat.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Korku filmi kurbanı gibi feci şekilde çığlık at.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content': 'En sevmediğin öğretmenin/patronunun taklidini yap.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Taklit',
      'content': 'Arap harfleri okuyormuş gibi makamla anlamsız sesler çıkar.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Taklit',
      'content': 'Bebek doğuruyormuş gibi nefes egzersizi yap.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['adult'],
    },

    // ── SOSYAL MEDYA - EASY ────────────────────────────
    {
      'category': 'Sosyal Medya',
      'content': 'Instagram keşfetini herkese göster.',
      'difficulty': 'easy',
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
    {
      'category': 'Sosyal Medya',
      'content': 'En çok kullandığın 3 uygulamayı göster.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'En son kimi takip etmeye başladın?',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'YouTube geçmişindeki son 5 videoyu oku.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'TikTok / Reels beğendiklerinden ilk 3\'ünü bize izlet.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Twitter/X feed\'indeki ilk tweeti sesli oku.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Spotify / Apple Music\'te en son dinlediğin şarkıyı aç.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Telefonunun kilit ve ana ekran duvar kağıdını herkese göster.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Sık kullanılan emojilerini ekranı açıp göster.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── SOSYAL MEDYA - MEDIUM ──────────────────────────
    {
      'category': 'Sosyal Medya',
      'content': 'Son beğendiğin 5 gönderiyi göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Instagram\'da arama geçmişini harf harf bize göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Galerindeki "Gizli/Hidden" klasöründeki fotoğraf sayısını söyle.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Fotoğraflarında en eski olanı bulup göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Kaydettiğin postlara gir ve bize ilkini göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Instagram DM\'de "engellenmiş hesaplar" listeni açma ama sayısını söyle.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'LinkedIn profiline gir ve en son kimin paneline baktığını söyle.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'WhatsApp gruplarından birine "Çok sıkıldım" yaz.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Son 24 saat içinde attığın en uzun mesajı bize oku.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Notes/Notlar uygulamandaki ilk notunu göster.',
      'difficulty': 'medium',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── SOSYAL MEDYA - HARD ────────────────────────────
    {
      'category': 'Sosyal Medya',
      'content': 'WhatsApp son konuşmalarını 10 saniye göster.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Instagram DM kutunda en üstteki DM\'i aç ve son iki mesajı oku.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Bir rastgele takipçine/arkadaşına kalp emojisi at.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Son sildiğin (Recently Deleted) fotoğrafları 5 saniyeliğine göster.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Sessize aldığın hikayelerden birini aç ve kim olduğunu söyle.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Galendeki rastgele bir fotoğrafı Twitter veya Insta hikayene "No context" yazarak at.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'Eski sevgilinin Instagram\'ına gir ve profilini göster.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Tinder (veya benzeri uygulama) varsa açıp 3 kişiyi sağa kaydır.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content': 'WhatsApp arşivlenmiş sohbetlerinden en üsttekini göster.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['adult'],
    },
    {
      'category': 'Sosyal Medya',
      'content':
          'Google arama geçmişinde son 1 ayı aç ve ilk 5 satırı sesli oku.',
      'difficulty': 'hard',
      'type': 'action',
      'tags': ['classic', 'adult'],
    },

    // ── FİZİKSEL - EASY ────────────────────────────────
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
      'content': '10 kez zıpla.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Kollarını iki yana aç ve havada daireler çiz (30sn).',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Ayak parmaklarına dokunmaya çalış (15 sn bekle).',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          '5 tane jumping jack (zıplayarak kol bacak açma) hareketi yap.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Burnunun ucuna parmağınla dokun ve gözlerini kapatarak 15 saniye dur.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Ellerini çırparak 10 saniye boyunca hızlıca dizlerini göğsüne çek.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Oturup kalkma (squat) hareketini 5 kez tekrarla.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Başını sağdan sola doğru yavaşça 5 kez çevir.',
      'difficulty': 'easy',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── FİZİKSEL - MEDIUM ──────────────────────────────
    {
      'category': 'Fiziksel',
      'content': '20 şınav çek.',
      'difficulty': 'medium',
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
    {
      'category': 'Fiziksel',
      'content':
          'Duvara sırtını daya ve oturur pozisyonda (wall sit) 30 saniye bekle.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': '15 kez tam çömelip kalkarak zıpla (jump squat).',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Sırtüstü yatıp 20 adet mekik çek.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Bir elinle ters dizine dokunarak yerinde hızlıca 30 saniye koş.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Kendini parmak uçlarında esneterek dayanabildiğin kadar yürü.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Gruptaki birini sırtına al ve 10 saniye yürü.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Tek ayak üstünde zıplayarak odanın diğer ucuna git ve geri dön.',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Yere uzanıp sadece kollarını ve bacaklarını kaldırıp "Superman" pozu yap (20sn).',
      'difficulty': 'medium',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── FİZİKSEL - HARD ────────────────────────────────
    {
      'category': 'Fiziksel',
      'content': 'Amuda kalkmayı dene (duvara yaslanabilirsin) ve 10 sn dur.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          '1 dakika boyunca hiç ara vermeden burpee (şınavlı zıplama) yap.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Yerde ellerinin ve ayaklarının üzerinde "Örümcek yürüyüşü" ile dolaş.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Sırtında biri varken (seni hafifçe bastırırken) 10 şınav çek.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['adult'],
    },
    {
      'category': 'Fiziksel',
      'content': 'Odanın çevresinde takla atarak 2 tur at.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Köprü hareketi yap (eller ve ayaklar üstünde ters kalk) ve 20 sn bekle.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Gruptaki en ağır kişiyi havaya kaldırmaya çalış (Sırtına dikkat et!).',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult'],
    },
    {
      'category': 'Fiziksel',
      'content':
          '45 saniye boyunca tek elin üzerine ağırlık vererek asimetrik plank yap.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Gözlerin kapalı halde tek ayak üstünde dururken 10 tam squat yap.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Fiziksel',
      'content':
          'Bacaklarını V şeklinde havaya kaldırıp (V-Sit) 45 saniye dur.',
      'difficulty': 'hard',
      'type': 'physical',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── BİLGİ - EASY ───────────────────────────────────
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
      'content': 'Türkiye\'nin 5 coğrafi bölgesini say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': '10 saniyede 5 tane futbol takımı say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Gökkuşağının renklerini sırasıyla söyle.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'İngilizce alfabede kaç harf vardır söyle.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Yılın aylarını tersten say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Tekerleme: "Şu köşe yaz köşesi..." yi hatasız söyle.',
      'difficulty': 'easy',
      'type': 'action',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Haftanın günlerini tersten say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': '10 saniye içinde 5 meyve ismi say.',
      'difficulty': 'easy',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── BİLGİ - MEDIUM ─────────────────────────────────
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
    {
      'category': 'Bilgi',
      'content': '10 saniyede Avrupa\'dan 6 ülke say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Alfabetik sırayla 5 farklı araba markası say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Harry Potter evrenindeki 4 binanın adını say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Dünya üzerindeki kıtaların hepsini say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Türkiye\'nin komşu ülkelerinden 6 tanesini say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Güneş sistemindeki gezegenleri sırasıyla say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Tarihteki son 3 Türkiye Cumhurbaşkanını say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Marvel veya DC evreninden 10 süper kahraman say.',
      'difficulty': 'medium',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },

    // ── BİLGİ - HARD ───────────────────────────────────
    {
      'category': 'Bilgi',
      'content': "Tersten 100'den 7'şer say.",
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Periyodik tablodaki ilk 10 elementi sırasıyla say.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': '15 saniye içinde Afrika kıtasından 7 ülke say.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Oscar ödülü almış 5 farklı film ismi say.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Tarihteki 4 büyük medeniyet veya imparatorluğu söyle.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Alfabeyi olabildiğince hızlı şekilde tersten oku.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Türkiye\'de nüfusu en az olan 3 ili bilmeye çalış.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content': 'Pi sayısının noktadan sonraki ilk 5 rakamını söyle.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content':
          'Mitolojideki 5 farklı Yunan tanrısının adını ve ne tanrısı olduğunu söyle.',
      'difficulty': 'hard',
      'type': 'question',
      'tags': ['classic', 'adult', 'family'],
    },
    {
      'category': 'Bilgi',
      'content':
          'Nobel ödülü kazanmış 3 Türk\'ün veya dünya çapında 3 bilim insanının ismini söyle.',
      'difficulty': 'hard',
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
