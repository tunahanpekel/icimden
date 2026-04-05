// lib/main.dart
//
// İçimden — App Entry Point
//
// Run locally:
//   flutter run \
//     --dart-define=APP_ENV=dev \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ...

import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';

Future<void> _initATT() async {
  if (Platform.isIOS) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // ── First-run Secure Storage Wipe (iOS Keychain survives reinstalls) ─────────
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('app_first_run') ?? true) {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    await prefs.setBool('app_first_run', false);
  }

  // ── Orientation ───────────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── System UI ─────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Firebase ──────────────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp();
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  } catch (e) {
    debugPrint('Firebase not configured — running without it: $e');
  }

  // ── imageCache ────────────────────────────────────────────────────────────
  PaintingBinding.instance.imageCache
    ..maximumSize = 150
    ..maximumSizeBytes = 40 << 20; // 40 MB

  // ── ErrorWidget (release: silent, debug: verbose) ─────────────────────────
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) return ErrorWidget(details.exception);
    return const SizedBox.shrink();
  };

  // ── Supabase ──────────────────────────────────────────────────────────────
  assert(
    AppConfig.supabaseUrl.isNotEmpty && !AppConfig.supabaseUrl.startsWith('YOUR'),
    'SUPABASE_URL not configured',
  );
  await Supabase.initialize(
    url:     AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug:   kDebugMode,
  );

  // ── ATT (App Tracking Transparency) — must run before AdMob on iOS ────────
  await _initATT();

  // ── AdMob ─────────────────────────────────────────────────────────────────
  await AdService.initialize();

  // ── Validate prod config ──────────────────────────────────────────────────
  if (AppConfig.isProd) AppConfig.assertProductionConfig();

  runApp(const ProviderScope(child: IcimdenApp()));
}

// ─── Root widget ──────────────────────────────────────────────────────────────

class IcimdenApp extends ConsumerWidget {
  const IcimdenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'İçimden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('es'),
        Locale('de'),
        Locale('fr'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
