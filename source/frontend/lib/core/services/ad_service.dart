// lib/core/services/ad_service.dart
//
// AdMob service for İçimden.
// Handles interstitial (before message reveal) and banner (journal screen).

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';

class AdService {
  AdService._();

  static final AdService _instance = AdService._();
  static AdService get instance => _instance;

  // ── Ad state ─────────────────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  // Frequency cap: track last shown time
  DateTime? _lastInterstitialShown;
  static const Duration _interstitialCooldown = Duration(hours: 24);

  // ── Ad Unit IDs ───────────────────────────────────────────────────────────────
  static String get _interstitialAdUnitId {
    if (kDebugMode) {
      // Test IDs
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return Platform.isIOS
        ? AppConfig.iosInterstitialAdUnitId
        : AppConfig.androidInterstitialAdUnitId;
  }

  static String get _bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return Platform.isIOS
        ? AppConfig.iosBannerAdUnitId
        : AppConfig.androidBannerAdUnitId;
  }

  /// Public accessor used by JournalScreen to construct its own BannerAd.
  static String get journalBannerAdUnitId => _bannerAdUnitId;

  // ── Initialization ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('AdMob initialized');
      AdService.instance._loadInterstitial();
    } catch (e) {
      debugPrint('AdMob init failed (non-fatal): $e');
    }
  }

  // ── Interstitial ──────────────────────────────────────────────────────────────
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('Interstitial ad loaded');
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          debugPrint('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show interstitial ad before message reveal.
  /// [onComplete] is called after ad dismissal (or immediately if no ad loaded).
  Future<void> showInterstitialBeforeMessage({
    required Function() onComplete,
  }) async {
    // Check frequency cap
    if (_lastInterstitialShown != null) {
      final timeSinceLast = DateTime.now().difference(_lastInterstitialShown!);
      if (timeSinceLast < _interstitialCooldown) {
        debugPrint('Interstitial skipped (cooldown): ${timeSinceLast.inMinutes}m ago');
        onComplete();
        return;
      }
    }

    if (!_isInterstitialLoaded || _interstitialAd == null) {
      debugPrint('Interstitial not loaded, proceeding without ad');
      onComplete();
      _loadInterstitial(); // Preload for next time
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        _lastInterstitialShown = DateTime.now();
        _loadInterstitial(); // Preload next
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        debugPrint('Interstitial show failed: ${error.message}');
        _loadInterstitial();
        onComplete();
      },
    );

    await _interstitialAd!.show();
  }

  // ── Banner ────────────────────────────────────────────────────────────────────

  /// Create a new banner ad for the journal screen.
  /// Caller is responsible for disposing.
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
  }
}
