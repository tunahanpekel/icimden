// lib/core/l10n/app_strings.dart
//
// İçimden — Localization (tr, en, es, de, fr, pt)
// Usage: S.of(context).someKey
// In ConsumerWidget: ref.watch(localeProvider) to rebuild on locale change

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Locale Provider ──────────────────────────────────────────────────────────

const _kLangKey = 'app_language';
const _supportedLangs = ['tr', 'en', 'es', 'de', 'fr', 'pt'];

String _deviceLang() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return _supportedLangs.contains(code) ? code : 'tr';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _load();
    return Locale(_deviceLang());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);
  }

  bool get isTurkish    => state.languageCode == 'tr';
  bool get isSpanish    => state.languageCode == 'es';
  bool get isGerman     => state.languageCode == 'de';
  bool get isFrench     => state.languageCode == 'fr';
  bool get isPortuguese => state.languageCode == 'pt';
}

// ─── String lookup ────────────────────────────────────────────────────────────

class S {
  const S._(this._locale);
  final Locale _locale;
  String get _lang => _locale.languageCode;
  bool get _tr => _lang == 'tr';
  bool get _es => _lang == 'es';
  bool get _de => _lang == 'de';
  bool get _fr => _lang == 'fr';
  bool get _pt => _lang == 'pt';

  static S of(BuildContext context) => S._(Localizations.localeOf(context));

  // ── Common ───────────────────────────────────────────────────────────────────
  String get commonOk         => _tr ? 'Tamam'       : _es ? 'Aceptar'   : _de ? 'OK'         : _fr ? 'OK'        : _pt ? 'OK'         : 'OK';
  String get commonCancel     => _tr ? 'İptal'       : _es ? 'Cancelar'  : _de ? 'Abbrechen'  : _fr ? 'Annuler'   : _pt ? 'Cancelar'   : 'Cancel';
  String get commonSave       => _tr ? 'Kaydet'      : _es ? 'Guardar'   : _de ? 'Speichern'  : _fr ? 'Enregistrer' : _pt ? 'Salvar'   : 'Save';
  String get commonContinue   => _tr ? 'Devam Et'    : _es ? 'Continuar' : _de ? 'Weiter'     : _fr ? 'Continuer' : _pt ? 'Continuar'  : 'Continue';
  String get commonBack       => _tr ? 'Geri'        : _es ? 'Atrás'     : _de ? 'Zurück'     : _fr ? 'Retour'    : _pt ? 'Voltar'     : 'Back';
  String get commonLoading    => _tr ? 'Yükleniyor'  : _es ? 'Cargando'  : _de ? 'Laden...'   : _fr ? 'Chargement': _pt ? 'Carregando' : 'Loading...';
  String get commonError      => _tr ? 'Hata'        : _es ? 'Error'     : _de ? 'Fehler'     : _fr ? 'Erreur'    : _pt ? 'Erro'       : 'Error';
  String get commonRetry      => _tr ? 'Tekrar Dene' : _es ? 'Reintentar': _de ? 'Wiederholen': _fr ? 'Réessayer' : _pt ? 'Tentar novamente': 'Try Again';
  String get commonPageNotFound => _tr ? 'Sayfa Bulunamadı': _es ? 'Página no encontrada': _de ? 'Seite nicht gefunden': _fr ? 'Page introuvable': _pt ? 'Página não encontrada': 'Page Not Found';
  String get commonGoHome     => _tr ? 'Ana Sayfaya Dön': _es ? 'Ir al inicio': _de ? 'Zur Startseite': _fr ? 'Aller à l\'accueil': _pt ? 'Ir para o início': 'Go Home';

