// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sosyal Risk';

  @override
  String get login => 'Giriş Yap';

  @override
  String get loginSubtitle => 'İsmini yaz ve maceraya başla!';

  @override
  String get enterName => 'İsim gir';

  @override
  String get enterButton => 'Gir';

  @override
  String get signInWithGoogle => 'Google ile Giriş';

  @override
  String get signInWithApple => 'Apple ile Giriş';

  @override
  String get home => 'Ana Menü';

  @override
  String get createRoom => 'Oda Oluştur';

  @override
  String get joinRoom => 'Odaya Katıl';

  @override
  String get profile => 'Profil';

  @override
  String get store => 'Mağaza';

  @override
  String get copyright => '© 2026 Sosyal Risk';

  @override
  String get lobby => 'Lobi';

  @override
  String get roomCode => 'Oda Kodu';

  @override
  String get codeCopied => 'Kod kopyalandı!';

  @override
  String get startGame => 'Oyunu Başlat';

  @override
  String get allPlayersReady => 'Tüm oyuncular hazır!';

  @override
  String get waitForPlayers => 'Herkesin hazır olmasını bekle...';

  @override
  String get ready => 'Hazırım!';

  @override
  String get notReady => 'Hazır Ol';

  @override
  String get playerCapacity => 'Oyuncu Kapasitesi';

  @override
  String get player => 'oyuncu';

  @override
  String get endCondition => 'Bitiş Koşulu';

  @override
  String get scoreTarget => 'Puan Hedefi';

  @override
  String get roundTarget => 'Tur Sayısı';

  @override
  String get points => 'puan';

  @override
  String get rounds => 'tur';

  @override
  String get gameMode => 'Oyun Modu';

  @override
  String get classicWheel => 'Klasik Çark';

  @override
  String get classicDesc =>
      'Şans ve kaos — çarkı çevir, hangi kategori gelirse o!';

  @override
  String get economyMode => 'Ekonomi';

  @override
  String get economyDesc =>
      'Bu modda kategorilerin puanları popülerliğine göre değişir. Az seçilen kategoriler değer kazanırken, çok seçilenlerin puanı düşer!';

  @override
  String get visibilityMode => 'Görünürlük Modu';

  @override
  String get openMode => 'Açık Mod';

  @override
  String get closedMode => 'Kapalı Mod';

  @override
  String get openModeDesc => 'Herkes görev içeriğini önceden görebilir.';

  @override
  String get closedModeDesc =>
      'Sadece kategori ve çarpan görünür. İçerik gizli!';

  @override
  String get difficulty => 'Görev Zorluğu';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get mixed => 'Karışık';

  @override
  String get createRoomButton => 'Odayı Oluştur';

  @override
  String get enterRoomCode => '6 haneli oda kodunu gir';

  @override
  String get joinButton => 'Katıl';

  @override
  String get spinWheel => 'Çarkı Çevir!';

  @override
  String spinningPlayer(String playerName) {
    return '$playerName çarkı çeviriyor...';
  }

  @override
  String get categoryRandom => 'Kategori şansa bağlı!';

  @override
  String get yourTurn => 'Senin Sıran!';

  @override
  String playerPlaying(String playerName) {
    return '$playerName oynuyor';
  }

  @override
  String get yourTask => 'Görevin:';

  @override
  String playerTask(String playerName) {
    return '$playerName\'in Görevi:';
  }

  @override
  String get closedModeLabel => 'Kapalı Mod';

  @override
  String get revealTask => 'Görevi Aç 🔓';

  @override
  String get acceptTask => 'Görevi Kabul Et';

  @override
  String passTask(int penalty) {
    return 'Pas Geç (Ceza: -$penalty puan)';
  }

  @override
  String waitingForDecision(String playerName) {
    return '$playerName\'ın karar vermesi bekleniyor...';
  }

  @override
  String get winner => 'KAZANAN!';

  @override
  String get finalRanking => 'Final Sıralaması';

  @override
  String get goToStore => 'Mağazaya Git';

  @override
  String get goToRooms => 'Odalara Dön';

  @override
  String walletAdded(int points) {
    return '+$points Puan Cüzdana Eklendi';
  }

  @override
  String get pickCategory => 'Kategori Seç';

  @override
  String get yourPick => 'Senin sıran!';

  @override
  String playerPicking(String playerName) {
    return '$playerName seçiyor...';
  }

  @override
  String pickProgress(int current, int total) {
    return 'Seçim $current/$total';
  }

  @override
  String get marketStatus => 'Pazar Durumu';

  @override
  String get categoryLocked => 'Bu kategori kilitli!';

  @override
  String get premiumCategoryLocked =>
      'Bu özel bir kilitli kategoridir ve sadece Premium üyeler tarafından seçilebilir.';

  @override
  String error(String message) {
    return 'Hata: $message';
  }

  @override
  String get storeTitle => 'Mağaza & Cüzdan';

  @override
  String get storeSubtitle => 'Kozmetikler ve içerikler';

  @override
  String get cosmetics => 'Kozmetikler';

  @override
  String get frames => 'Çerçeveler';

  @override
  String get badges => 'Rozetler & Ünvanlar';

  @override
  String get owned => 'Sahipsin';

  @override
  String get you => 'Sen';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Ses ve Dil';

  @override
  String get menuMusic => 'Menü Müziği';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get languageSelection => 'Dil Seçimi';

  @override
  String get newParty => 'Yeni Parti Başlat';

  @override
  String get joinParty => 'Partiye Katıl';

  @override
  String get myContent => 'İçeriklerim';

  @override
  String get myContentSubtitle => 'Kendi içeriklerini yönet';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get adminPanel => 'Yönetici Paneli';

  @override
  String get attention => 'DİKKAT!';

  @override
  String get logoutWarning =>
      'Hesabınızı silmek ve çıkış yapmak istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get no => 'Hayır';

  @override
  String get deleteAndExit => 'Sil ve Çık';

  @override
  String get sendEmote => 'Emote Gönder';

  @override
  String get emoteCooldown => 'Emote Bekleme';

  @override
  String get partyStarting => 'PARTİ BAŞLIYOR!';

  @override
  String get chooseTask => 'Görevini Belirle';

  @override
  String get spinWheelSubtitle => 'Rastgele Kategori İçin Çarkı Çevir!';

  @override
  String get taskReveal => 'Görevi Aç';

  @override
  String get startTask => 'Görevi Başlat';

  @override
  String get waitingForPlayerAction =>
      'Oyuncunun performansını sergilemesi bekleniyor...';

  @override
  String get finishTask => 'Görevi Bitir';

  @override
  String get taskResultTitle => 'TUR BİTTİ';

  @override
  String taskResultSubtitle(String playerName) {
    return '$playerName performansını tamamladı.';
  }

  @override
  String get taskRejectedTitle => 'GÖREV REDDEDİLDİ';

  @override
  String taskRejectedSubtitle(String playerName) {
    return '$playerName rolünü yapmayı reddetti.';
  }

  @override
  String get audienceScore => 'Seyirci Puanı';

  @override
  String get performanceResult => 'Performans Sonucu';

  @override
  String get liked => 'Beğenildi';

  @override
  String get disliked => 'Beğenilmedi';

  @override
  String get undecided => 'Kararsız';

  @override
  String get difficultyMultiplier => 'Zorluk Çarpanı';

  @override
  String get pointsWon => 'Kazanılan Puan';

  @override
  String get pointsLost => 'Kaybedilen Puan';

  @override
  String get playerRanking => 'OYUNCU SIRALAMASI';

  @override
  String get nextTask => 'SIRADAKİ GÖREV';

  @override
  String get waitingForHostNextTurn =>
      'Yöneticinin yeni tura geçmesi bekleniyor...';

  @override
  String get rateScenario => 'SENARYOYU DEĞERLENDİR';

  @override
  String get good => 'İYİ';

  @override
  String get bad => 'KÖTÜ';

  @override
  String get difficultyLevel => 'Zorluk Seviyesi';

  @override
  String get riskAndReward => 'RİSK VE ÖDÜL';

  @override
  String get chooseDifficultyOneLine => 'Performansının zorluğunu sen belirle';

  @override
  String get chooseDifficultyTwoLines =>
      'Performansının zorluğunu sen belirle...';

  @override
  String estimatedGain(int points) {
    return 'Tahmini Kazanç: $points Puan';
  }

  @override
  String waitingDifficulty(String playerName) {
    return '$playerName zorluk seviyesini seçiyor...';
  }

  @override
  String get categoriesLabel => 'Kategoriler';

  @override
  String get homeScreenLoading => 'Ana menü yükleniyor...';

  @override
  String get menu => 'Menü';

  @override
  String get roomClosedHostLeft =>
      'Ev sahibi odadan ayrıldığı için oda kapatıldı.';

  @override
  String get preparingGame => 'Oyun Hazırlanıyor...';

  @override
  String get wheelModeCapital => 'ÇARK MODU';

  @override
  String get marketModeCapital => 'BORSA MODU';

  @override
  String get chooseAnEmote => 'Bir Emote Seç';

  @override
  String sendEmoteCooldown(int seconds) {
    return 'Emote Bekleme ${seconds}sn';
  }

  @override
  String get everyoneWaitingForYou => 'Haydi, herkes seni bekliyor!';

  @override
  String get waitForOthersToReady =>
      'Diğer oyuncuların hazırlanmasını bekleyin...';

  @override
  String get youSuffix => ' (Sen)';

  @override
  String get hostDefaultName => 'Yönetmen';

  @override
  String get roomCreating => 'Parti Kuruluyor...';

  @override
  String get newPartyHostTitle => 'Yeni Parti Kur';

  @override
  String get endConditionLabel => 'Oyun Sonu';

  @override
  String get gameModeLabel => 'Oyun Modu';

  @override
  String get startPartyButton => 'Partiyi Başlat';

  @override
  String get roundLabel => 'Tur';

  @override
  String get pointLabel => 'Puan';

  @override
  String get classicModeTitle => 'Klasik Parti';

  @override
  String get economyModeTitle => 'Patron Parti';

  @override
  String get classicModeDesc =>
      'Şans çarkını çevir ve rastgele kategoriden gelen riskli cezalarla yüzleş. Puan toplamak için tek şansın cesaret!';

  @override
  String get economyModeDesc =>
      'Kategorilerin puanları popülerliğine göre dinamik olarak değişir: Az seçilen gizli cevherler daha çok puan kazandırırken, herkesin seçtiği kategorilerin değeri düşer. Stratejini kur ve en karlı riskleri al! (En az 3 kategoride aktifleşir)';

  @override
  String get singleCategoryEconomyWarn =>
      'Tek kategori seçildiğinde sadece Borsa modu kullanılabilir.';

  @override
  String get singleCategoryEconomyAutoChange =>
      'Tek kategori seçildi. Oyun modu otomatik Borsa moduna alındı.';

  @override
  String get minOneCategoryWarn => 'En az 1 kategori seçmelisiniz.';

  @override
  String get pleaseEnter6DigitCode => 'Lütfen 6 haneli kodu gir';

  @override
  String get playerDefaultName => 'Oyuncu';

  @override
  String partyNotFound(String error) {
    return 'Parti bulunamadı: $error';
  }

  @override
  String get connectingToParty => 'Partiye bağlanılıyor...';

  @override
  String get joinPartyTitle => 'Partiye Katıl';

  @override
  String get enterPartyCode => 'Parti Kodunu Gir';

  @override
  String get enterPartyCodeDesc =>
      'Arkadaşlarının paylaştığı 6 haneli parti kodunu girerek eğlenceye dahil ol.';

  @override
  String get determineYourTask => 'Görevini Belirle';

  @override
  String get hiddenRound => 'GİZLİ TUR';

  @override
  String get taskCapital => 'GÖREV';

  @override
  String get nextTaskHidden => 'Sıradaki Görev Gizli';

  @override
  String get yourContentHere => 'İçeriğin Burada:';

  @override
  String contentForPlayer(String player) {
    return '$player İçeriği:';
  }

  @override
  String get openCardToViewTask => 'Mevcut görevi görmek için kartı aç...';

  @override
  String get openTask => 'Görevi Aç';

  @override
  String get rejectTaskPoint => 'Görevi Reddet (-50 Puan)';

  @override
  String get areYouSurePoint => 'EMİN MİSİN? (-50)';

  @override
  String readingContentSubtitle(String player) {
    return '$player İçeriği okuyor...';
  }

  @override
  String categoryVariable(String category) {
    return 'Kategori: $category';
  }

  @override
  String get gameNotFound => 'Oyun bulunamadı';

  @override
  String get determineYourDifficulty =>
      'Performansının zorluğunu sen belirle...';

  @override
  String get determineYourDifficultyShort =>
      'Performansının zorluğunu sen belirle';

  @override
  String get waitingCapital => 'BEKLENİYOR';

  @override
  String playerChoosingDifficulty(String player) {
    return '$player zorluk seviyesini seçiyor...';
  }

  @override
  String get easyCapital => 'KOLAY';

  @override
  String get mediumCapital => 'ORTA';

  @override
  String get hardCapital => 'ZOR';

  @override
  String estimatedEarningsPoint(int point) {
    return 'Tahmini Kazanç: $point Puan';
  }

  @override
  String get taskStarted => 'GÖREV BAŞLADI';

  @override
  String get contentLabel => 'İÇERİK:';

  @override
  String get displayedContentLabel => 'SERGİLENEN İÇERİK:';

  @override
  String get hiddenContentLabel => 'GİZLİ İÇERİK';

  @override
  String get taskNoRole => 'Rol belirtilmemiş';

  @override
  String get finishTaskInstruction =>
      'Görevi tamamladıysanız performansınızı bitirin.';

  @override
  String get finishTaskButton => 'Görevi Bitir';

  @override
  String get waitingForPerformance =>
      'Oyuncunun performansını sergilemesi bekleniyor...';

  @override
  String get waitingForPlayerCapital => 'Oyuncu Bekleniyor...';

  @override
  String get taskRejected => 'GÖREV REDDEDİLDİ';

  @override
  String get roundOver => 'TUR BİTTİ';

  @override
  String playerRefusedRole(String player) {
    return '$player rolünü yapmayı reddetti.';
  }

  @override
  String playerCompletedPerformance(String player) {
    return '$player performasını tamamladı.';
  }

  @override
  String get likedResult => 'Beğenildi';

  @override
  String get dislikedResult => 'Beğenilmedi';

  @override
  String get neutralResult => 'Kararsız';

  @override
  String get gainedPoints => 'Kazanılan Puan';

  @override
  String get lostPoints => 'Kaybedilen Puan';

  @override
  String get partyOver => 'PARTİ BİTTİ';

  @override
  String get waitingForFinal => 'Final bekleniyor...';

  @override
  String get waitingForHostNextRound =>
      'Yöneticinin yeni tura geçmesi bekleniyor...';

  @override
  String get evaluateScenario => 'SENARYOYU DEĞERLENDİR';

  @override
  String get goodUpper => 'İYİ';

  @override
  String get badUpper => 'KÖTÜ';

  @override
  String get winnerCapital => 'KAZANAN';

  @override
  String get pointsCapital => 'PUAN';

  @override
  String get negativeScoreMessage =>
      'Eksilere düşmezsin be kardeşim\nHiç bakiye kazanamadın!';

  @override
  String pointsAddedToBalance(int point) {
    return '+$point Puan bakiyenize eklendi';
  }

  @override
  String get returnToLobby => 'LOBİYE DÖN';

  @override
  String get scenarioSelection => 'SENARYO SEÇİMİ';

  @override
  String get nextPickerIsYou => 'SIRADAKİ OYUNCU SENSİN!';

  @override
  String playerIsPicking(String player) {
    return '$player SEÇİYOR...';
  }

  @override
  String pickCount(int current, int total) {
    return 'SEÇİM $current/$total';
  }

  @override
  String get partyExperience => 'PARTİ DENEYİMİ';

  @override
  String get hotDeal => 'Sıcak\nFırsat';

  @override
  String get basePoint => 'TABAN PUAN';

  @override
  String get gameEndedOrHostLeft => 'Oyun sona erdi veya ev sahibi ayrıldı.';

  @override
  String get leftPlayer => 'Ayrılan Oyuncu';

  @override
  String get waitingQueue => 'BEKLEME SIRASI';

  @override
  String playerIsPerforming(String player) {
    return '$player performansını sergiliyor...';
  }

  @override
  String playerIsDecidingRole(String player) {
    return '$player rolünü belirliyor...';
  }

  @override
  String get votingWillStartWhenTurnEnds => 'Sıra bittiğinde oylama başlayacak';

  @override
  String get preparingParty => 'Parti Hazırlanıyor...';

  @override
  String get info => 'Bilgilendirme';

  @override
  String get about => 'Hakkında';

  @override
  String get appAndTeamInfo => 'Uygulama ve ekip bilgileri';

  @override
  String get termsOfUse => 'Kullanım Koşulları';

  @override
  String get legalTermsAndConditions => 'Yasal şartlar ve koşullar';

  @override
  String get close => 'Kapat';

  @override
  String get termsOfUseContent =>
      'Son güncelleme: 2026\n\n1) Kabul ve Kapsam\nBu uygulamayi kullanarak, burada belirtilen Kullanım Koşulları\\\'nı kabul etmiş sayılırsınız. Koşulları kabul etmiyorsanız uygulamayı kullanmayınız.\n\n2) Uygun Kullanım\nKullanıcı; hile, taciz, nefret söylemi, tehdit, yasa dışı içerik paylaşımı, hesap güvenliğini ihlal etme ve hizmeti bozacak otomasyon araçları kullanmama yükümlülüğündedir.\n\n3) Hesap ve Güvenlik\nHesabınızla yapılan işlemlerden sorumlusunuz. Şüpheli erişim veya güvenlik ihlalini gecikmeden bildirmeniz gerekir.\n\n4) İçerik ve Topluluk Kuralları\nKullanıcı tarafından oluşturulan içerikler (metin, görsel vb.) topluluk kurallarına uygun olmalıdır. Kuralları ihlal eden içerikler bildirimsiz kaldırılabilir, hesaplara geçici veya kalıcı kısıt uygulanabilir.\n\n5) Fikri Mülkiyet\nUygulama arayüzü, marka öğeleri ve yazılım bileşenleri ilgili hak sahiplerine aittir. İzinsiz kopyalama, dağıtma veya tersine mühendislik yasaktır.\n\n6) Hizmette Değişiklik ve Kesinti\nHizmet, teknik bakım, güvenlik veya iş gereksinimleri nedeniyle değiştirilebilir, kısıtlanabilir veya geçici olarak durdurulabilir.\n\n7) Sorumluluğun Sınırlandırılması\nUygulama \"olduğu gibi\" sunulur. Mevzuatın izin verdiği ölçüde, dolaylı veya arızi zararlardan sorumluluk kabul edilmez.\n\n8) Hesap Sonlandırma\nKullanım koşulları veya topluluk kurallarının ihlali durumunda erişiminiz askıya alınabilir veya sonlandırılabilir.\n\n9) Koşulların Güncellenmesi\nKullanım Koşulları zaman zaman güncellenebilir. Güncel metin uygulama içinde yayımlandığı andan itibaren geçerlidir.\n\n10) İletişim\nYasal bildirimler ve destek talepleri için uygulama içi iletişim kanalları kullanılmalıdır.';

  @override
  String get notReadyYet => 'HAZIR OL';

  @override
  String get readyForParty => 'HAZIR DEĞİLİM';

  @override
  String get lobbyTip1 => 'Parti başlasın! Hazır mısın?';

  @override
  String get lobbyTip2 => 'Vereceğin cevaplar çok konuşulacak!';

  @override
  String get lobbyTip3 => 'Diğer oyuncuların oyları kaderini belirleyecek.';

  @override
  String get lobbyTip4 => 'Riskli görevler ve zor seçimler seni bekliyor.';

  @override
  String get spinning => 'Dönüyor...';

  @override
  String pointsLowercase(Object points) {
    return '$points puan';
  }

  @override
  String get titlesTab => 'Ünvanlar';

  @override
  String get framesTab => 'Çerçeveler';

  @override
  String get scenariosTab => 'Senaryolar';

  @override
  String get ownedLabel => 'SAHİP';

  @override
  String itemPurchased(Object name) {
    return '$name artık gardırobunuzda!';
  }

  @override
  String get insufficientBalance => 'Yetersiz bakiye';

  @override
  String buyError(Object message) {
    return 'Hata: $message';
  }

  @override
  String get noItems => 'Henüz sergilenecek ürün yok.';

  @override
  String get scenariosComingSoon =>
      'Özel Senaryolar ve Tema Paketleri Çok Yakında Sizlerle!';

  @override
  String get logoutSuccess => 'Çıkış Başarılı';

  @override
  String logoutError(String error) {
    return 'Çıkış başarısız: $error';
  }

  @override
  String get loginError => 'Giriş başarısız';

  @override
  String get nameEmptyError => 'Lütfen sahne adınızı belirleyin';

  @override
  String get nameTooShortError => 'İsim en az 3 karakter olmalıdır';

  @override
  String get invalidNameError => 'Sadece harf ve rakam kullanın';

  @override
  String get anonymousLoginSuccess => 'Anonim olarak giriş yapıldı';

  @override
  String get loggingIn => 'Partiye giriş yapılıyor...';

  @override
  String get playerDisplayNameHint => 'Oyuncu Adınız...';

  @override
  String get joinPartyButton => 'Partiye Katıl!';

  @override
  String get anonymousHint =>
      '* Anonim olarak devam edeceksiniz. İstatistikleriniz bu cihaza kaydedilir.';

  @override
  String get orDivider => 'Veya';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get content => 'İçerik';

  @override
  String get comingSoon => 'YAKINDA';

  @override
  String get loginSuccess => 'Giriş başarılı';

  @override
  String get editProfileTitle => 'Profilinizi Düzenleyin';

  @override
  String get updateDisplayNameTitle => 'Oyuncu Adını Güncelle';

  @override
  String get newDisplayNameLabel => 'Yeni Oyuncu Adı';

  @override
  String get cancel => 'İptal';

  @override
  String get update => 'GÜNCELLE';

  @override
  String get profileUpdated => 'Profil güncellendi!';

  @override
  String get invalidNameLong =>
      'Lütfen geçerli bir isim giriniz! (En az 3 karakter, sadece harf ve sayı)';

  @override
  String get actorTab => 'Profil';

  @override
  String get wardrobeTab => 'Eşyalar';

  @override
  String get performanceTab => 'Performans';

  @override
  String get noItemsInWardrobe =>
      'Henüz bir eşyanız yok.\nMağazadaki harika içeriklere göz atmak ister misiniz?';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get balanceLabel => 'Bakiye';

  @override
  String get rankLabel => 'Rütbe';

  @override
  String get collectionLabel => 'Koleksiyon';

  @override
  String itemsCount(int count) {
    return '$count ürün';
  }

  @override
  String get activeLabel => 'Aktif';

  @override
  String get quickStatsTitle => 'Hızlı İstatistikler';

  @override
  String get gameLabel => 'Oyun';

  @override
  String get winLabel => 'Kazanma';

  @override
  String get pointsLabel => 'Puan';

  @override
  String get rankLegend => 'Efsane';

  @override
  String get rankKing => 'Kral';

  @override
  String get rankStar => 'Yıldız';

  @override
  String get rankFun => 'Eğlenceli';

  @override
  String get rankBeginner => 'Çaylak';

  @override
  String get guestName => 'Misafir';

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String get completedLabel => 'TAMAMLANDI ✓';

  @override
  String get achievementPartyMonsterTitle => 'Parti Canavarı';

  @override
  String get achievementPartyMonsterDesc => 'Oynanan oyun sayısı';

  @override
  String get achievementVoiceOfPeopleTitle => 'Halkın Sesi';

  @override
  String get achievementVoiceOfPeopleDesc => 'Verilen oy sayısı';

  @override
  String get achievementVipTitle => 'VIP';

  @override
  String get achievementVipDesc => 'Sahip olunan bakiye';

  @override
  String get achievementSocialIconTitle => 'Sosyal İkon';

  @override
  String get achievementSocialIconDesc => 'Sahip olunan eşya sayısı';

  @override
  String get createContent => 'İçerik Oluştur';

  @override
  String get editContent => 'İçeriği Düzenle';

  @override
  String get addContent => 'İçerik Ekle';

  @override
  String get contentAdded => 'Soru eklendi!';

  @override
  String get contentUpdated => 'Soru güncellendi!';

  @override
  String get pleaseWriteContent => 'Lütfen bir içerik yazın';

  @override
  String get contentText => 'İçerik Metni';

  @override
  String get difficultyLabel => 'Zorluk';

  @override
  String get specialCategory => 'Özel İçerik';

  @override
  String get myContentsTitle => 'İçeriklerim';

  @override
  String get myContentsDescription =>
      'Bu bölümde kendi içeriklerini oluşturabilirsin.';

  @override
  String get myContentsUsage =>
      'Bu içerikleri oyun içinde kullanarak eğlenceni katlayabilirsin!';

  @override
  String get editTooltip => 'Düzenle';

  @override
  String get deleteTooltip => 'Sil';

  @override
  String get easyDifficulty => 'Kolay';

  @override
  String get mediumDifficulty => 'Orta';

  @override
  String get hardDifficulty => 'Zor';

  @override
  String get votingTitle => 'ELEŞTİRİ & OYLAMA';

  @override
  String get playerPerformed => 'performansını sergiledi:';

  @override
  String get voteTimeoutPenalty =>
      'Süre doldu. Oy vermediğin için -10 puan cezası aldın.';

  @override
  String get calculatingScore => 'Skor Hesaplanıyor...';

  @override
  String get countingVotes => 'Oylar sayılıyor...';

  @override
  String get waitingForEvaluation =>
      'Diğer oyuncuların değerlendirmesi bekleniyor...';

  @override
  String get evaluated => 'DEĞERLENDİRİLDİ';

  @override
  String get waitingTip1 => 'Herkes senin kararını bekliyor...';

  @override
  String get waitingTip2 => 'Zaman daralıyor!';

  @override
  String get waitingTip3 => 'Hızlı karar ver...';

  @override
  String get waitingTip4 => 'Acımasız ol!';

  @override
  String get waitingTip5 => 'Gerilim tırmanıyor...';

  @override
  String get howWasPerformance => 'PERFORMANS NASILDI?';

  @override
  String get evaluatePerformance =>
      'Oyuncunun sergilediği performansı değerlendirin';

  @override
  String get voteLike => 'BEĞEN';

  @override
  String get voteNeutral => 'KARARSIZ';

  @override
  String get voteDislike => 'BEĞENME';

  @override
  String get categoryMoral => 'Ahlaki';

  @override
  String get categoryKnowledge => 'Bilgi';

  @override
  String get categoryDigital => 'Dijital';

  @override
  String get categoryPhysical => 'Fiziksel';

  @override
  String get categoryVisual => 'Görsel';

  @override
  String get categoryConfession => 'İtiraf';

  @override
  String get categoryIntimate => 'Mahrem';

  @override
  String get categoryMental => 'Zihinsel';

  @override
  String get premiumRequiredTitle => 'Premium Gerekli';

  @override
  String get premiumRequiredDesc =>
      'Özel içerik üretmek için Premium gerekli. Tek seferlik Premium satın alarak bu özelliği açabilirsin.';

  @override
  String get buyPremium => 'Premium Al';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get restoringPurchases => 'Satın alımlar geri yükleniyor...';

  @override
  String get purchaseFlowStarted => 'Satın alma akışı başlatıldı.';

  @override
  String get premiumLabel => 'PREMIUM';

  @override
  String get leavePartyTitle => 'Partiden Ayrıl';

  @override
  String get leavePartyConfirm =>
      'Oyundan çıkmak istediğinize emin misiniz? (Eğer kurucuysanız oda kapanır.)';

  @override
  String get leavePartyConfirmInGame =>
      'Odadan / Oyundan ayrılmak istediğinize emin misiniz? Oyun devam ederken çıkış yapmak oyunun akışını etkileyebilir.';

  @override
  String exitButtonActiveIn(int seconds) {
    return 'Çıkış butonu $seconds saniye sonra aktif olacak.';
  }

  @override
  String get leftRoomToast => 'Odadan ayrıldınız';
}
