import 'package:flutter/material.dart';

class Dictionary {
  final String id;
  final String name;
  final String description;
  final int totalWords;
  final int learnedWords;
  final String languageFrom;
  final String languageTo;

  Dictionary({
    required this.id,
    required this.name,
    required this.description,
    required this.totalWords,
    required this.learnedWords,
    required this.languageFrom,
    required this.languageTo,
  });
}

class Word {
  final String id;
  final String word;
  final String translation;
  final String example;
  final DateTime createdAt;
  final DateTime? nextReview;
  final int reviewCount;
  final double easeFactor;

  Word({
    required this.id,
    required this.word,
    required this.translation,
    this.example = '',
    required this.createdAt,
    this.nextReview,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
  });
}

class UserSettings {
  bool darkTheme;
  String interfaceLanguage;
  bool notificationsEnabled;
  List<int> reviewIntervals; // Days between reviews

  UserSettings({
    this.darkTheme = false,
    this.interfaceLanguage = 'ru',
    this.notificationsEnabled = true,
    this.reviewIntervals = const [1, 3, 7, 14, 30],
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
