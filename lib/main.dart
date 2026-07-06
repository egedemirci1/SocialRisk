import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:social_risk/core/constants/app_locale_options.dart';
import 'package:social_risk/l10n/app_localizations.dart';
import 'package:social_risk/core/providers/lifecycle_provider.dart';
import 'package:social_risk/core/providers/locale_provider.dart';
import 'package:social_risk/core/audio/audio_service.dart';
import 'package:social_risk/core/audio/menu_music_binder.dart';
import 'package:social_risk/shared/widgets/common/themed_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_risk/core/providers/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Firebase Initialization ───
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ─── NOTE: TaskSeedMigration removed from startup ───
  // It was hitting Firestore before auth → always failed with permission-denied.
  // Seed tasks from the admin panel instead.

  // ─── CLEANUP: Zombie temizliği Cloud Function (cleanupOldSessions) tarafından yapılıyor.

  // Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024, // 100 MB
  );

  // Firebase Auth persistence — tüm platformlarda otomatik yönetilir.
  // GoRouter'daki _AuthRefreshNotifier auth değişikliklerini zaten dinliyor.

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

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SocialRiskApp(),
    ),
  );
}

class SocialRiskApp extends ConsumerWidget {
  const SocialRiskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLifecycleManagerProvider);
    final localePreference = ref.watch(appLocaleProvider);

    final locale = resolveMaterialLocale(localePreference);
    final l = lookupAppLocalizations(locale);

    return MaterialApp.router(
      title: l.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            try {
              ref.read(audioServiceProvider).retryPendingMusic();
            } catch (_) {}
          },
          child: MenuMusicBinder(
            child: ThemedBackground(child: child!),
          ),
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: resolveMaterialLocale(localePreference),
    );
  }
}
