// lib/shared/widgets/main_scaffold.dart
//
// Shell scaffold with bottom navigation bar (Home | Journal | Settings)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final s = S.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.journal)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.settings)) {
      currentIndex = 2;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgMid,
          border: Border(
            top: BorderSide(color: AppTheme.bgBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: AppTheme.bgMid,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textHint,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0: context.go(AppRoutes.home);
              case 1: context.go(AppRoutes.journal);
              case 2: context.go(AppRoutes.settings);
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: s.tabHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_rounded),
              label: s.tabJournal,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: s.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
