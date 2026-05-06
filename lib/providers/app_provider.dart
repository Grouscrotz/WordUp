import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  List<Dictionary> _dictionaries = [];
  List<Word> _words = [];
  UserSettings _settings = UserSettings();

  // Statistics
  int _totalWordsLearned = 0;
  int _totalReviewsCompleted = 0;
  int _currentStreak = 0;

  User? get currentUser => _currentUser;
  List<Dictionary> get dictionaries => _dictionaries;
  List<Word> get words => _words;
  UserSettings get settings => _settings;
  int get totalWordsLearned => _totalWordsLearned;
  int get totalReviewsCompleted => _totalReviewsCompleted;
  int get currentStreak => _currentStreak;

  bool get isAuthenticated => _currentUser != null;

  // Mock data initialization
  void initializeMockData() {
    _dictionaries = [
      Dictionary(
        id: '1',
        name: 'Английский - Базовый',
        description: 'Основные слова для начинающих',
        totalWords: 500,
        learnedWords: 120,
        languageFrom: 'Русский',
        languageTo: 'Английский',
      ),
      Dictionary(
        id: '2',
        name: 'Английский - Продвинутый',
        description: 'Слова для продвинутого уровня',
        totalWords: 1000,
        learnedWords: 45,
        languageFrom: 'Русский',
        languageTo: 'Английский',
      ),
      Dictionary(
        id: '3',
        name: 'Немецкий - Базовый',
        description: 'Основные немецкие слова',
        totalWords: 400,
        learnedWords: 80,
        languageFrom: 'Русский',
        languageTo: 'Немецкий',
      ),
      Dictionary(
        id: '4',
        name: 'Испанский - Путешествия',
        description: 'Слова для путешественников',
        totalWords: 300,
        learnedWords: 150,
        languageFrom: 'Русский',
        languageTo: 'Испанский',
      ),
    ];

    _words = [
      Word(
        id: '1',
        word: 'Hello',
        translation: 'Привет',
        example: 'Hello, how are you?',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        nextReview: DateTime.now().add(const Duration(days: 2)),
        reviewCount: 3,
      ),
      Word(
        id: '2',
        word: 'Goodbye',
        translation: 'До свидания',
        example: 'Goodbye, see you later!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        nextReview: DateTime.now().subtract(const Duration(days: 1)),
        reviewCount: 2,
      ),
    ];

    _totalWordsLearned = 120;
    _totalReviewsCompleted = 450;
    _currentStreak = 7;

    notifyListeners();
  }

  // Auth methods
  Future<bool> login(String email, String password) async {
    // Mock login - in real app would call API
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '1',
        email: email,
        name: email.split('@').first,
        settings: _settings,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    // Mock registration - in real app would call API
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      _currentUser = User(
        id: '1',
        email: email,
        name: name,
        settings: _settings,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  // Settings methods
  void toggleTheme() {
    _settings.darkTheme = !_settings.darkTheme;
    notifyListeners();
  }

  void setInterfaceLanguage(String language) {
    _settings.interfaceLanguage = language;
    notifyListeners();
  }

  void toggleNotifications() {
    _settings.notificationsEnabled = !_settings.notificationsEnabled;
    notifyListeners();
  }

  void updateReviewIntervals(List<int> intervals) {
    _settings.reviewIntervals = intervals;
    notifyListeners();
  }

  void resetProgress() {
    _totalWordsLearned = 0;
    _totalReviewsCompleted = 0;
    _currentStreak = 0;
    for (var dict in _dictionaries) {
      // Reset dictionary progress
    }
    notifyListeners();
  }

  // Study methods
  List<Word> getWordsForReview() {
    return _words.where((word) {
      final nextReview = word.nextReview;
      return nextReview == null || nextReview.isBefore(DateTime.now());
    }).toList();
  }

  List<Word> getNewWords() {
    return _words.where((word) => word.reviewCount == 0).toList();
  }

  void markWordAsReviewed(Word word, int quality) {
    // Implement SM-2 or similar spaced repetition algorithm
    final newEaseFactor = _calculateEaseFactor(word.easeFactor, quality);
    final newReviewCount = word.reviewCount + 1;
    
    // Calculate next review interval based on settings and quality
    int intervalDays;
    if (quality >= 3) {
      if (newReviewCount == 1) {
        intervalDays = _settings.reviewIntervals[0];
      } else if (newReviewCount == 2) {
        intervalDays = _settings.reviewIntervals[1];
      } else {
        intervalDays = (_settings.reviewIntervals.last * (newReviewCount - 2)).clamp(
          _settings.reviewIntervals[2],
          _settings.reviewIntervals.last * 10,
        );
      }
    } else {
      intervalDays = 1; // Review again tomorrow
    }

    final updatedWord = Word(
      id: word.id,
      word: word.word,
      translation: word.translation,
      example: word.example,
      createdAt: word.createdAt,
      nextReview: DateTime.now().add(Duration(days: intervalDays)),
      reviewCount: newReviewCount,
      easeFactor: newEaseFactor,
    );

    final index = _words.indexWhere((w) => w.id == word.id);
    if (index != -1) {
      _words[index] = updatedWord;
    }

    _totalReviewsCompleted++;
    notifyListeners();
  }

  double _calculateEaseFactor(double ef, int quality) {
    // SM-2 algorithm ease factor calculation
    double newEf = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return newEf.clamp(1.3, 3.0);
  }
}
