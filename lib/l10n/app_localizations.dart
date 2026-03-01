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
