// lib/features/mood/presentation/mood_screen.dart
//
// MoodScreen — Main home screen. User selects mood and taps CTA to get message.
// Shows streak badge in AppBar. Handles ad → message navigation flow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/motivation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/motivation_message.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final selectedMoodProvider = StateProvider<String?>((ref) => null);

final streakProvider = FutureProvider.autoDispose<UserStreak>((ref) async {
  return ref.read(motivationServiceProvider).fetchStreak();
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  bool _isLoading = false;

  Future<void> _onGetMessage() async {
    final mood = ref.read(selectedMoodProvider);
    if (mood == null) return;

    final language = ref.read(localeProvider).languageCode;

    setState(() => _isLoading = true);

    // Show interstitial ad, then navigate to message screen
    await AdService.instance.showInterstitialBeforeMessage(
      onComplete: () async {
        if (!mounted) return;
        setState(() => _isLoading = false);
        context.push(AppRoutes.message, extra: {
          'mood': mood,
          'language': language,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final selectedMood = ref.watch(selectedMoodProvider);
    // select: only rebuild when currentStreak value changes, not on every UserStreak field update
    final currentStreak = ref.watch(
      streakProvider.select((async) => async.valueOrNull?.currentStreak),
    );

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'İçimden',
                    style: AppTheme.headlineMedium.copyWith(
                      foreground: Paint()
                        ..shader = AppTheme.warmGradient.createShader(
                          const Rect.fromLTWH(0, 0, 120, 30),
                        ),
                    ),
                  ),
                  const Spacer(),
                  // Streak badge
                  if (currentStreak != null && currentStreak > 0)
                    _StreakBadge(streak: currentStreak),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.settings),
                    icon: const Icon(Icons.settings_rounded, color: AppTheme.textSecondary),
                    iconSize: 22,
                    tooltip: s.tabSettings,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // ── Title ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(s.moodScreenTitle,
                      style: AppTheme.headlineLarge,
                      textAlign: TextAlign.center)
                      .animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(s.moodScreenSubtitle,
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center)
                      .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Mood Grid ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Row 1: tired | anxious | happy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MoodCard(mood: 'tired', isSelected: selectedMood == 'tired'),
                      _MoodCard(mood: 'anxious', isSelected: selectedMood == 'anxious'),
                      _MoodCard(mood: 'happy', isSelected: selectedMood == 'happy'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2 (centered): sad | motivated
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MoodCard(mood: 'sad', isSelected: selectedMood == 'sad'),
                      const SizedBox(width: 12),
                      _MoodCard(mood: 'motivated', isSelected: selectedMood == 'motivated'),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── CTA ──────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: selectedMood != null ? 1.0 : 0.4,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_isLoading || selectedMood == null) ? null : _onGetMessage,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(s.moodGetMessage,
                                style: AppTheme.labelLarge.copyWith(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MoodCard ─────────────────────────────────────────────────────────────────

class _MoodCard extends ConsumerWidget {
  const _MoodCard({required this.mood, required this.isSelected});

  final String mood;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final color = AppTheme.moodColor(mood);
    final emoji = AppTheme.moodEmoji(mood);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(selectedMoodProvider.notifier).state = mood;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.bgMid,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.bgBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        transform: isSelected
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              s.moodLabel(mood),
              style: AppTheme.labelMedium.copyWith(
                color: isSelected ? color : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── StreakBadge ──────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8735A), Color(0xFFF5A97F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: AppTheme.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
