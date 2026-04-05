// lib/shared/models/motivation_message.dart
//
// Data models for İçimden

// ─── MotivationMessage ─────────────────────────────────────────────────────────

class MotivationMessage {
  const MotivationMessage({
    required this.id,
    required this.message,
    required this.mood,
    required this.date,
    required this.isNew,
    required this.isSaved,
    this.streak,
    this.createdAt,
  });

  final String id;
  final String message;
  final String mood;
  final String date;
  final bool isNew;
  final bool isSaved;
  final StreakInfo? streak;
  final DateTime? createdAt;

  factory MotivationMessage.fromJson(Map<String, dynamic> json) {
    return MotivationMessage(
      id:        json['id'] as String? ?? '',
      message:   json['message'] as String? ?? '',
      mood:      json['mood'] as String? ?? '',
      date:      json['date'] as String? ?? '',
      isNew:     json['is_new'] as bool? ?? false,
      isSaved:   json['is_saved'] as bool? ?? false,
      streak:    json['streak'] != null
          ? StreakInfo.fromJson(json['streak'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  MotivationMessage copyWith({bool? isSaved}) {
    return MotivationMessage(
      id:        id,
      message:   message,
      mood:      mood,
      date:      date,
      isNew:     isNew,
      isSaved:   isSaved ?? this.isSaved,
      streak:    streak,
      createdAt: createdAt,
    );
  }
}

// ─── StreakInfo ────────────────────────────────────────────────────────────────

class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.longest,
    required this.isMilestone,
  });

  final int current;
  final int longest;
  final bool isMilestone;

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      current:     (json['current'] as num?)?.toInt() ?? 0,
      longest:     (json['longest'] as num?)?.toInt() ?? 0,
      isMilestone: json['is_milestone'] as bool? ?? false,
    );
  }
}

// ─── JournalEntry ─────────────────────────────────────────────────────────────

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.message,
    required this.mood,
    required this.messageDate,
    required this.savedAt,
  });

  final String id;
  final String message;
  final String mood;
  final String messageDate;
  final DateTime savedAt;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id:          json['id'] as String,
      message:     json['message'] as String,
      mood:        json['mood'] as String,
      messageDate: json['message_date'] as String? ?? '',
      savedAt:     DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get previewText {
    if (message.length <= 100) return message;
    return '${message.substring(0, 100)}...';
  }
}

// ─── UserStreak ───────────────────────────────────────────────────────────────

class UserStreak {
  const UserStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivity,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivity;

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActivity:  json['last_activity'] != null
          ? DateTime.tryParse(json['last_activity'] as String)
          : null,
    );
  }

  factory UserStreak.empty() => const UserStreak(currentStreak: 0, longestStreak: 0);
}
