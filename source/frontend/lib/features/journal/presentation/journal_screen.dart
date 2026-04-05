// lib/features/journal/presentation/journal_screen.dart
//
// JournalScreen — Saved messages list with AdMob banner at bottom.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/motivation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/motivation_message.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final journalProvider = FutureProvider.autoDispose<List<JournalEntry>>((ref) async {
  return ref.read(motivationServiceProvider).fetchJournal();
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdService.journalBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await ref.read(motivationServiceProvider).unsaveMessage(id);
      ref.invalidate(journalProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).errorGeneric),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = S.of(context);
    final journalAsync = ref.watch(journalProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text(s.journalTitle),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Journal list ──────────────────────────────────────────────────
          Expanded(
            child: journalAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: S.of(context).errorGeneric),
              data: (entries) {
                if (entries.isEmpty) {
                  return EmptyView(
                    emoji: '📖',
                    title: s.journalEmptyTitle,
                    subtitle: s.journalEmptySubtitle,
                    action: () => context.go(AppRoutes.home),
                    actionLabel: s.moodGetMessage,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _JournalEntryCard(
                      entry: entries[index],
                      languageCode: locale.languageCode,
                      onTap: () => context.push('/journal/${entries[index].id}'),
                      onDelete: () async {
                        final confirm = await _confirmDelete(context);
                        if (confirm == true) {
                          await _deleteEntry(entries[index].id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ── Banner Ad ─────────────────────────────────────────────────────
          if (_bannerAdLoaded && _bannerAd != null)
            SafeArea(
              top: false,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          else
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final s = S.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

// ─── JournalEntryCard ─────────────────────────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
    required this.languageCode,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final moodColor = AppTheme.moodColor(entry.mood);
    final moodEmoji = AppTheme.moodEmoji(entry.mood);
    final dateStr = DateFormat('d MMM', languageCode).format(entry.savedAt);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // We handle deletion manually via provider
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgMid,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bgBorder),
          ),
          child: Row(
            children: [
              // Mood emoji
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(moodEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),

              // Message preview + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr,
                        style: AppTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(entry.previewText,
                        style: AppTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
