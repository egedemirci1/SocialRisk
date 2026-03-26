import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Risk'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İsmini yaz ve maceraya başla!'**
  String get loginSubtitle;

  /// No description provided for @enterName.
  ///
  /// In tr, this message translates to:
  /// **'İsim gir'**
  String get enterName;

  /// No description provided for @enterButton.
  ///
  /// In tr, this message translates to:
  /// **'Gir'**
  String get enterButton;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile Giriş'**
  String get signInWithApple;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menü'**
  String get home;

  /// No description provided for @createRoom.
  ///
  /// In tr, this message translates to:
  /// **'Oda Oluştur'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In tr, this message translates to:
  /// **'Odaya Katıl'**
  String get joinRoom;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @store.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza'**
  String get store;

  /// No description provided for @copyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2026 Sosyal Risk'**
  String get copyright;

  /// No description provided for @lobby.
  ///
  /// In tr, this message translates to:
  /// **'Lobi'**
  String get lobby;

  /// No description provided for @roomCode.
  ///
  /// In tr, this message translates to:
  /// **'Oda Kodu'**
  String get roomCode;

  /// No description provided for @codeCopied.
  ///
  /// In tr, this message translates to:
  /// **'Kod kopyalandı!'**
  String get codeCopied;

  /// No description provided for @startGame.
  ///
  /// In tr, this message translates to:
  /// **'Oyunu Başlat'**
  String get startGame;

  /// No description provided for @allPlayersReady.
  ///
  /// In tr, this message translates to:
  /// **'Tüm oyuncular hazır!'**
  String get allPlayersReady;

  /// No description provided for @waitForPlayers.
  ///
  /// In tr, this message translates to:
  /// **'Herkesin hazır olmasını bekle...'**
  String get waitForPlayers;

  /// No description provided for @ready.
  ///
  /// In tr, this message translates to:
  /// **'Hazırım!'**
  String get ready;

  /// No description provided for @notReady.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Değilim'**
  String get notReady;

  /// No description provided for @playerCapacity.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Kapasitesi'**
  String get playerCapacity;

  /// No description provided for @player.
  ///
  /// In tr, this message translates to:
  /// **'oyuncu'**
  String get player;

  /// No description provided for @endCondition.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Koşulu'**
  String get endCondition;

  /// No description provided for @scoreTarget.
  ///
  /// In tr, this message translates to:
  /// **'Puan Hedefi'**
  String get scoreTarget;

  /// No description provided for @roundTarget.
  ///
  /// In tr, this message translates to:
  /// **'Tur Sayısı'**
  String get roundTarget;

  /// No description provided for @points.
  ///
  /// In tr, this message translates to:
  /// **'puan'**
  String get points;

  /// No description provided for @rounds.
  ///
  /// In tr, this message translates to:
  /// **'tur'**
  String get rounds;

  /// No description provided for @gameMode.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Modu'**
  String get gameMode;

  /// No description provided for @classicWheel.
  ///
  /// In tr, this message translates to:
  /// **'Klasik Çark'**
  String get classicWheel;

  /// No description provided for @classicDesc.
  ///
  /// In tr, this message translates to:
  /// **'Şans ve kaos — çarkı çevir, hangi kategori gelirse o!'**
  String get classicDesc;

  /// No description provided for @economyMode.
  ///
  /// In tr, this message translates to:
  /// **'Ekonomi'**
  String get economyMode;

  /// No description provided for @economyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Strateji — puan lideri önce seçer, pazar daralır!'**
  String get economyDesc;

  /// No description provided for @visibilityMode.
  ///
  /// In tr, this message translates to:
  /// **'Görünürlük Modu'**
  String get visibilityMode;

  /// No description provided for @openMode.
  ///
  /// In tr, this message translates to:
  /// **'Açık Mod'**
  String get openMode;

  /// No description provided for @closedMode.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı Mod'**
  String get closedMode;

  /// No description provided for @openModeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Herkes görev içeriğini önceden görebilir.'**
  String get openModeDesc;

  /// No description provided for @closedModeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sadece kategori ve çarpan görünür. İçerik gizli!'**
  String get closedModeDesc;

  /// No description provided for @difficulty.
  ///
  /// In tr, this message translates to:
  /// **'Görev Zorluğu'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In tr, this message translates to:
  /// **'Kolay'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In tr, this message translates to:
  /// **'Zor'**
  String get hard;

  /// No description provided for @mixed.
  ///
  /// In tr, this message translates to:
  /// **'Karışık'**
  String get mixed;

  /// No description provided for @createRoomButton.
  ///
  /// In tr, this message translates to:
  /// **'Odayı Oluştur'**
  String get createRoomButton;

  /// No description provided for @enterRoomCode.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli oda kodunu gir'**
  String get enterRoomCode;

  /// No description provided for @joinButton.
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get joinButton;

  /// No description provided for @spinWheel.
  ///
  /// In tr, this message translates to:
  /// **'Çarkı Çevir!'**
  String get spinWheel;

  /// No description provided for @spinningPlayer.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} çarkı çeviriyor...'**
  String spinningPlayer(String playerName);

  /// No description provided for @categoryRandom.
  ///
  /// In tr, this message translates to:
  /// **'Kategori şansa bağlı!'**
  String get categoryRandom;

  /// No description provided for @yourTurn.
  ///
  /// In tr, this message translates to:
  /// **'Senin Sıran!'**
  String get yourTurn;

  /// No description provided for @playerPlaying.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} oynuyor'**
  String playerPlaying(String playerName);

  /// No description provided for @yourTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevin:'**
  String get yourTask;

  /// No description provided for @playerTask.
  ///
  /// In tr, this message translates to:
  /// **'{playerName}\'in Görevi:'**
  String playerTask(String playerName);

  /// No description provided for @closedModeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı Mod'**
  String get closedModeLabel;

  /// No description provided for @revealTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Aç 🔓'**
  String get revealTask;

  /// No description provided for @acceptTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Kabul Et'**
  String get acceptTask;

  /// No description provided for @passTask.
  ///
  /// In tr, this message translates to:
  /// **'Pas Geç (Ceza: -{penalty} puan)'**
  String passTask(int penalty);

  /// No description provided for @waitingForDecision.
  ///
  /// In tr, this message translates to:
  /// **'{playerName}\'ın karar vermesi bekleniyor...'**
  String waitingForDecision(String playerName);

  /// No description provided for @winner.
  ///
  /// In tr, this message translates to:
  /// **'KAZANAN!'**
  String get winner;

  /// No description provided for @finalRanking.
  ///
  /// In tr, this message translates to:
  /// **'Final Sıralaması'**
  String get finalRanking;

  /// No description provided for @goToStore.
  ///
  /// In tr, this message translates to:
  /// **'Mağazaya Git'**
  String get goToStore;

  /// No description provided for @goToRooms.
  ///
  /// In tr, this message translates to:
  /// **'Odalara Dön'**
  String get goToRooms;

  /// No description provided for @walletAdded.
  ///
  /// In tr, this message translates to:
  /// **'+{points} Puan Cüzdana Eklendi'**
  String walletAdded(int points);

  /// No description provided for @pickCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seç'**
  String get pickCategory;

  /// No description provided for @yourPick.
  ///
  /// In tr, this message translates to:
  /// **'Senin sıran!'**
  String get yourPick;

  /// No description provided for @playerPicking.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} seçiyor...'**
  String playerPicking(String playerName);

  /// No description provided for @pickProgress.
  ///
  /// In tr, this message translates to:
  /// **'Seçim {current}/{total}'**
  String pickProgress(int current, int total);

  /// No description provided for @marketStatus.
  ///
  /// In tr, this message translates to:
  /// **'Pazar Durumu'**
  String get marketStatus;

  /// No description provided for @categoryLocked.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategori kilitli!'**
  String get categoryLocked;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {message}'**
  String error(String message);

  /// No description provided for @storeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza & Cüzdan'**
  String get storeTitle;

  /// No description provided for @storeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kozmetikler ve içerikler'**
  String get storeSubtitle;

  /// No description provided for @cosmetics.
  ///
  /// In tr, this message translates to:
  /// **'Kozmetikler'**
  String get cosmetics;

  /// No description provided for @frames.
  ///
  /// In tr, this message translates to:
  /// **'Çerçeveler'**
  String get frames;

  /// No description provided for @badges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler & Ünvanlar'**
  String get badges;

  /// No description provided for @owned.
  ///
  /// In tr, this message translates to:
  /// **'Sahipsin'**
  String get owned;

  /// No description provided for @you.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ses ve Dil'**
  String get settingsSubtitle;

  /// No description provided for @menuMusic.
  ///
  /// In tr, this message translates to:
  /// **'Menü Müziği'**
  String get menuMusic;

  /// No description provided for @soundEffects.
  ///
  /// In tr, this message translates to:
  /// **'Ses Efektleri'**
  String get soundEffects;

  /// No description provided for @on.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get on;

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @languageSelection.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçimi'**
  String get languageSelection;

  /// No description provided for @newParty.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Parti Başlat'**
  String get newParty;

  /// No description provided for @joinParty.
  ///
  /// In tr, this message translates to:
  /// **'Partiye Katıl'**
  String get joinParty;

  /// No description provided for @myContent.
  ///
  /// In tr, this message translates to:
  /// **'İçeriklerim'**
  String get myContent;

  /// No description provided for @myContentSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kendi içeriklerini yönet'**
  String get myContentSubtitle;

  /// No description provided for @logOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logOut;

  /// No description provided for @adminPanel.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici Paneli'**
  String get adminPanel;

  /// No description provided for @attention.
  ///
  /// In tr, this message translates to:
  /// **'DİKKAT!'**
  String get attention;

  /// No description provided for @logoutWarning.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek ve çıkış yapmak istediğinize emin misiniz? Bu işlem geri alınamaz.'**
  String get logoutWarning;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @deleteAndExit.
  ///
  /// In tr, this message translates to:
  /// **'Sil ve Çık'**
  String get deleteAndExit;

  /// No description provided for @sendEmote.
  ///
  /// In tr, this message translates to:
  /// **'Emote Gönder'**
  String get sendEmote;

  /// No description provided for @emoteCooldown.
  ///
  /// In tr, this message translates to:
  /// **'Emote Bekleme'**
  String get emoteCooldown;

  /// No description provided for @partyStarting.
  ///
  /// In tr, this message translates to:
  /// **'PARTİ BAŞLIYOR!'**
  String get partyStarting;

  /// No description provided for @chooseTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevini Belirle'**
  String get chooseTask;

  /// No description provided for @spinWheelSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Rastgele Kategori İçin Çarkı Çevir!'**
  String get spinWheelSubtitle;

  /// No description provided for @taskReveal.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Aç'**
  String get taskReveal;

  /// No description provided for @startTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Başlat'**
  String get startTask;

  /// No description provided for @waitingForPlayerAction.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncunun performansını sergilemesi bekleniyor...'**
  String get waitingForPlayerAction;

  /// No description provided for @finishTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Bitir'**
  String get finishTask;

  /// No description provided for @taskResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'TUR BİTTİ'**
  String get taskResultTitle;

  /// No description provided for @taskResultSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} performansını tamamladı.'**
  String taskResultSubtitle(String playerName);

  /// No description provided for @taskRejectedTitle.
  ///
  /// In tr, this message translates to:
  /// **'GÖREV REDDEDİLDİ'**
  String get taskRejectedTitle;

  /// No description provided for @taskRejectedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} rolünü yapmayı reddetti.'**
  String taskRejectedSubtitle(String playerName);

  /// No description provided for @audienceScore.
  ///
  /// In tr, this message translates to:
  /// **'Seyirci Puanı'**
  String get audienceScore;

  /// No description provided for @performanceResult.
  ///
  /// In tr, this message translates to:
  /// **'Performans Sonucu'**
  String get performanceResult;

  /// No description provided for @liked.
  ///
  /// In tr, this message translates to:
  /// **'Beğenildi'**
  String get liked;

  /// No description provided for @disliked.
  ///
  /// In tr, this message translates to:
  /// **'Beğenilmedi'**
  String get disliked;

  /// No description provided for @undecided.
  ///
  /// In tr, this message translates to:
  /// **'Kararsız'**
  String get undecided;

  /// No description provided for @difficultyMultiplier.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk Çarpanı'**
  String get difficultyMultiplier;

  /// No description provided for @pointsWon.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Puan'**
  String get pointsWon;

  /// No description provided for @pointsLost.
  ///
  /// In tr, this message translates to:
  /// **'Kaybedilen Puan'**
  String get pointsLost;

  /// No description provided for @playerRanking.
  ///
  /// In tr, this message translates to:
  /// **'OYUNCU SIRALAMASI'**
  String get playerRanking;

  /// No description provided for @nextTask.
  ///
  /// In tr, this message translates to:
  /// **'SIRADAKİ GÖREV'**
  String get nextTask;

  /// No description provided for @waitingForHostNextTurn.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinin yeni tura geçmesi bekleniyor...'**
  String get waitingForHostNextTurn;

  /// No description provided for @rateScenario.
  ///
  /// In tr, this message translates to:
  /// **'SENARYOYU DEĞERLENDİR'**
  String get rateScenario;

  /// No description provided for @good.
  ///
  /// In tr, this message translates to:
  /// **'İYİ'**
  String get good;

  /// No description provided for @bad.
  ///
  /// In tr, this message translates to:
  /// **'KÖTÜ'**
  String get bad;

  /// No description provided for @difficultyLevel.
  ///
  /// In tr, this message translates to:
  /// **'Zorluk Seviyesi'**
  String get difficultyLevel;

  /// No description provided for @riskAndReward.
  ///
  /// In tr, this message translates to:
  /// **'RİSK VE ÖDÜL'**
  String get riskAndReward;

  /// No description provided for @chooseDifficultyOneLine.
  ///
  /// In tr, this message translates to:
  /// **'Performansının zorluğunu sen belirle'**
  String get chooseDifficultyOneLine;

  /// No description provided for @chooseDifficultyTwoLines.
  ///
  /// In tr, this message translates to:
  /// **'Performansının zorluğunu sen belirle...'**
  String get chooseDifficultyTwoLines;

  /// No description provided for @estimatedGain.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Kazanç: {points} Puan'**
  String estimatedGain(int points);

  /// No description provided for @waitingDifficulty.
  ///
  /// In tr, this message translates to:
  /// **'{playerName} zorluk seviyesini seçiyor...'**
  String waitingDifficulty(String playerName);

  /// No description provided for @categoriesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categoriesLabel;

  /// No description provided for @homeScreenLoading.
  ///
  /// In tr, this message translates to:
  /// **'Ana menü yükleniyor...'**
  String get homeScreenLoading;

  /// No description provided for @menu.
  ///
  /// In tr, this message translates to:
  /// **'Menü'**
  String get menu;

  /// No description provided for @roomClosedHostLeft.
  ///
  /// In tr, this message translates to:
  /// **'Ev sahibi odadan ayrıldığı için oda kapatıldı.'**
  String get roomClosedHostLeft;

  /// No description provided for @preparingGame.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Hazırlanıyor...'**
  String get preparingGame;

  /// No description provided for @wheelModeCapital.
  ///
  /// In tr, this message translates to:
  /// **'ÇARK MODU'**
  String get wheelModeCapital;

  /// No description provided for @marketModeCapital.
  ///
  /// In tr, this message translates to:
  /// **'BORSA MODU'**
  String get marketModeCapital;

  /// No description provided for @chooseAnEmote.
  ///
  /// In tr, this message translates to:
  /// **'Bir Emote Seç'**
  String get chooseAnEmote;

  /// No description provided for @sendEmoteCooldown.
  ///
  /// In tr, this message translates to:
  /// **'Emote Bekleme {seconds}sn'**
  String sendEmoteCooldown(int seconds);

  /// No description provided for @everyoneWaitingForYou.
  ///
  /// In tr, this message translates to:
  /// **'Haydi, herkes seni bekliyor!'**
  String get everyoneWaitingForYou;

  /// No description provided for @waitForOthersToReady.
  ///
  /// In tr, this message translates to:
  /// **'Diğer oyuncuların hazırlanmasını bekleyin...'**
  String get waitForOthersToReady;

  /// No description provided for @youSuffix.
  ///
  /// In tr, this message translates to:
  /// **' (Sen)'**
  String get youSuffix;

  /// No description provided for @hostDefaultName.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen'**
  String get hostDefaultName;

  /// No description provided for @roomCreating.
  ///
  /// In tr, this message translates to:
  /// **'Parti Kuruluyor...'**
  String get roomCreating;

  /// No description provided for @newPartyHostTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Parti Kur'**
  String get newPartyHostTitle;

  /// No description provided for @endConditionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Sonu'**
  String get endConditionLabel;

  /// No description provided for @gameModeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Modu'**
  String get gameModeLabel;

  /// No description provided for @startPartyButton.
  ///
  /// In tr, this message translates to:
  /// **'Partiyi Başlat'**
  String get startPartyButton;

  /// No description provided for @roundLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tur'**
  String get roundLabel;

  /// No description provided for @pointLabel.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get pointLabel;

  /// No description provided for @classicModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Klasik Parti'**
  String get classicModeTitle;

  /// No description provided for @economyModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Patron Parti'**
  String get economyModeTitle;

  /// No description provided for @classicModeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Şans çarkını çevir ve rastgele kategoriden gelen riskli cezalarla yüzleş. Puan toplamak için tek şansın cesaret!'**
  String get classicModeDesc;

  /// No description provided for @economyModeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Görevleri tamamlayarak coin kazan; bu coinlerle başkalarına ceza kitle, risklerden kurtul. Kim daha acımasızsa o kazanır.'**
  String get economyModeDesc;

  /// No description provided for @singleCategoryEconomyWarn.
  ///
  /// In tr, this message translates to:
  /// **'Tek kategori seçildiğinde sadece Borsa modu kullanılabilir.'**
  String get singleCategoryEconomyWarn;

  /// No description provided for @singleCategoryEconomyAutoChange.
  ///
  /// In tr, this message translates to:
  /// **'Tek kategori seçildi. Oyun modu otomatik Borsa moduna alındı.'**
  String get singleCategoryEconomyAutoChange;

  /// No description provided for @minOneCategoryWarn.
  ///
  /// In tr, this message translates to:
  /// **'En az 1 kategori seçmelisiniz.'**
  String get minOneCategoryWarn;

  /// No description provided for @pleaseEnter6DigitCode.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen 6 haneli kodu gir'**
  String get pleaseEnter6DigitCode;

  /// No description provided for @playerDefaultName.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get playerDefaultName;

  /// No description provided for @partyNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Parti bulunamadı: {error}'**
  String partyNotFound(String error);

  /// No description provided for @connectingToParty.
  ///
  /// In tr, this message translates to:
  /// **'Partiye bağlanılıyor...'**
  String get connectingToParty;

  /// No description provided for @joinPartyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Partiye Katıl'**
  String get joinPartyTitle;

  /// No description provided for @enterPartyCode.
  ///
  /// In tr, this message translates to:
  /// **'Parti Kodunu Gir'**
  String get enterPartyCode;

  /// No description provided for @enterPartyCodeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarının paylaştığı 6 haneli parti kodunu girerek eğlenceye dahil ol.'**
  String get enterPartyCodeDesc;

  /// No description provided for @determineYourTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevini Belirle'**
  String get determineYourTask;

  /// No description provided for @hiddenRound.
  ///
  /// In tr, this message translates to:
  /// **'GİZLİ TUR'**
  String get hiddenRound;

  /// No description provided for @taskCapital.
  ///
  /// In tr, this message translates to:
  /// **'GÖREV'**
  String get taskCapital;

  /// No description provided for @nextTaskHidden.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki Görev Gizli'**
  String get nextTaskHidden;

  /// No description provided for @yourContentHere.
  ///
  /// In tr, this message translates to:
  /// **'İçeriğin Burada:'**
  String get yourContentHere;

  /// No description provided for @contentForPlayer.
  ///
  /// In tr, this message translates to:
  /// **'{player} İçeriği:'**
  String contentForPlayer(String player);

  /// No description provided for @openCardToViewTask.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut görevi görmek için kartı aç...'**
  String get openCardToViewTask;

  /// No description provided for @openTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Aç'**
  String get openTask;

  /// No description provided for @rejectTaskPoint.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Reddet (-50 Puan)'**
  String get rejectTaskPoint;

  /// No description provided for @areYouSurePoint.
  ///
  /// In tr, this message translates to:
  /// **'EMİN MİSİN? (-50)'**
  String get areYouSurePoint;

  /// No description provided for @readingContentSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{player} İçeriği okuyor...'**
  String readingContentSubtitle(String player);

  /// No description provided for @categoryVariable.
  ///
  /// In tr, this message translates to:
  /// **'Kategori: {category}'**
  String categoryVariable(String category);

  /// No description provided for @gameNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Oyun bulunamadı'**
  String get gameNotFound;

  /// No description provided for @determineYourDifficulty.
  ///
  /// In tr, this message translates to:
  /// **'Performansının zorluğunu sen belirle...'**
  String get determineYourDifficulty;

  /// No description provided for @determineYourDifficultyShort.
  ///
  /// In tr, this message translates to:
  /// **'Performansının zorluğunu sen belirle'**
  String get determineYourDifficultyShort;

  /// No description provided for @waitingCapital.
  ///
  /// In tr, this message translates to:
  /// **'BEKLENİYOR'**
  String get waitingCapital;

  /// No description provided for @playerChoosingDifficulty.
  ///
  /// In tr, this message translates to:
  /// **'{player} zorluk seviyesini seçiyor...'**
  String playerChoosingDifficulty(String player);

  /// No description provided for @easyCapital.
  ///
  /// In tr, this message translates to:
  /// **'KOLAY'**
  String get easyCapital;

  /// No description provided for @mediumCapital.
  ///
  /// In tr, this message translates to:
  /// **'ORTA'**
  String get mediumCapital;

  /// No description provided for @hardCapital.
  ///
  /// In tr, this message translates to:
  /// **'ZOR'**
  String get hardCapital;

  /// No description provided for @estimatedEarningsPoint.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Kazanç: {point} Puan'**
  String estimatedEarningsPoint(int point);

  /// No description provided for @taskStarted.
  ///
  /// In tr, this message translates to:
  /// **'GÖREV BAŞLADI'**
  String get taskStarted;

  /// No description provided for @contentLabel.
  ///
  /// In tr, this message translates to:
  /// **'İÇERİK:'**
  String get contentLabel;

  /// No description provided for @displayedContentLabel.
  ///
  /// In tr, this message translates to:
  /// **'SERGİLENEN İÇERİK:'**
  String get displayedContentLabel;

  /// No description provided for @hiddenContentLabel.
  ///
  /// In tr, this message translates to:
  /// **'GİZLİ İÇERİK'**
  String get hiddenContentLabel;

  /// No description provided for @taskNoRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol belirtilmemiş'**
  String get taskNoRole;

  /// No description provided for @finishTaskInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Görevi tamamladıysanız performansınızı bitirin.'**
  String get finishTaskInstruction;

  /// No description provided for @finishTaskButton.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Bitir'**
  String get finishTaskButton;

  /// No description provided for @waitingForPerformance.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncunun performansını sergilemesi bekleniyor...'**
  String get waitingForPerformance;

  /// No description provided for @waitingForPlayerCapital.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Bekleniyor...'**
  String get waitingForPlayerCapital;

  /// No description provided for @taskRejected.
  ///
  /// In tr, this message translates to:
  /// **'GÖREV REDDEDİLDİ'**
  String get taskRejected;

  /// No description provided for @roundOver.
  ///
  /// In tr, this message translates to:
  /// **'TUR BİTTİ'**
  String get roundOver;

  /// No description provided for @playerRefusedRole.
  ///
  /// In tr, this message translates to:
  /// **'{player} rolünü yapmayı reddetti.'**
  String playerRefusedRole(String player);

  /// No description provided for @playerCompletedPerformance.
  ///
  /// In tr, this message translates to:
  /// **'{player} performasını tamamladı.'**
  String playerCompletedPerformance(String player);

  /// No description provided for @likedResult.
  ///
  /// In tr, this message translates to:
  /// **'Beğenildi'**
  String get likedResult;

  /// No description provided for @dislikedResult.
  ///
  /// In tr, this message translates to:
  /// **'Beğenilmedi'**
  String get dislikedResult;

  /// No description provided for @neutralResult.
  ///
  /// In tr, this message translates to:
  /// **'Kararsız'**
  String get neutralResult;

  /// No description provided for @gainedPoints.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Puan'**
  String get gainedPoints;

  /// No description provided for @lostPoints.
  ///
  /// In tr, this message translates to:
  /// **'Kaybedilen Puan'**
  String get lostPoints;

  /// No description provided for @partyOver.
  ///
  /// In tr, this message translates to:
  /// **'PARTİ BİTTİ'**
  String get partyOver;

  /// No description provided for @waitingForFinal.
  ///
  /// In tr, this message translates to:
  /// **'Final bekleniyor...'**
  String get waitingForFinal;

  /// No description provided for @waitingForHostNextRound.
  ///
  /// In tr, this message translates to:
  /// **'Yöneticinin yeni tura geçmesi bekleniyor...'**
  String get waitingForHostNextRound;

  /// No description provided for @evaluateScenario.
  ///
  /// In tr, this message translates to:
  /// **'SENARYOYU DEĞERLENDİR'**
  String get evaluateScenario;

  /// No description provided for @goodUpper.
  ///
  /// In tr, this message translates to:
  /// **'İYİ'**
  String get goodUpper;

  /// No description provided for @badUpper.
  ///
  /// In tr, this message translates to:
  /// **'KÖTÜ'**
  String get badUpper;

  /// No description provided for @winnerCapital.
  ///
  /// In tr, this message translates to:
  /// **'KAZANAN'**
  String get winnerCapital;

  /// No description provided for @pointsCapital.
  ///
  /// In tr, this message translates to:
  /// **'PUAN'**
  String get pointsCapital;

  /// No description provided for @negativeScoreMessage.
  ///
  /// In tr, this message translates to:
  /// **'Eksilere düşmezsin be kardeşim\nHiç bakiye kazanamadın!'**
  String get negativeScoreMessage;

  /// No description provided for @pointsAddedToBalance.
  ///
  /// In tr, this message translates to:
  /// **'+{point} Puan bakiyenize eklendi'**
  String pointsAddedToBalance(int point);

  /// No description provided for @returnToLobby.
  ///
  /// In tr, this message translates to:
  /// **'LOBİYE DÖN'**
  String get returnToLobby;

  /// No description provided for @scenarioSelection.
  ///
  /// In tr, this message translates to:
  /// **'SENARYO SEÇİMİ'**
  String get scenarioSelection;

  /// No description provided for @nextPickerIsYou.
  ///
  /// In tr, this message translates to:
  /// **'SIRADAKİ OYUNCU SENSİN!'**
  String get nextPickerIsYou;

  /// No description provided for @playerIsPicking.
  ///
  /// In tr, this message translates to:
  /// **'{player} SEÇİYOR...'**
  String playerIsPicking(String player);

  /// No description provided for @pickCount.
  ///
  /// In tr, this message translates to:
  /// **'SEÇİM {current}/{total}'**
  String pickCount(int current, int total);

  /// No description provided for @partyExperience.
  ///
  /// In tr, this message translates to:
  /// **'PARTİ DENEYİMİ'**
  String get partyExperience;

  /// No description provided for @hotDeal.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak\nFırsat'**
  String get hotDeal;

  /// No description provided for @basePoint.
  ///
  /// In tr, this message translates to:
  /// **'TABAN PUAN'**
  String get basePoint;

  /// No description provided for @gameEndedOrHostLeft.
  ///
  /// In tr, this message translates to:
  /// **'Oyun sona erdi veya ev sahibi ayrıldı.'**
  String get gameEndedOrHostLeft;

  /// No description provided for @leftPlayer.
  ///
  /// In tr, this message translates to:
  /// **'Ayrılan Oyuncu'**
  String get leftPlayer;

  /// No description provided for @waitingQueue.
  ///
  /// In tr, this message translates to:
  /// **'BEKLEME SIRASI'**
  String get waitingQueue;

  /// No description provided for @playerIsPerforming.
  ///
  /// In tr, this message translates to:
  /// **'{player} performansını sergiliyor...'**
  String playerIsPerforming(String player);

  /// No description provided for @playerIsDecidingRole.
  ///
  /// In tr, this message translates to:
  /// **'{player} rolünü belirliyor...'**
  String playerIsDecidingRole(String player);

  /// No description provided for @votingWillStartWhenTurnEnds.
  ///
  /// In tr, this message translates to:
  /// **'Sıra bittiğinde oylama başlayacak'**
  String get votingWillStartWhenTurnEnds;

  /// No description provided for @preparingParty.
  ///
  /// In tr, this message translates to:
  /// **'Parti Hazırlanıyor...'**
  String get preparingParty;

  /// No description provided for @info.
  ///
  /// In tr, this message translates to:
  /// **'Bilgilendirme'**
  String get info;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Credits / Hakkında'**
  String get about;

  /// No description provided for @appAndTeamInfo.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama ve ekip bilgileri'**
  String get appAndTeamInfo;

  /// No description provided for @termsOfUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfUse;

  /// No description provided for @legalTermsAndConditions.
  ///
  /// In tr, this message translates to:
  /// **'Yasal şartlar ve koşullar'**
  String get legalTermsAndConditions;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @termsOfUseContent.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: 2026\n\n1) Kabul ve Kapsam\nBu uygulamayi kullanarak, burada belirtilen Kullanım Koşulları\\\'nı kabul etmiş sayılırsınız. Koşulları kabul etmiyorsanız uygulamayı kullanmayınız.\n\n2) Uygun Kullanım\nKullanıcı; hile, taciz, nefret söylemi, tehdit, yasa dışı içerik paylaşımı, hesap güvenliğini ihlal etme ve hizmeti bozacak otomasyon araçları kullanmama yükümlülüğündedir.\n\n3) Hesap ve Güvenlik\nHesabınızla yapılan işlemlerden sorumlusunuz. Şüpheli erişim veya güvenlik ihlalini gecikmeden bildirmeniz gerekir.\n\n4) İçerik ve Topluluk Kuralları\nKullanıcı tarafından oluşturulan içerikler (metin, görsel vb.) topluluk kurallarına uygun olmalıdır. Kuralları ihlal eden içerikler bildirimsiz kaldırılabilir, hesaplara geçici veya kalıcı kısıt uygulanabilir.\n\n5) Fikri Mülkiyet\nUygulama arayüzü, marka öğeleri ve yazılım bileşenleri ilgili hak sahiplerine aittir. İzinsiz kopyalama, dağıtma veya tersine mühendislik yasaktır.\n\n6) Hizmette Değişiklik ve Kesinti\nHizmet, teknik bakım, güvenlik veya iş gereksinimleri nedeniyle değiştirilebilir, kısıtlanabilir veya geçici olarak durdurulabilir.\n\n7) Sorumluluğun Sınırlandırılması\nUygulama \"olduğu gibi\" sunulur. Mevzuatın izin verdiği ölçüde, dolaylı veya arızi zararlardan sorumluluk kabul edilmez.\n\n8) Hesap Sonlandırma\nKullanım koşulları veya topluluk kurallarının ihlali durumunda erişiminiz askıya alınabilir veya sonlandırılabilir.\n\n9) Koşulların Güncellenmesi\nKullanım Koşulları zaman zaman güncellenebilir. Güncel metin uygulama içinde yayımlandığı andan itibaren geçerlidir.\n\n10) İletişim\nYasal bildirimler ve destek talepleri için uygulama içi iletişim kanalları kullanılmalıdır.'**
  String get termsOfUseContent;

  /// No description provided for @notReadyYet.
  ///
  /// In tr, this message translates to:
  /// **'HENÜZ HAZIR DEĞİLİM'**
  String get notReadyYet;

  /// No description provided for @readyForParty.
  ///
  /// In tr, this message translates to:
  /// **'PARTİYE HAZIRIM!'**
  String get readyForParty;

  /// No description provided for @lobbyTip1.
  ///
  /// In tr, this message translates to:
  /// **'Parti başlasın! Hazır mısın?'**
  String get lobbyTip1;

  /// No description provided for @lobbyTip2.
  ///
  /// In tr, this message translates to:
  /// **'Vereceğin cevaplar çok konuşulacak!'**
  String get lobbyTip2;

  /// No description provided for @lobbyTip3.
  ///
  /// In tr, this message translates to:
  /// **'Diğer oyuncuların oyları kaderini belirleyecek.'**
  String get lobbyTip3;

  /// No description provided for @lobbyTip4.
  ///
  /// In tr, this message translates to:
  /// **'Riskli görevler ve zor seçimler seni bekliyor.'**
  String get lobbyTip4;

  /// No description provided for @spinning.
  ///
  /// In tr, this message translates to:
  /// **'Dönüyor...'**
  String get spinning;

  /// No description provided for @pointsLowercase.
  ///
  /// In tr, this message translates to:
  /// **'{points} puan'**
  String pointsLowercase(Object points);

  /// No description provided for @titlesTab.
  ///
  /// In tr, this message translates to:
  /// **'Ünvanlar'**
  String get titlesTab;

  /// No description provided for @framesTab.
  ///
  /// In tr, this message translates to:
  /// **'Çerçeveler'**
  String get framesTab;

  /// No description provided for @scenariosTab.
  ///
  /// In tr, this message translates to:
  /// **'Senaryolar'**
  String get scenariosTab;

  /// No description provided for @ownedLabel.
  ///
  /// In tr, this message translates to:
  /// **'SAHİP'**
  String get ownedLabel;

  /// No description provided for @itemPurchased.
  ///
  /// In tr, this message translates to:
  /// **'{name} artık gardırobunuzda!'**
  String itemPurchased(Object name);

  /// No description provided for @insufficientBalance.
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz bakiye'**
  String get insufficientBalance;

  /// No description provided for @buyError.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {message}'**
  String buyError(Object message);

  /// No description provided for @noItems.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sergilenecek ürün yok.'**
  String get noItems;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'YAKINDA...'**
  String get comingSoon;

  /// No description provided for @scenariosComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Özel Senaryolar ve Tema Paketleri Çok Yakında Sizlerle!'**
  String get scenariosComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
