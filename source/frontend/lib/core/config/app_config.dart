// ignore_for_file: constant_identifier_names
//
// İçimden — App Configuration
// All secrets injected via --dart-define at build time.
//
// Run locally:
//   flutter run \
//     --dart-define=APP_ENV=dev \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ...

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  AppConfig._();

  // ── Environment ───────────────────────────────────────────────────────────
  static const String _env =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppEnvironment get environment {
    switch (_env) {
      case 'prod':    return AppEnvironment.prod;
      case 'staging': return AppEnvironment.staging;
      default:        return AppEnvironment.dev;
    }
  }

  static bool get isDev     => environment == AppEnvironment.dev;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProd    => environment == AppEnvironment.prod;

  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName      = 'İçimden';
  static const String appNameLower = 'icimden';
  static const String packageId    = 'com.icimden.app';
  static const String privacyUrl   = 'https://icimden.app/privacy';
  static const String termsUrl     = 'https://icimden.app/terms';
  static const String supportEmail = 'support@icimden.app';

  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // ── AdMob ─────────────────────────────────────────────────────────────────
  // iOS Ad Unit IDs
  static const String iosInterstitialAdUnitId = String.fromEnvironment(
    'IOS_INTERSTITIAL_AD_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910', // Test ID
  );
  static const String iosBannerAdUnitId = String.fromEnvironment(
    'IOS_BANNER_AD_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Test ID
  );

  // Android Ad Unit IDs
  static const String androidInterstitialAdUnitId = String.fromEnvironment(
    'ANDROID_INTERSTITIAL_AD_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // Test ID
  );
  static const String androidBannerAdUnitId = String.fromEnvironment(
    'ANDROID_BANNER_AD_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Test ID
  );

  // ── Edge Functions ────────────────────────────────────────────────────────
  static const String fnGenerateMotivation = 'generate-motivation';

  // ── Validation ────────────────────────────────────────────────────────────
  static void assertProductionConfig() {
    assert(
      supabaseUrl.isNotEmpty && !supabaseUrl.startsWith('YOUR'),
      'SUPABASE_URL not configured for production!',
    );
    assert(
      supabaseAnonKey.isNotEmpty && !supabaseAnonKey.startsWith('YOUR'),
      'SUPABASE_ANON_KEY not configured for production!',
    );
  }
}
