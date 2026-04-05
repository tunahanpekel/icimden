// lib/core/network/supabase_client.dart
//
// Supabase client wrapper for İçimden.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class SupabaseClientService {
  SupabaseClientService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient   get auth   => Supabase.instance.client.auth;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url:      AppConfig.supabaseUrl,
      anonKey:  AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: kDebugMode,
    );
  }

  // ── Table names ─────────────────────────────────────────────────────────────
  static const String tableUsers         = 'users';
  static const String tableDailyMessages = 'daily_messages';
  static const String tableUserStreaks   = 'user_streaks';

  // ── Edge function names ──────────────────────────────────────────────────────
  static const String fnGenerateMotivation = 'generate-motivation';
}
