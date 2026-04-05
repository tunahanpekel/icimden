// lib/features/onboarding/presentation/onboarding_screen.dart
//
// İçimden Onboarding — 3-slide intro + Google/Apple sign-in

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _isSigningIn = false;

  static const _deepLinkScheme = '${AppConfig.packageId}://login-callback';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _deepLinkScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Router auto-redirects on auth state change
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${S.of(context).commonError}: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isSigningIn = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _deepLinkScheme,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${S.of(context).commonError}: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final s = S.of(context);

    final pages = [
      _OnboardingPageData(
        emoji: '💫',
        title: s.onboarding1Title,
        body: s.onboarding1Body,
        gradientColors: const [Color(0xFF1A1028), Color(0xFF241535)],
      ),
      _OnboardingPageData(
        emoji: '🌙',
        title: s.onboarding2Title,
        body: s.onboarding2Body,
        gradientColors: const [Color(0xFF1F1030), Color(0xFF241535)],
      ),
      _OnboardingPageData(
        emoji: '🌱',
        title: s.onboarding3Title,
        body: s.onboarding3Body,
        gradientColors: const [Color(0xFF221535), Color(0xFF1A1028)],
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: pages.length,
            itemBuilder: (context, i) => _OnboardingPageWidget(page: pages[i]),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _page == i ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _page == i ? AppTheme.primary : AppTheme.bgBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    if (_page < pages.length - 1) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                          child: Text(s.commonContinue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _pageController.animateToPage(
                          pages.length - 1,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                        child: Text(s.onboardingSkip,
                            style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                      ),
                    ] else ...[
                      // Google Sign-In
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSigningIn ? null : _signInWithGoogle,
                          icon: _isSigningIn
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login_rounded, size: 20),
                          label: Text(_isSigningIn ? '...' : s.authSignInGoogle),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Apple Sign-In
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _isSigningIn ? null : _signInWithApple,
                          icon: const Icon(Icons.apple_rounded, size: 20),
                          label: Text(s.authSignInApple),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: const BorderSide(color: AppTheme.bgBorder, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legal links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse(AppConfig.privacyUrl)),
                            child: Text(s.settingsPrivacy,
                                style: AppTheme.labelSmall.copyWith(color: AppTheme.textHint)),
                          ),
                          Text(' · ', style: AppTheme.labelSmall.copyWith(color: AppTheme.textHint)),
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse(AppConfig.termsUrl)),
                            child: Text(s.settingsTerms,
                                style: AppTheme.labelSmall.copyWith(color: AppTheme.textHint)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.body,
    required this.gradientColors,
  });
  final String emoji;
  final String title;
  final String body;
  final List<Color> gradientColors;
}

// ─── Page widget ──────────────────────────────────────────────────────────────

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});
  final _OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 220),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.emoji, style: const TextStyle(fontSize: 72))
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 32),
              Text(page.title,
                  style: AppTheme.displayMedium,
                  textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 16),
              Text(page.body,
                  style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary, height: 1.6),
                  textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 250.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