  // ── Navigation ───────────────────────────────────────────────────────────────
  String get tabHome     => _tr ? 'Ana Sayfa' : _es ? 'Inicio'  : _de ? 'Startseite'    : _fr ? 'Accueil'   : _pt ? 'Início'       : 'Home';
  String get tabJournal  => _tr ? 'Günlüğüm'  : _es ? 'Diario'  : _de ? 'Tagebuch'      : _fr ? 'Journal'   : _pt ? 'Diário'       : 'Journal';
  String get tabSettings => _tr ? 'Ayarlar'   : _es ? 'Ajustes' : _de ? 'Einstellungen' : _fr ? 'Paramètres': _pt ? 'Configurações' : 'Settings';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  String get authSignIn       => _tr ? 'Giriş Yap'  : _es ? 'Iniciar sesión': _de ? 'Anmelden'   : _fr ? 'Se connecter'    : _pt ? 'Entrar'        : 'Sign In';
  String get authSignOut      => _tr ? 'Çıkış Yap'  : _es ? 'Cerrar sesión' : _de ? 'Abmelden'   : _fr ? 'Se déconnecter' : _pt ? 'Sair'           : 'Sign Out';
  String get authSignInGoogle => _tr ? 'Google ile Giriş Yap': _es ? 'Continuar con Google': _de ? 'Mit Google anmelden': _fr ? 'Continuer avec Google': _pt ? 'Entrar com Google': 'Continue with Google';
  String get authSignInApple  => _tr ? 'Apple ile Giriş Yap' : _es ? 'Continuar con Apple' : _de ? 'Mit Apple anmelden' : _fr ? 'Continuer avec Apple' : _pt ? 'Entrar com Apple' : 'Continue with Apple';

  // ── Settings ─────────────────────────────────────────────────────────────────
  String get settingsLanguage      => _tr ? 'Dil'         : _es ? 'Idioma'        : _de ? 'Sprache'    : _fr ? 'Langue'     : _pt ? 'Idioma'       : 'Language';
  String get settingsAccount       => _tr ? 'Hesap'       : _es ? 'Cuenta'        : _de ? 'Konto'      : _fr ? 'Compte'     : _pt ? 'Conta'        : 'Account';
  String get settingsDeleteAccount => _tr ? 'Hesabı Sil'  : _es ? 'Eliminar cuenta': _de ? 'Konto löschen': _fr ? 'Supprimer le compte': _pt ? 'Excluir conta': 'Delete Account';
  String get settingsPrivacy       => _tr ? 'Gizlilik Politikası': _es ? 'Política de privacidad': _de ? 'Datenschutzrichtlinie': _fr ? 'Politique de confidentialité': _pt ? 'Política de privacidade': 'Privacy Policy';
  String get settingsTerms         => _tr ? 'Kullanım Koşulları': _es ? 'Términos de uso': _de ? 'Nutzungsbedingungen': _fr ? 'Conditions d\'utilisation': _pt ? 'Termos de uso': 'Terms of Use';
  String get settingsNotifications => _tr ? 'Bildirimler' : _es ? 'Notificaciones': _de ? 'Benachrichtigungen': _fr ? 'Notifications': _pt ? 'Notificações': 'Notifications';
  String get settingsNotifTime     => _tr ? 'Bildirim Saati': _es ? 'Hora de notificación': _de ? 'Benachrichtigungszeit': _fr ? 'Heure de notification': _pt ? 'Hora da notificação': 'Notification Time';
  String get settingsLegal         => _tr ? 'Yasal'         : _es ? 'Legal'          : _de ? 'Rechtliches'  : _fr ? 'Mentions légales': _pt ? 'Legal'         : 'Legal';
  String get deleteAccountConfirmBody => _tr
    ? 'Tüm verilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.'
    : _es ? 'Todos tus datos serán eliminados permanentemente. Esta acción no se puede deshacer.'
    : _de ? 'Alle deine Daten werden dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.'
    : _fr ? 'Toutes tes données seront supprimées définitivement. Cette action est irréversible.'
    : _pt ? 'Todos os seus dados serão excluídos permanentemente. Esta ação não pode ser desfeita.'
    : 'All your data will be permanently deleted. This action cannot be undone.';

  // ── Onboarding ────────────────────────────────────────────────────────────────
  String get onboardingGetStarted  => _tr ? 'Başla'       : _es ? 'Comenzar'  : _de ? 'Loslegen'    : _fr ? 'Commencer' : _pt ? 'Começar'     : 'Get Started';
  String get onboardingSkip        => _tr ? 'Geç'         : _es ? 'Omitir'    : _de ? 'Überspringen': _fr ? 'Passer'    : _pt ? 'Pular'       : 'Skip';

  String get onboarding1Title      => _tr ? 'Her gün, sadece senin için'
    : _es ? 'Cada día, solo para ti'
    : _de ? 'Jeden Tag, nur für dich'
    : _fr ? 'Chaque jour, rien que pour toi'
    : _pt ? 'Cada dia, só para você'
    : 'Every day, just for you';

