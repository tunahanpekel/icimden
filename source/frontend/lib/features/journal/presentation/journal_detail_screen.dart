// lib/features/journal/presentation/journal_detail_screen.dart
//
// JournalDetailScreen — Full message view for a saved journal entry.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/services/motivation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/motivation_message.dart';
import '../../../shared/widgets/loading_overlay.dart';
import 'journal_screen.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

// Use the journal provider and find entry by ID
final _journalDetailProvider = FutureProvider.family
    .autoDispose<JournalEntry?, String>((ref, entryId) async {
  final entries = await ref.watch(journalProvider.future);
  try {
    return entries.firstWhere((e) => e.id == entryId);
  } catch (_) {
    return null;
  }
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = S.of(context);
    final entryAsync = ref.watch(_journalDetailProvider(entryId));

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Delete button
          if (entryAsync.valueOrNull != null)
            TextButton(
              onPressed: () async {
                final confirm = await _confirmDelete(context);
                if (confirm == true && context.mounted) {
                  await ref.read(motivationServiceProvider)
                      .unsaveMessage(entryId);
                  ref.invalidate(journalProvider);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: Text(s.journalDelete,
                  style: const TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: entryAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: S.of(context).errorGeneric),
        data: (entry) {
          if (entry == null) {
            return Center(child: Text(s.errorGeneric, style: AppTheme.bodyMedium));
          }

          final moodColor = AppTheme.moodColor(entry.mood);
          final moodEmoji = AppTheme.moodEmoji(entry.mood);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood + date row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: moodColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: moodColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(moodEmoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(s.moodLabel(entry.mood),
                              style: AppTheme.labelMedium.copyWith(color: moodColor)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('d MMMM y', locale.languageCode).format(entry.savedAt),
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Decorative quote mark
                Text(
                  '"',
                  style: AppTheme.displayLarge.copyWith(
                    color: moodColor.withValues(alpha: 0.2),
                    height: 0.8,
                    fontSize: 72,
                  ),
                ),
                const SizedBox(height: 8),

                // Full message
                Text(entry.message, style: AppTheme.messageText),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final s = S.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgMid,
        content: Text(s.journalDeleteConfirm, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.journalDelete,
                style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
