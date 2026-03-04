import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import 'package:social_risk/features/room/data/firebase_room_source.dart';
import 'package:social_risk/core/providers/lifecycle_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── FONTS: Enable Google Fonts HTTP fetching ───
  // Allows downloading fonts like Cinzel over HTTP.
  GoogleFonts.config.allowRuntimeFetching = true;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ─── NOTE: TaskSeedMigration removed from startup ───
  // It was hitting Firestore before auth → always failed with permission-denied.
  // Seed tasks from the admin panel instead.

  // ─── CLEANUP: Remove zombie rooms and games (older than 24h) ───
  // Non-blocking background operation
  unawaited(FirebaseRoomSource().cleanupZombieRoomsAndGames());

  // Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Firebase Auth persistence
  // Web: Otomatik olarak localStorage kullanır
  // Android: Otomatik olarak SharedPreferences kullanır
  // iOS: Otomatik olarak Keychain kullanır
  // Mobil platformlarda ek ayar gerekmez, Firebase Auth varsayılan olarak oturumu saklar
  if (kIsWeb) {
    // Web'de Firebase Auth otomatik olarak localStorage'da oturum bilgilerini saklar
    // Bu sayede kullanıcı sayfayı yenilediğinde veya tarayıcıyı kapattığında oturum korunur
    final auth = FirebaseAuth.instance;
    // Auth state değişikliklerini dinlemek için listener ekliyoruz
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('User signed in: ${user.uid}');
      } else {
        debugPrint('User signed out');
      }
    });
  } else {
    // Mobil platformlarda (Android/iOS) Firebase Auth otomatik olarak:
    // - Android: SharedPreferences'da oturum bilgilerini saklar
    // - iOS: Keychain'de oturum bilgilerini saklar
    // Uygulama kapatılıp açıldığında otomatik olarak oturum geri yüklenir
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('User signed in (mobile): ${user.uid}');
      } else {
        debugPrint('User signed out (mobile)');
      }
    });
  }

  // Crashlytics — only on native platforms (NOT supported on web)
  if (!kIsWeb) {
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const ProviderScope(child: SocialRiskApp()));
}

class SocialRiskApp extends ConsumerWidget {
  const SocialRiskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Lifecycle Manager
    ref.watch(appLifecycleManagerProvider);

    return MaterialApp.router(
      title: 'Sosyal Risk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
    );
  }
}