  String get onboarding1Body       => _tr ? 'Bugün nasıl hissettiğine bağlı, yapay zeka sana özel bir mesaj yazar.'
    : _es ? 'Según cómo te sientas hoy, la IA escribe un mensaje personal para ti.'
    : _de ? 'Basierend auf deinen Gefühlen heute schreibt KI dir eine persönliche Nachricht.'
    : _fr ? 'Selon ton humeur du jour, l\'IA écrit un message personnel pour toi.'
    : _pt ? 'Com base em como você se sente hoje, a IA escreve uma mensagem pessoal para você.'
    : 'Based on how you feel today, AI writes you a personal message.';

  String get onboarding2Title      => _tr ? 'Ruh halini seç, mesajını al'
    : _es ? 'Elige tu estado de ánimo, recibe tu mensaje'
    : _de ? 'Wähle deine Stimmung, erhalte deine Nachricht'
    : _fr ? 'Choisis ton humeur, reçois ton message'
    : _pt ? 'Escolha seu humor, receba sua mensagem'
    : 'Choose your mood, get your message';

  String get onboarding2Body       => _tr ? 'Yorgun mu, mutlu mu, kaygılı mı? İki saniyede söyle — mesajın anında gelsin.'
    : _es ? '¿Cansado, feliz, ansioso? Díselo en segundos — tu mensaje llega al instante.'
    : _de ? 'Müde, glücklich, ängstlich? Sag es in Sekunden — deine Nachricht kommt sofort.'
    : _fr ? 'Fatigué, heureux, anxieux? Dis-le en secondes — ton message arrive instantanément.'
    : _pt ? 'Cansado, feliz, ansioso? Diga em segundos — sua mensagem chega na hora.'
    : 'Tired, happy, anxious? Tell us in seconds — your message arrives instantly.';

  String get onboarding3Title      => _tr ? 'Bugün başla, yarına taşı'
    : _es ? 'Empieza hoy, llévalo contigo'
    : _de ? 'Fang heute an'
    : _fr ? 'Commence aujourd\'hui'
    : _pt ? 'Comece hoje'
    : 'Start today, carry it forward';

  String get onboarding3Body       => _tr ? 'Beğendiğin mesajları günlüğüne kaydet. Serini koru. Rutinin burada başlıyor.'
    : _es ? 'Guarda mensajes en tu diario. Mantén tu racha. Tu rutina empieza aquí.'
    : _de ? 'Speichere Nachrichten in deinem Tagebuch. Halte deinen Streak. Deine Routine beginnt hier.'
    : _fr ? 'Sauvegarde les messages dans ton journal. Maintiens ta série. Ta routine commence ici.'
    : _pt ? 'Salve mensagens no seu diário. Mantenha sua sequência. Sua rotina começa aqui.'
    : 'Save messages that resonate to your journal. Keep your streak. Your routine starts here.';

  // ── Mood Screen ───────────────────────────────────────────────────────────────
  String get moodScreenTitle       => _tr ? 'Bugün nasıl hissediyorsun?'
    : _es ? '¿Cómo te sientes hoy?'
    : _de ? 'Wie fühlst du dich heute?'
    : _fr ? 'Comment te sens-tu aujourd\'hui?'
    : _pt ? 'Como você está se sentindo hoje?'
    : 'How are you feeling today?';

  String get moodScreenSubtitle    => _tr ? 'Ruh halini seç, mesajını al'
    : _es ? 'Elige tu estado de ánimo, recibe tu mensaje'
    : _de ? 'Wähle deine Stimmung, erhalte deine Nachricht'
    : _fr ? 'Choisis ton humeur, reçois ton message'
    : _pt ? 'Escolha seu humor, receba sua mensagem'
    : 'Choose your mood, get your message';

  String get moodGetMessage        => _tr ? 'Mesajımı Al'
    : _es ? 'Obtener Mensaje'
    : _de ? 'Meine Nachricht'
    : _fr ? 'Mon Message'
    : _pt ? 'Minha Mensagem'
    : 'Get My Message';

  String get moodAlreadyUsed       => _tr ? 'Bugün zaten mesajını aldın'
    : _es ? 'Ya recibiste tu mensaje de hoy'
    : _de ? 'Du hast heute bereits deine Nachricht erhalten'
    : _fr ? 'Tu as déjà reçu ton message aujourd\'hui'
    : _pt ? 'Você já recebeu sua mensagem hoje'
    : 'You already got today\'s message';

  String get moodNextTomorrow      => _tr ? 'Yarın yeni mesajın olacak'
    : _es ? 'Tu próximo mensaje mañana'
    : _de ? 'Deine nächste Nachricht morgen'
    : _fr ? 'Ton prochain message demain'
    : _pt ? 'Sua próxima mensagem amanhã'
    : 'Your next message tomorrow';

