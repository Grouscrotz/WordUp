import 'package:flutter/material.dart';

/// Статус слова в процессе изучения
enum WordStatus {
  newWord,      // Новое слово, ещё не начали учить
  learning,     // Слово в процессе изучения (повторяется)
  known,        // Пользователь уже знал это слово (не требует повторений)
  learned,      // Полностью изучено (7 повторений выполнено)
}

class Dictionary {
  final String id;
  final String name;
  final String description;
  final int totalWords;
  final int learnedWords;
  final String languageFrom;
  final String languageTo;
  final bool isPreset;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Dictionary({
    required this.id,
    required this.name,
    required this.description,
    required this.totalWords,
    required this.learnedWords,
    required this.languageFrom,
    required this.languageTo,
    this.isPreset = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap({String? userId}) {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'total_words': totalWords,
      'learned_words': learnedWords,
      'language_from': languageFrom,
      'language_to': languageTo,
      'is_preset': isPreset ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Dictionary.fromMap(Map<String, dynamic> map) {
    return Dictionary(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      totalWords: map['total_words'] ?? 0,
      learnedWords: map['learned_words'] ?? 0,
      languageFrom: map['language_from'] ?? '',
      languageTo: map['language_to'] ?? '',
      isPreset: (map['is_preset'] ?? 0) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
    );
  }

  Dictionary copyWith({
    String? id,
    String? name,
    String? description,
    int? totalWords,
    int? learnedWords,
    String? languageFrom,
    String? languageTo,
    bool? isPreset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dictionary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWords: totalWords ?? this.totalWords,
      learnedWords: learnedWords ?? this.learnedWords,
      languageFrom: languageFrom ?? this.languageFrom,
      languageTo: languageTo ?? this.languageTo,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Word {
  final String id;
  final String dictionaryId;
  final String word;
  final String translation;
  final String? example;
  final String? transcription;
  final WordStatus status;
  final int reviewCount;
  final double easeFactor;
  final DateTime createdAt;
  final DateTime? firstLearnedAt;
  final DateTime? nextReview;
  final DateTime? lastReviewedAt;
  final DateTime? completedAt;

  Word({
    required this.id,
    required this.dictionaryId,
    required this.word,
    required this.translation,
    this.example,
    this.transcription,
    this.status = WordStatus.newWord,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
    required this.createdAt,
    this.firstLearnedAt,
    this.nextReview,
    this.lastReviewedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dictionary_id': dictionaryId,
      'word': word,
      'translation': translation,
      'example': example,
      'transcription': transcription,
      'status': status.index,
      'review_count': reviewCount,
      'ease_factor': easeFactor,
      'created_at': createdAt.toIso8601String(),
      'first_learned_at': firstLearnedAt?.toIso8601String(),
      'next_review': nextReview?.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] ?? '',
      dictionaryId: map['dictionary_id'] ?? '',
      word: map['word'] ?? '',
      translation: map['translation'] ?? '',
      example: map['example'],
      transcription: map['transcription'],
      status: WordStatus.values[map['status'] ?? 0],
      reviewCount: map['review_count'] ?? 0,
      easeFactor: (map['ease_factor'] ?? 2.5).toDouble(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      firstLearnedAt: map['first_learned_at'] != null 
          ? DateTime.parse(map['first_learned_at']) 
          : null,
      nextReview: map['next_review'] != null 
          ? DateTime.parse(map['next_review']) 
          : null,
      lastReviewedAt: map['last_reviewed_at'] != null 
          ? DateTime.parse(map['last_reviewed_at']) 
          : null,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
    );
  }

  Word copyWith({
    String? id,
    String? dictionaryId,
    String? word,
    String? translation,
    String? example,
    String? transcription,
    WordStatus? status,
    int? reviewCount,
    double? easeFactor,
    DateTime? createdAt,
    DateTime? firstLearnedAt,
    DateTime? nextReview,
    DateTime? lastReviewedAt,
    DateTime? completedAt,
  }) {
    return Word(
      id: id ?? this.id,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      example: example ?? this.example,
      transcription: transcription ?? this.transcription,
      status: status ?? this.status,
      reviewCount: reviewCount ?? this.reviewCount,
      easeFactor: easeFactor ?? this.easeFactor,
      createdAt: createdAt ?? this.createdAt,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      nextReview: nextReview ?? this.nextReview,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class UserSettings {
  bool darkTheme;
  String interfaceLanguage;
  bool notificationsEnabled;
  int maxNewWordsPerDay;
  List<int> repetitionIntervals; // Days between reviews for each stage

  UserSettings({
    this.darkTheme = false,
    this.interfaceLanguage = 'ru',
    this.notificationsEnabled = true,
    this.maxNewWordsPerDay = 10,
    this.repetitionIntervals = const [1, 2, 4, 7, 14, 30, 60],
  });
}

class User {
  final String id;
  final String email;
  final String name;
  UserSettings settings;

  User({
    required this.id,
    required this.email,
    required this.name,
    UserSettings? settings,
  }) : settings = settings ?? UserSettings();
}
