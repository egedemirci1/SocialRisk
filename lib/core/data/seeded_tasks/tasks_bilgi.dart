/// Bilgi — Tam 120 görev, 4 alt kategori, her zorlukta 10'ar soru.
/// Format: 'options' ve 'answer' içermez.
/// Mantık: Sırası gelen oyuncu soruyu okur. Gerçek cevabı biliyorsa doğru şekilde anlatır.
/// Eğer bilmiyorsa, o kadar iyi bir blöf yapar ki masayı bunun doğru olduğuna ikna etmeye çalışır.
/// Masa performansa göre (👍 Doğru/İkna edici, 😐 Emin değiliz, 👎 Yanlış/Kötü salladı) oylar.

final List<Map<String, dynamic>> tasksBilgi = [

  // ==========================================
  // 1. GENEL KÜLTÜR (BİLİM, TARİH, DOĞA)
  // ==========================================

  // ── GENEL KÜLTÜR — EASY ──
  {'category': 'Bilgi', 'content': 'Ahtapotların kaç kalbi vardır ve bu kalpler ne işe yarar? Gerçek anatomiyi anlat veya belgesel sunucusu edasıyla harika bir sallamasyon yap.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Kedilerin tat alma duyularında hangi temel tat tamamen eksiktir? Cevabı ver ve bir kedinin bu tadı alınca nasıl tepki vereceğini taklit et.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Dünyadaki oksijenin büyük bir kısmı ağaçlardan gelmez. Peki nereden gelir? Gerçek cevabı biliyorsan açıkla, bilmiyorsan masayı ikna edecek kadar bilimsel bir yalan uydur.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Eyfel Kulesi yaz aylarında neden fiziksel olarak birkaç santim uzar? Fizik bilginle masayı aydınlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'İncir aslında botanik olarak bir meyve değildir. Peki nedir? Bu bitkinin oluşum sürecini ilginç bir şekilde anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Bukalemunların dili kendi vücut uzunluklarının ortalama kaç katıdır? Bilmiyorsan, evrimsel bir neden uydur.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Penguenler sadece dünyanın hangi yarımküresinde doğal olarak yaşarlar? Coğrafya bilginle masayı ikna et.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Kangurular neden fiziksel olarak geri geri yürüyemezler? Ayak ve kuyruk yapılarını bilimselmiş gibi anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Salyangozlar kesintisiz olarak kaç yıl boyunca uyuyabilirler? Sence o kadar süre ne rüyası görüyorlardır?', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'İnsan DNA\'sı ile %60 oranında benzerlik gösteren o meşhur sarı meyve hangisidir? Mantığını açıkla.', 'difficulty': 'easy', 'type': 'action', 'tags': ['trivia', 'family']},

  // ── GENEL KÜLTÜR — MEDIUM ──
  {'category': 'Bilgi', 'content': 'Bal neden binlerce yıl geçse bile asla bozulmaz? İşin kimyasını doğru açıkla ya da arıların gizli tarifini uydur.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': '"Mona Lisa" tablosundaki kadının neden kaşları yoktur? Dönemin modasını veya ressamın sırrını biliyorsan anlat, bilmiyorsan sanatsal bir komplo teorisi üret.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'İnsan vücudundaki en güçlü kas hangisidir? Cevabı tahmin et ve neden o kasın en güçlü olması gerektiğini mantıklı bir şekilde savun.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Bir günün, kendi bir yılından daha uzun sürdüğü o tuhaf gezegen hangisidir? Güneş sistemi bilginle masayı etkile.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Yerçekimsiz ortamda, uzayda ağladığınızda gözyaşlarınıza tam olarak ne olur? Sıvının davranışını masaya uygulamalı gibi tarif et.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Su aygırlarının teri güneşte kuruduğunda ne renge dönüşür? Sence bu renk onların hangi evrimsel ihtiyacını karşılıyor?', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'İskambil kağıtlarındaki kupa papazının bıyığı neden yoktur? Tarihsel bir dedikodu mu yoksa basım hatası mı? Uydur veya gerçeği söyle.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Zürafaların ses telleri yoktur. Peki iletişim kurmak için nasıl bir ses çıkarırlar veya titreşim yayarlar? Masaya bir zürafa sesi simülasyonu yap.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Devekuşlarının gözleri hangi iç organlarından daha büyüktür? Kuş anatomisi hakkında mantıklı bir açıklama getir.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Jüpiter\'deki "Büyük Kırmızı Leke" aslında nedir? Uzay bilimcisi edasıyla orada kopan kıyameti anlat.', 'difficulty': 'medium', 'type': 'action', 'tags': ['trivia', 'family']},

  // ── GENEL KÜLTÜR — HARD ──
  {'category': 'Bilgi', 'content': 'Tarihteki en kısa savaş sadece 38 dakika sürmüştür. Sence bu savaş hangi iki ülke arasında ve ne için çıkmış olabilir? Bilmiyorsan en absürt savaş sebebini uydur.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Wombat adlı Avustralya hayvanının dışkısı doğadaki tek "küp" şekilli dışkıdır. Neden küp şeklinde? Evrimsel faydasını blöf yaparak anlat.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Istakozların kanı ne renktir ve oksijen taşıyan molekülleri demir yerine hangi elementi içerir? İkna edici bir yalan veya gerçek sun.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Uçak pencerelerinin en altındaki o minik delik tam olarak ne işe yarar? Havacılık mühendisi gibi masaya teknik bir açıklama yap.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Hangi popüler sarı meyve hafif derecede radyoaktiftir? İçindeki hangi mineral onu böyle yapar?', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Hangi hayvanın parmak izi, olay yerinde bırakıldığında polisleri kandıracak kadar insan parmak izine benzer?', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Astronotların uzay giysileri neden genellikle beyaz renklidir? Moda mıdır yoksa radyasyonla mı ilgilidir? Detaylandır.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Dünyadaki tüm karıncaların toplam ağırlığı, kabaca hangi canlı türünün toplam ağırlığına eşittir? Oran orantı kurarak salla.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Çikolata köpekler için neden ölümcüldür? İçindeki o meşhur sindiremedikleri maddenin adını ve etkisini açıkla.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},
  {'category': 'Bilgi', 'content': 'Bir sivrisineğin mikroskop altında görülebilen toplam kaç dişi (veya kesicisi) vardır? Aklındaki en çılgın rakamı söyle ve savun.', 'difficulty': 'hard', 'type': 'action', 'tags': ['trivia', 'family']},


  // ==========================================
  // 2. POPÜLER KÜLTÜR (DİZİ, SİNEMA, MAGAZİN)
  // ==========================================

  // ── POPÜLER KÜLTÜR — EASY ──
  {'category': 'Bilgi', 'content': 'Türk televizyon tarihinin efsanesi: "Ne dedin sen!" tokat olayında, tokatı kim kime atmıştır? Olayın nasıl geliştiğini magazin muhabiri gibi anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Aşk-ı Memnu dizisinde Firdevs Yöreoğlu\'nun "Sen Bihter Ziyagil\'sin, aptallık etme!" repliğini ezberden ve en dramatik halinle masaya karşı oyna.', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'İnternette "Rickroll"lanmak ne demektir? Bu kavramın nereden geldiğini hiç bilmeyen birine anlatır gibi açıkla.', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Matrix filminde Neo\'ya sunulan hapların renkleri nelerdi ve hangisi ne işe yarıyordu? Seçimini yap ve masaya felsefesini yap.', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Yaprak Dökümü dizisinde "Aman Ali Rıza Bey ağzımızın tadı kaçmasın" repliğini söyleyen o ikonik karakterin adını ver.', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Cem Yılmaz\'ın G.O.R.A filmindeki efsanevi Erşan Kuneri karakterinin asıl mesleği nedir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'İnternet dünyasının meşhur "Doge" memesi (ve kripto parası) olan köpeğin cinsi nedir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Acun Ilıcalı\'nın televizyonda ve normal hayatta giydiği, onunla bütünleşmiş o ikonik tişört rengi nedir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Dünyaca ünlü K-Pop grubu BTS\'in çılgın hayran kitlesine verilen resmi isim nedir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Eski Türk evlilik programlarında adayların birbirini reddederken kullandığı o meşhur 2 kelimelik "enerji" bahanesi nedir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['popculture', 'adult']},

  // ── POPÜLER KÜLTÜR — MEDIUM ──
  {'category': 'Bilgi', 'content': 'Kanye West, 2009 müzik ödüllerinde sahneye atlayıp kimin konuşmasını bölmüştür? O anın utanç vericiliğini (cringe) masaya anlat.', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Avrupa Yakası dizisinin efsane karakteri Burhan Altıntop aslen nerelidir? Masaya biraz şivesinden örnek ver.', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'TikTok\'ta hiç konuşmadan, sadece basit işleri karmaşık yapan insanlara elleriyle "işte bu kadar basit" hareketi yaparak ünlenen o adamın adı nedir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'family']},
  {'category': 'Bilgi', 'content': 'Yalan Dünya dizisinde Vasfiye Teyze karakterinin her felaket sonrası söylediği o meşhur teselli/laf sokma cümlesi nedir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Kardashian ailesinin tüm hayatını sergilediği meşhur reality show toplamda kaç sezon sürmüştür? Yaklaşık bir sayı at.', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': '"Seni çöpe atacağım poşete yazık" gibi efsanevi bir felsefi dizeye sahip olan şarkı hangi ünlü Türk sanatçıya aittir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Amerika\'da sürekli şikayet eden, her fırsatta "müdürle konuşmak isteyen" sorunlu orta yaşlı kadın tiplemesine internette hangi isim verilir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Breaking Bad dizisinde Walter White\'ın ürettiği ve onun imzası haline gelen o meşhur methin rengi neydi? Neden o renk olduğunu (veya senin uydurmanı) dinleyelim.', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Kurtlar Vadisi dizisinde Süleyman Çakır öldüğünde, Türk halkı sokaklara dökülüp ne tür bir "gerçeküstü" ritüel gerçekleştirmiştir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Gelinim Olur Musun programında sinir krizi geçirip kendi kafasında bardak kıran o efsanevi yarışmacının adını söyle.', 'difficulty': 'medium', 'type': 'action', 'tags': ['popculture', 'adult']},

  // ── POPÜLER KÜLTÜR — HARD ──
  {'category': 'Bilgi', 'content': 'Game of Thrones\'un final sezonunda çekim sırasında masada unutulan ve olay olan bardağın markası neydi? Sence o seti kim, nasıl o halde unuttu?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Tarihin en büyük sosyal medya dolandırıcılığı olan Fyre Festival\'de binlerce dolar ödeyen VIP misafirlere yemek kutusunda ne verilmişti? Masaya o menüyü pazarla.', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Britney Spears\'ın 2007 yılında geçirdiği sinir krizinde magazincilere karşı hangi eşyayla, nasıl bir saldırı yaptığını detaylarıyla anlat.', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Justin Bieber\'ın Almanya turnesinde gümrükte el konulan ve bir daha asla geri almadığı evcil hayvanı ne tür bir canlıydı?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Eski YouTube döneminin en ünlü videolarından olan "Angry German Kid", bilgisayarın başında bağırarak hangi oyun donanımını parçalamıştır?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Kim Kardashian\'ın Kris Humphries ile olan "yüzyılın aşkı" diye pazarlanan ve milyonlar harcanan o meşhur evliliği toplam kaç GÜN sürmüştür?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': '2014 Oscar töreninde Twitter\'ı çökerten o meşhur selfie\'yi çeken (telefonu tutan) ünlü aktör kimdi? Masayla bir "Oscar Selfie"si pozu ver.', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Will Smith\'in Oscar töreninde Chris Rock\'a tokat attıktan sonra sahneye doğru bağırarak kurduğu o meşhur İngilizce cümleyi tam olarak söyle.', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Mehmet Ali Erbil\'in parmaklarıyla yaptığı o anlamsız ama efsanevi şov hareketinin / kelimesinin adı nedir?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},
  {'category': 'Bilgi', 'content': 'Aşk-ı Memnu dizisinde Adnan Bey, Bihter ve Behlül\'ü yakaladıktan sonra fenalaşıp merdivenlerden inerken ağzından dökülen son kelime ne olmuştur?', 'difficulty': 'hard', 'type': 'action', 'tags': ['popculture', 'adult']},


  // ==========================================
  // 3. SOSYAL TRİVİA (MASA İÇİ TAHMİNLER & DİNAMİKLER)
  // ==========================================

  // ── SOSYAL TRİVİA — EASY ──
  {'category': 'Bilgi', 'content': 'Solundaki oyuncunun hayatta en çok para harcadığı "en gereksiz" şey sence nedir? Onu ne kadar iyi tanıdığını kanıtla.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Masadan birinin lise yıllarındaki en belirgin özelliğini veya ergenlik tarzını tahmin et. Hedefin doğrularsa oyu kaparsın.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'family']},
  {'category': 'Bilgi', 'content': 'Sağındaki oyuncunun telefonundaki en çok vakit geçirdiği uygulamanın hangisi olduğunu ve orada tam olarak ne yaptığını detaylıca tahmin et.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Masadaki oyunculardan birinin yemekle alakalı sahip olduğu en garip takıntıyı veya midesiz komboyu ortaya çıkar.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Bu grupta sabahları uyandığında kesinlikle konuşulmaması gereken, en huysuz ve çekilmez kişi kim? Savunmanı yap.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Masadaki hangi oyuncunun trafikte veya gündelik hayatta en ufak şeye en abartılı ve çabuk sinirlenen kişi olduğunu düşünüyorsun?', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Eğer bu masadaki herkes bir zombi istilasında olsaydı, sence ilk avlanacak kişi kim olurdu ve neden? Olayı canlandır.', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Bu grupta yalan söylediğinde gözünden, sesinden veya mimiklerinden kendini anında ele veren en beceriksiz yalancı kim?', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Dışarı çıkmadan önce hazırlanırken aynaya bakarak en çok vakit kaybeden ve kendini en çok süzen kişi kim?', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Duştayken avazı çıktığı kadar bağıra bağıra konser vermeye en meyilli kişi sence kim? Hangi şarkıyı söylüyordur?', 'difficulty': 'easy', 'type': 'action', 'tags': ['social', 'adult']},

  // ── SOSYAL TRİVİA — MEDIUM ──
  {'category': 'Bilgi', 'content': 'Masadaki oyunculardan birinin gizli bir yeteneğini veya herkesin bilmediği tuhaf bir fobisini doğru bilmeye çalış.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Eğer bu masa bir Amerikan korku filminin oyuncu kadrosu olsaydı, sence seri katil kim çıkardı? Profilini analiz et.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Şu an masadaki birinin en sevdiği ama itiraf etmekten utandığı (guilty pleasure) şarkıyı veya diziyi tahmin edip yüzüne vur.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Gecenin köründe, kafası iyiyken eski sevgilisine mesaj atma veya stalklama potansiyeli en yüksek olan kişiyi göster ve nedenini açıkla.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Bu grupta sosyal medyada gösterdiği hayatla gerçekte yaşadığı hayat arasında en büyük uçurum (en fake) olan kişi kim?', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Eline geçen en ufak sırrı, "Sadece sana söylüyorum" diyerek saniyeler içinde herkese yayma potansiyeli olan en dedikoducu kim?', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Büyük bir ikramiye kazandığında, arkadaşlarını anında unutup zenginliğin dibine vurarak değişecek ilk kişi sence kim?', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Grupta sürekli ısrarla savunduğu ama aslında tamamen yanlış ve mantıksız olan o "sabit fikri" kime ait? Yüzüne söyle.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Kendi yemeğini söylemeyip veya bitirip, sürekli başkalarının tabağına çatal uzatan "otlakçı" oyuncuyu ifşa et.', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Buluşmalara sürekli geç kalan ve gelirken her seferinde sanki dünyayı kurtarmış gibi abartılı bahaneler üreten kişi kim?', 'difficulty': 'medium', 'type': 'action', 'tags': ['social', 'adult']},

  // ── SOSYAL TRİVİA — HARD ──
  {'category': 'Bilgi', 'content': 'Eğer bu masadan biri gizli bir suç şebekesi yönetiyor olsaydı bu kim olurdu ve paravan şirketi ne iş yapardı? Profilini çıkar.', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Masadaki hangi oyuncunun geçmişte en epik "aşk acısı" veya "reddedilme" hikayesine sahip olduğunu düşünüyorsun? Tahmin et ve ondan onay bekle.', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Solundaki kişinin konuşurken en çok kullandığı ve artık duyduğunda sinirlerini bozan o "klişe" cümlesini veya kelimesini taklit ederek söyle.', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Eğer hayatta kalmak için bir arkadaşını feda etmesi veya satması gerekseydi, bu masada gözünü kırpmadan yapacak o "Makyavelist" kişi kim?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Dünyayı ele geçirse ve diktatör olsa, bu masadan sence kim zevk için en saçma ve zalim yasaları çıkarırdı?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'İş hayatında veya kendi çıkarı için gözünü kırpmadan en gaddar ve duygusuz kararları alabileceğini düşündüğün gizli psikopat kim?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'İleride evlenirse, huysuzluğu, dengesizliği veya tahammülsüzlüğü yüzünden evliliği en çabuk bitecek oyuncuyu tahmin et.', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Masadaki insanlardan birinin sırlarını bilse, bunu kendi çıkarı için "gizlice şantaj aracı" olarak kullanma ihtimali en yüksek sinsi karakter kim?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Bir olay patlak verdiğinde veya biri hata yaptığında, en kibirli ses tonuyla "Ben sana demiştim" demeyi en çok seven o ukala kişi kim?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},
  {'category': 'Bilgi', 'content': 'Eğer arkasından iş çevrilirse, bu masada asla affetmeyecek ve en korkunç, en planlı intikamı alacak kişi sence kim?', 'difficulty': 'hard', 'type': 'action', 'tags': ['social', 'adult']},


  // ==========================================
  // 4. LANETLİ BİLGİLER (BİZARRE & RAHATSIZ EDİCİ)
  // ==========================================

  // ── LANETLİ BİLGİLER — EASY ──
  {'category': 'Bilgi', 'content': 'Antik Roma\'da insanlar dişlerini beyazlatmak ve temizlemek için ağız gargarası olarak hangi iğrenç bedensel sıvıyı kullanırdı? Tahmin et!', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Kelebekler bir çiçeğin tadını vücutlarının hangi ilginç bölgesiyle alırlar? Biliyorsan söyle, bilmiyorsan en garip organı uydur.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Eski Mısır\'da mumyalama yapılırken firavunların beyinleri kafatasından tam olarak hangi delikten ve nasıl çıkarılırdı? Süreci iğrenç detaylarıyla anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Ketçap, 1830\'larda aslında bir yiyecek sosu değil, ne olarak satılıyordu? O dönemdeki bir tüccar gibi bu ürünü masaya pazarla.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Doğada erkeklerin hamile kalıp doğum yaptığı tek canlı türü hangisidir? Evrimini hayal gücünle destekle.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Vampir yarasalar, mağaraya kan içemeden aç dönen bir arkadaşlarına yardım etmek için ne yaparlar? Bu "fedakarlığı" masaya iğrenerek anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Bir hamamböceğinin kafası kopsa bile ölene kadar ortalama ne kadar süre daha yaşayabilir? Ve sonunda kafasızlıktan değil, neyden ölür?', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Karasinekler yemeğinize konduğunda aslında o an fiziksel olarak ne yapmaktadırlar? Mide bulandırıcı gerçeği masaya anlat.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Kedilerin kumunda bulunan ve insanlara geçerek beyinlerine yerleşen, risk almayı seven bir karaktere dönüştüren o parazitin adı nedir? Hastalığı uydur.', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Tembelhayvanların (Sloth) doğal ölümlerinin çok büyük bir kısmı, haftada bir kez yaptıkları hangi basit ihtiyaç molası sırasında gerçekleşir?', 'difficulty': 'easy', 'type': 'action', 'tags': ['bizarre', 'family']},

  // ── LANETLİ BİLGİLER — MEDIUM ──
  {'category': 'Bilgi', 'content': 'Orta Çağ Avrupa\'sında, tarlaya zarar veren böceklere ve farelere uygulanan o en absürt hukuki işlem neydi? Biliyorsan anlat, bilmiyorsan salla.', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': '"Yürüyen Ceset Sendromu" (Cotard) isimli psikolojik rahatsızlığa sahip hastalar hayatlarıyla ilgili hangi korkunç illüzyona inanırlar?', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': '1800\'lerde, özellikle Waterloo Savaşı sonrasında takma dişler çoğunlukla neyden (ve kimlerden alınarak) yapılırdı? O dönemin dişçisi gibi anlat.', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'İnekler sürüdeki en yakın arkadaşları satıldığında veya ayrıldığında ne tür bir psikolojik çöküntü yaşarlar? Bunu insan ilişkilerine benzet.', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Antik Roma\'nın umumi tuvaletlerinde (Latrina) insanların temizlik için sırayla kullandıkları o iğrenç nesne neydi? Süreci anlat.', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Viktorya dönemi İngiltere\'sinde, ailesinden biri öldüğünde cenazeden önce yapılan o en ürpertici fotoğraf çekimi geleneği neydi?', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Kunduzların kalçalarındaki bezlerden salgılanan "Castoreum" adlı madde, eski yıllarda hangi tatlı aromasını vermek için yiyeceklerde kullanılıyordu?', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Timsahların avlarını yerken gerçekten gözyaşı dökmesinin altında yatan o acımasız biyolojik sebep nedir?', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Kargaların onlara taş atan veya kötü davranan insanları asla unutmadığı ve ne tür bir intikam aldığı biliniyor? Kargaların zekasını abartarak anlat.', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'family']},
  {'category': 'Bilgi', 'content': 'Sevimli bildiğimiz ördekler, aşırı strese girdiklerinde veya kalabalık ortamda kaldıklarında birbirlerine ne tür bir vahşi eylem yaparlar?', 'difficulty': 'medium', 'type': 'action', 'tags': ['bizarre', 'adult']},

  // ── LANETLİ BİLGİLER — HARD ──
  {'category': 'Bilgi', 'content': '"Fare Kralı" (Rat King) adı verilen o iğrenç doğa olayının tam olarak ne olduğunu biliyor musun? Masanın midesini bulandırmaya çalış.', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Everest Dağı tırmanış yolundaki donmuş cesetlerin günümüzde dağcılar için hangi ürpertici amaca hizmet ettiğini açıkla.', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Fransız İhtilali döneminde giyotinle kafası kesilen bir insanın bilinci ortalama kaç saniye daha açık kalır? Bilimsel gerçeği masaya sun.', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Eski Fransa\'da, görkemli Versay Sarayı\'nda tuvalet odası olmadığı için asiller ve misafirler ihtiyaçlarını nerede ve nasıl gideriyorlardı?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Dünyanın çeşitli yerlerindeki yamyam kabilelerin kayıtlarına göre, pişmiş insan etinin tadı ve dokusu hangi hayvanın etine benzemektedir?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Kordiseps adlı lanetli mantar, ormanda hangi böceğin beynini ele geçirerek onu kelimenin tam anlamıyla bir zombiye dönüştürür? Süreci anlat.', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Mafyanın ceset yok etmek için domuzları kullanmasının sebebi, domuzların insan vücudunda diş ve saç hariç neleri de yiyebilmesidir?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Uzay boşluğunda koruyucu kıyafetsiz bir şekilde ölen bir astronotun cesedi asla çürümez. Peki bakteriler çalışmadığı için cesede ne olur?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': '18. yüzyılda diri diri gömülme korkusu nedeniyle mezar tabutlarına dışarıdan duyulabilecek şekilde bağlanan o güvenlik cihazı neydi?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']},
  {'category': 'Bilgi', 'content': 'Gıda örgütlerinin resmi kurallarına göre, marketten alınan bir kalıp çikolatanın içinde ortalama kaç adet parçalanmış "böcek" parçası olması yasal sınırdır?', 'difficulty': 'hard', 'type': 'action', 'tags': ['bizarre', 'adult']}

];