  // Mood labels
  String get moodTired             => _tr ? 'Yorgunum'             : _es ? 'Cansado/a'   : _de ? 'Müde'        : _fr ? 'Fatigué(e)'   : _pt ? 'Cansado/a'   : 'Tired';
  String get moodAnxious           => _tr ? 'Kaygılıyım'           : _es ? 'Ansioso/a'   : _de ? 'Ängstlich'   : _fr ? 'Anxieux/se'   : _pt ? 'Ansioso/a'   : 'Anxious';
  String get moodHappy             => _tr ? 'Mutluyum'             : _es ? 'Feliz'        : _de ? 'Glücklich'   : _fr ? 'Heureux/se'   : _pt ? 'Feliz'       : 'Happy';
  String get moodSad               => _tr ? 'Üzgünüm'             : _es ? 'Triste'       : _de ? 'Traurig'     : _fr ? 'Triste'       : _pt ? 'Triste'      : 'Sad';
  String get moodMotivated         => _tr ? 'Motive hissediyorum' : _es ? 'Motivado/a'   : _de ? 'Motiviert'   : _fr ? 'Motivé(e)'    : _pt ? 'Motivado/a'  : 'Motivated';

  String moodLabel(String mood) {
    return switch (mood) {
      'tired'     => moodTired,
      'anxious'   => moodAnxious,
      'happy'     => moodHappy,
      'sad'       => moodSad,
      'motivated' => moodMotivated,
      _           => mood,
    };
  }

  // ── Message Screen ────────────────────────────────────────────────────────────
  String get messageGenerating     => _tr ? 'Senin için düşünüyor...'
    : _es ? 'Pensando para ti...'
    : _de ? 'Denke für dich...'
    : _fr ? 'Je pense pour toi...'
    : _pt ? 'Pensando para você...'
    : 'Thinking for you...';

  String get messageSaveToJournal  => _tr ? 'Günlüğe Kaydet'
    : _es ? 'Guardar en Diario'
    : _de ? 'Im Tagebuch speichern'
    : _fr ? 'Sauvegarder au Journal'
    : _pt ? 'Salvar no Diário'
    : 'Save to Journal';

  String get messageSaved          => _tr ? 'Kaydedildi ✓'
    : _es ? 'Guardado ✓'
    : _de ? 'Gespeichert ✓'
    : _fr ? 'Sauvegardé ✓'
    : _pt ? 'Salvo ✓'
    : 'Saved ✓';

  String get messageToday          => _tr ? 'Bugün'
    : _es ? 'Hoy'
    : _de ? 'Heute'
    : _fr ? 'Aujourd\'hui'
    : _pt ? 'Hoje'
    : 'Today';

  // ── Journal Screen ────────────────────────────────────────────────────────────
  String get journalTitle          => _tr ? 'Günlüğüm'
    : _es ? 'Mi Diario'
    : _de ? 'Mein Tagebuch'
    : _fr ? 'Mon Journal'
    : _pt ? 'Meu Diário'
    : 'My Journal';

  String get journalEmptyTitle     => _tr ? 'Henüz kaydedilmiş mesaj yok'
    : _es ? 'Aún no hay mensajes guardados'
    : _de ? 'Noch keine gespeicherten Nachrichten'
    : _fr ? 'Aucun message sauvegardé'
    : _pt ? 'Nenhuma mensagem salva ainda'
    : 'No saved messages yet';

  String get journalEmptySubtitle  => _tr ? 'Seni etkileyen mesajları buraya kaydet.'
    : _es ? 'Guarda aquí los mensajes que te resuenen.'
    : _de ? 'Speichere hier Nachrichten, die dich berühren.'
    : _fr ? 'Sauvegarde ici les messages qui te touchent.'
    : _pt ? 'Salve aqui as mensagens que ressoarem com você.'
    : 'Save messages that resonate with you here.';

  String get journalDelete         => _tr ? 'Sil'
    : _es ? 'Eliminar'
    : _de ? 'Löschen'
    : _fr ? 'Supprimer'
    : _pt ? 'Excluir'
    : 'Delete';

