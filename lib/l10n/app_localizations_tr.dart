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
  String get notReady => 'Hazır Değilim';

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
  String get economyDesc => 'Strateji — puan lideri önce seçer, pazar daralır!';

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
  String error(String message) {
    return 'Hata: $message';
  }

  @override
  String get storeTitle => 'Mağaza & Cüzdan';

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
}
