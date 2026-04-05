// lib/features/message/presentation/message_screen.dart
//
// MessageScreen — Shows AI-generated motivation message with typewriter effect.
// Allows saving to journal.

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/services/motivation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/motivation_message.dart';
import '../../../shared/widgets/loading_overlay.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _messageProvider = FutureProvider.family
    .autoDispose<MotivationMessage, ({String mood, String language})>(
  (ref, args) async {
    final service = ref.read(motivationServiceProvider);
    return service.generateMessage(mood: args.mood, language: args.language);
  },
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key, required this.mood, required this.language});

  final String mood;
  final String language;

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  // Typewriter state
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typewriterTimer;

  bool _isSaving = false;
  bool _wasSaved = false;

  void _startTypewriter(String fullText) {
    _typewriterTimer?.cancel();
    _displayedText = '';
    _charIndex = 0;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (_charIndex < fullText.length) {
        if (mounted) {
          setState(() {
            _displayedText = fullText.substring(0, _charIndex + 1);
            _charIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveToJournal(MotivationMessage message) async {
    if (_isSaving || _wasSaved) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(motivationServiceProvider);
      await service.saveMessage(message.id);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _wasSaved = true;
        });
        // Invalidate journal cache
        // ref.invalidate(journalProvider); // if needed
      }
      // Analytics
      FirebaseAnalytics.instance.logEvent(
        name: 'message_saved',
        parameters: {
          'mood': message.mood,
          'streak_day': message.streak?.current ?? 0,
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).errorGeneric),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final messageAsync = ref.watch(
      _messageProvider((mood: widget.mood, language: widget.language)),
    );

    // Start typewriter when data arrives
    ref.listen(
      _messageProvider((mood: widget.mood, language: widget.language)),
      (prev, next) {
        next.whenData((msg) {
          if (prev?.valueOrNull?.message != msg.message) {
            _startTypewriter(msg.message);
            // Analytics
            FirebaseAnalytics.instance.logEvent(
              name: 'message_viewed',
              parameters: {'mood': widget.mood, 'language': widget.language},
            );
            // Check for streak milestone
            if (msg.streak?.isMilestone == true && msg.streak!.current > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showStreakCelebration(context, msg.streak!.current);
              });
            }
          }
        });
      },
    );

    final moodColor = AppTheme.moodColor(widget.mood);
    final moodEmoji = AppTheme.moodEmoji(widget.mood);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _MoodPill(mood: widget.mood, emoji: moodEmoji, color: moodColor, label: s.moodLabel(widget.mood)),
        centerTitle: false,
      ),
      body: messageAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.messageGenerating,
                  style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textHint,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 32),
              const MessageShimmer(),
            ],
          ),
        ),
        error: (e, _) {
          final errorMsg = e is MotivationException && e.isAiError
              ? s.errorAiTimeout
              : s.errorGeneric;
          return ErrorView(
            message: errorMsg,
            onRetry: () => ref.invalidate(
              _messageProvider((mood: widget.mood, language: widget.language)),
            ),
          );
        },
        data: (message) => Column(
          children: [
            // ── Message area ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative quotation mark
                    Text(
                      '"',
                      style: AppTheme.displayLarge.copyWith(
                        color: moodColor.withValues(alpha: 0.3),
                        height: 0.8,
                        fontSize: 72,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Message text with typewriter
                    Text(
                      _displayedText,
                      style: AppTheme.messageText,
                    ),

                    const SizedBox(height: 24),

                    // Date label
                    Text(
                      DateFormat('d MMMM y', widget.language).format(DateTime.now()),
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.bgBorder, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (_wasSaved || message.isSaved)
                      ? OutlinedButton.icon(
                          key: const ValueKey('saved'),
                          onPressed: null,
                          icon: const Icon(Icons.check_rounded, color: AppTheme.success, size: 18),
                          label: Text(s.messageSaved,
                              style: AppTheme.labelLarge.copyWith(color: AppTheme.success)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.success),
                          ),
                        )
                      : ElevatedButton.icon(
                          key: const ValueKey('save'),
                          onPressed: _isSaving ? null : () => _saveToJournal(message),
                          icon: _isSaving
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.bookmark_add_rounded, size: 18),
                          label: Text(s.messageSaveToJournal),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStreakCelebration(BuildContext context, int days) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StreakCelebrationSheet(days: days),
    );
  }
}

// ─── MoodPill ─────────────────────────────────────────────────────────────────

class _MoodPill extends StatelessWidget {
  const _MoodPill({
    required this.mood,
    required this.emoji,
    required this.color,
    required this.label,
  });

  final String mood;
  final String emoji;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── StreakCelebrationSheet ───────────────────────────────────────────────────

class _StreakCelebrationSheet extends ConsumerWidget {
  const _StreakCelebrationSheet({required this.days});
  final int days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final lang = ref.read(localeProvider).languageCode;
    final milestoneMessages = {
      3: lang == 'tr'
          ? '3 gün boyunca buraya geldin. Bu küçük ama gerçek bir adım.'
          : lang == 'es' ? '3 días seguidos. Pequeño, pero real.'
          : lang == 'de' ? '3 Tage in Folge. Klein, aber echt.'
          : lang == 'fr' ? '3 jours de suite. Petit, mais réel.'
          : lang == 'pt' ? '3 dias seguidos. Pequeno, mas real.'
          : '3 days in a row. Small, but real.',
      7: lang == 'tr'
          ? 'Tam bir hafta. Bir alışkanlık artık seninle.'
          : lang == 'es' ? 'Una semana completa. Un hábito ha echado raíces.'
          : lang == 'de' ? 'Eine ganze Woche. Eine Gewohnheit hat sich verwurzelt.'
          : lang == 'fr' ? 'Une semaine entière. Une habitude a pris racine.'
          : lang == 'pt' ? 'Uma semana inteira. Um hábito tomou raiz.'
          : 'One full week. A habit has taken root.',
      14: lang == 'tr'
          ? 'İki hafta! Tutarlılık, değişimin sessiz tohumudur.'
          : lang == 'es' ? '¡Dos semanas! La constancia es la semilla silenciosa del cambio.'
          : lang == 'de' ? 'Zwei Wochen! Konsequenz ist der stille Samen des Wandels.'
          : lang == 'fr' ? 'Deux semaines ! La constance est la graine silencieuse du changement.'
          : lang == 'pt' ? 'Duas semanas! A consistência é a semente silenciosa da mudança.'
          : 'Two weeks. Consistency is the quiet seed of change.',
      30: lang == 'tr'
          ? '30 gün. Bu artık senin bir parçan.'
          : lang == 'es' ? '30 días. Esto ya es parte de quien eres.'
          : lang == 'de' ? '30 Tage. Das ist jetzt ein Teil von dir.'
          : lang == 'fr' ? '30 jours. C\'est désormais une partie de qui tu es.'
          : lang == 'pt' ? '30 dias. Isso agora é parte de quem você é.'
          : '30 days. This is part of who you are now.',
    };

    final body = milestoneMessages[days] ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMid,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: const TextStyle(fontSize: 56))
              .animate(onPlay: (c) => c.repeat(period: 1.5.seconds))
              .scaleXY(begin: 1.0, end: 1.1)
              .then()
              .scaleXY(begin: 1.1, end: 1.0),
          const SizedBox(height: 16),
          Text(s.streakCelebrationTitle(days),
              style: AppTheme.displayMedium,
              textAlign: TextAlign.center),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(body,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.streakCelebrationCta),
            ),
          ),
        ],
      ),
    );
  }

}