  String get journalDeleteConfirm  => _tr ? 'Bu mesajı günlükten silmek istediğinden emin misin?'
    : _es ? '¿Estás seguro de eliminar este mensaje del diario?'
    : _de ? 'Möchtest du diese Nachricht aus dem Tagebuch löschen?'
    : _fr ? 'Veux-tu vraiment supprimer ce message du journal?'
    : _pt ? 'Tem certeza que quer excluir esta mensagem do diário?'
    : 'Are you sure you want to delete this message from your journal?';

  // ── Streak ────────────────────────────────────────────────────────────────────
  String get streakLabel           => _tr ? 'günlük seri'
    : _es ? 'días seguidos'
    : _de ? 'Tage in Folge'
    : _fr ? 'jours consécutifs'
    : _pt ? 'dias consecutivos'
    : 'day streak';

  String streakCelebrationTitle(int days) => _tr ? '$days Günlük Seri!'
    : _es ? '¡$days días seguidos!'
    : _de ? '$days Tage in Folge!'
    : _fr ? '$days jours consécutifs!'
    : _pt ? '$days dias consecutivos!'
    : '$days Day Streak!';

  String get streakCelebrationCta  => _tr ? 'Harika!' : _es ? '¡Genial!' : _de ? 'Toll!' : _fr ? 'Super!' : _pt ? 'Ótimo!' : 'Awesome!';

  // ── Errors ────────────────────────────────────────────────────────────────────
  String get errorNoInternet       => _tr ? 'Bağlantı yok. İnternetini kontrol edip tekrar dene.'
    : _es ? 'Sin conexión. Revisa tu internet e inténtalo de nuevo.'
    : _de ? 'Keine Verbindung. Überprüfe dein Internet und versuche es erneut.'
    : _fr ? 'Pas de connexion. Vérifie ton internet et réessaie.'
    : _pt ? 'Sem conexão. Verifique sua internet e tente novamente.'
    : 'No connection. Check your internet and try again.';

  String get errorAiTimeout        => _tr ? 'Mesaj oluşturulurken sorun yaşandı. Tekrar deneyelim mi?'
    : _es ? 'Hubo un problema al crear el mensaje. ¿Intentamos de nuevo?'
    : _de ? 'Beim Erstellen der Nachricht ist ein Problem aufgetreten. Sollen wir es erneut versuchen?'
    : _fr ? 'Un problème est survenu lors de la création du message. On réessaie?'
    : _pt ? 'Houve um problema ao criar a mensagem. Tentamos de novo?'
    : 'Had trouble creating your message. Want to try again?';

  String get errorGeneric          => _tr ? 'Bir şeyler ters gitti. Lütfen tekrar dene.'
    : _es ? 'Algo salió mal. Por favor, inténtalo de nuevo.'
    : _de ? 'Etwas ist schiefgelaufen. Bitte versuche es erneut.'
    : _fr ? 'Quelque chose a mal tourné. Veuillez réessayer.'
    : _pt ? 'Algo deu errado. Por favor, tente novamente.'
    : 'Something went wrong. Please try again.';

  // ── Notification permission ───────────────────────────────────────────────────
  String get notifPermissionTitle  => _tr ? 'Sabah ritüelini koru'
    : _es ? 'Protege tu ritual matutino'
    : _de ? 'Schütze dein Morgenritual'
    : _fr ? 'Protège ton rituel matinal'
    : _pt ? 'Proteja seu ritual matinal'
    : 'Protect your morning ritual';

  String get notifPermissionBody   => _tr ? 'Seni her sabah nazikçe hatırlatacağız. Spam yok, sadece senin için.'
    : _es ? 'Te recordaremos suavemente cada mañana. Sin spam, solo para ti.'
    : _de ? 'Wir erinnern dich jeden Morgen sanft. Kein Spam, nur für dich.'
    : _fr ? 'Nous te rappellerons doucement chaque matin. Pas de spam, juste pour toi.'
    : _pt ? 'Vamos lembrá-lo suavemente toda manhã. Sem spam, apenas para você.'
    : 'We\'ll gently remind you each morning. No spam, just for you.';

  String get notifPermissionEnable => _tr ? 'Bildirimleri Aç'
    : _es ? 'Activar Notificaciones'
    : _de ? 'Benachrichtigungen aktivieren'
    : _fr ? 'Activer les notifications'
    : _pt ? 'Ativar Notificações'
    : 'Enable Notifications';

  String get notifPermissionSkip   => _tr ? 'Şimdi değil' : _es ? 'Ahora no' : _de ? 'Nicht jetzt' : _fr ? 'Pas maintenant' : _pt ? 'Agora não' : 'Not now';
}
