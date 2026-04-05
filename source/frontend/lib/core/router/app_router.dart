// lib/core/router/app_router.dart
//
// İçimden GoRouter setup.
// Routes: splash → onboarding → home (mood) | journal | settings | message

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_strings.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/mood/presentation/mood_screen.dart';
import '../../features/message/presentation/message_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/journal/presentation/journal_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

part 'app_router.g.dart';

// ─── Route paths ──────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const root       = '/';
  static const onboarding = '/onboarding';
  static const home       = '/home';
  static const message    = '/message';
  static const journal    = '/journal';
  static const journalDetail = '/journal/:id';
  static const settings   = '/settings';
}

// ─── Auth state stream ────────────────────────────────────────────────────────

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

// ─── Router ───────────────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _AuthChangeNotifier(ref);
  late final GoRouter router;

  ref.listen(authStateProvider, (_, next) {
    final event = next.valueOrNull?.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (event == AuthChangeEvent.signedIn) {
        router.go(AppRoutes.home);
      } else if (event == AuthChangeEvent.signedOut) {
        router.go(AppRoutes.onboarding);
      }
    });
  });

  router = GoRouter(
    initialLocation: AppRoutes.root,
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final goingTo = state.matchedLocation;

      const publicRoutes = {AppRoutes.root, AppRoutes.onboarding};

      if (!isAuthenticated && !publicRoutes.contains(goingTo)) {
        return AppRoutes.onboarding;
      }
      if (isAuthenticated && goingTo == AppRoutes.onboarding) {
        return AppRoutes.home;
      }
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) {
          final session = Supabase.instance.client.auth.currentSession;
          return session != null ? AppRoutes.home : AppRoutes.onboarding;
        },
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const MoodScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            name: 'journal',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const JournalScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'journalDetail',
                pageBuilder: (context, state) => _slideUpTransition(
                  state: state,
                  child: JournalDetailScreen(entryId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _fadeTransition(
              state: state,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.message,
        name: 'message',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _slideUpTransition(
            state: state,
            child: MessageScreen(
              mood:     extra?['mood'] as String? ?? 'happy',
              language: extra?['language'] as String? ?? 'tr',
            ),
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF1A1028),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFE88A8A)),
            const SizedBox(height: 16),
            Text(S.of(context).commonPageNotFound,
                style: const TextStyle(color: Color(0xFFF5EEF8), fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(S.of(context).commonGoHome),
            ),
          ],
        ),
      ),
    ),
  );

  return router;
}

// ─── Transition helpers ───────────────────────────────────────────────────────

CustomTransitionPage<void> _slideUpTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// ─── Auth change listenable ───────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, next) {
      notifyListeners();
    });
  }
}
