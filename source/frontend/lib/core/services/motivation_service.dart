// lib/core/services/motivation_service.dart
//
// Service for fetching AI motivation messages via Supabase Edge Function.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/motivation_message.dart';
import '../network/supabase_client.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final motivationServiceProvider = Provider<MotivationService>((ref) {
  return MotivationService(SupabaseClientService.client);
});

// ─── Service ──────────────────────────────────────────────────────────────────

class MotivationService {
  MotivationService(this._supabase);

  final SupabaseClient _supabase;

  /// Generate (or retrieve cached) today's motivation message.
  Future<MotivationMessage> generateMessage({
    required String mood,
    required String language,
  }) async {
    final response = await _supabase.functions.invoke(
      SupabaseClientService.fnGenerateMotivation,
      body: {
        'mood': mood,
        'language': language,
      },
    );

    if (response.status != 200) {
      final error = response.data?['error'] as String? ?? 'Unknown error';
      throw MotivationException(error, statusCode: response.status);
    }

    final data = response.data as Map<String, dynamic>;
    return MotivationMessage.fromJson(data);
  }

  /// Save a message to the journal (set is_saved = true).
  Future<void> saveMessage(String messageId) async {
    await _supabase
        .from(SupabaseClientService.tableDailyMessages)
        .update({'is_saved': true})
        .eq('id', messageId);
  }

  /// Remove a message from journal (set is_saved = false).
  Future<void> unsaveMessage(String messageId) async {
    await _supabase
        .from(SupabaseClientService.tableDailyMessages)
        .update({'is_saved': false})
        .eq('id', messageId);
  }

  /// Fetch all saved journal entries for the current user.
  Future<List<JournalEntry>> fetchJournal() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from(SupabaseClientService.tableDailyMessages)
        .select('id, message, mood, message_date, created_at')
        .eq('user_id', userId)
        .eq('is_saved', true)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the current user's streak data.
  Future<UserStreak> fetchStreak() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return UserStreak.empty();

    final data = await _supabase
        .from(SupabaseClientService.tableUserStreaks)
        .select('current_streak, longest_streak, last_activity')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return UserStreak.empty();
    return UserStreak.fromJson(data);
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class MotivationException implements Exception {
  MotivationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNetworkError => statusCode == null;
  bool get isAiError      => statusCode == 502;
  bool get isRateLimited  => statusCode == 429;

  @override
  String toString() => 'MotivationException($statusCode): $message';
}
