import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  List<Dictionary> _dictionaries = [];
  List<Word> _words = [];
  UserSettings _settings = UserSettings();
  final DatabaseService _dbService = DatabaseService();

  // Statistics
  int _totalWordsLearned = 0;
  int _totalReviewsCompleted = 0;
  int _currentStreak = 0;

  // Выбранные словари для изучения
  Set<String> _selectedDictionaryIds = {};

  User? get currentUser => _currentUser;
  List<Dictionary> get dictionaries => _dictionaries;
  List<Word> get words => _words;
  UserSettings get settings => _settings;
  int get totalWordsLearned => _totalWordsLearned;
  int get totalReviewsCompleted => _totalReviewsCompleted;
  int get currentStreak => _currentStreak;
  Set<String> get selectedDictionaryIds => _selectedDictionaryIds;

  bool get isAuthenticated => _currentUser != null;

  // ==================== Инициализация ====================

  Future<void> initializeData() async {
    if (_currentUser != null) {
      await loadDictionaries();
    }
  }

  Future<void> loadDictionaries() async {
    if (_currentUser == null) return;
    
    _dictionaries = await _dbService.getAllDictionaries(_currentUser!.id);
    notifyListeners();
  }

  // ==================== Auth methods ====================

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@').first,
        settings: _settings,
      );
      
      await _dbService.createUser(user);
      _currentUser = user;
      await initializeData();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        settings: _settings,
      );
      
      await _dbService.createUser(user);
      _currentUser = user;
      await initializeData();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _dictionaries = [];
    _words = [];
    _selectedDictionaryIds.clear();
    notifyListeners();
  }

  // ==================== Settings methods ====================

  Future<void> toggleTheme() async {
    _settings.darkTheme = !_settings.darkTheme;
    if (_currentUser != null) {
      await _dbService.updateUserSettings(_currentUser!.id, _settings);
    }
    notifyListeners();
  }

  Future<void> setInterfaceLanguage(String language) async {
    _settings.interfaceLanguage = language;
    if (_currentUser != null) {
      await _dbService.updateUserSettings(_currentUser!.id, _settings);
    }
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _settings.notificationsEnabled = !_settings.notificationsEnabled;
    if (_currentUser != null) {
      await _dbService.updateUserSettings(_currentUser!.id, _settings);
    }
    notifyListeners();
  }

  Future<void> setMaxNewWordsPerDay(int max) async {
    _settings.maxNewWordsPerDay = max;
    if (_currentUser != null) {
      await _dbService.updateUserSettings(_currentUser!.id, _settings);
    }
    notifyListeners();
  }

  // ==================== Dictionary methods ====================

  Future<void> createDictionary({
    required String name,
    required String description,
    required String languageFrom,
    required String languageTo,
  }) async {
    if (_currentUser == null) return;

    final dictionary = Dictionary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      totalWords: 0,
      learnedWords: 0,
      languageFrom: languageFrom,
      languageTo: languageTo,
      isPreset: false,
      createdAt: DateTime.now(),
    );

    await _dbService.createDictionary(dictionary, _currentUser!.id);
    await loadDictionaries();
  }

  Future<void> deleteDictionary(String dictionaryId) async {
    await _dbService.deleteDictionary(dictionaryId);
    _selectedDictionaryIds.remove(dictionaryId);
    await loadDictionaries();
  }

  Future<void> addWordsToDictionary(String dictionaryId, List<Map<String, String>> wordsData) async {
    final now = DateTime.now();
    final words = wordsData.map((data) => Word(
      id: '${dictionaryId}_${now.millisecondsSinceEpoch}_${data['word']}',
      dictionaryId: dictionaryId,
      word: data['word'] ?? '',
      translation: data['translation'] ?? '',
      example: data['example'],
      transcription: data['transcription'],
      status: WordStatus.newWord,
      reviewCount: 0,
      createdAt: now,
    )).toList();

    await _dbService.createWordsBulk(words);
    
    // Обновить количество слов в словаре
    final dict = await _dbService.getDictionaryById(dictionaryId);
    if (dict != null) {
      final allWords = await _dbService.getWordsByDictionaryId(dictionaryId);
      final updatedDict = dict.copyWith(totalWords: allWords.length);
      await _dbService.updateDictionary(updatedDict, userId: dict.isPreset ? null : _currentUser?.id);
      await loadDictionaries();
    }
  }

  // ==================== Selected Dictionaries ====================

  void toggleDictionarySelection(String dictionaryId) {
    if (_selectedDictionaryIds.contains(dictionaryId)) {
      _selectedDictionaryIds.remove(dictionaryId);
    } else {
      _selectedDictionaryIds.add(dictionaryId);
    }
    notifyListeners();
  }

  void clearSelectedDictionaries() {
    _selectedDictionaryIds.clear();
    notifyListeners();
  }

  // ==================== Study methods ====================

  /// Получить слова для первичного изучения (этап "Изучения новых слов")
  Future<List<Word>> getWordsForInitialLearning() async {
    if (_currentUser == null || _selectedDictionaryIds.isEmpty) return [];
    
    return await _dbService.getWordsForLearning(
      _currentUser!.id,
      _selectedDictionaryIds.toList(),
    );
  }

  /// Получить слова для повторения
  Future<List<Word>> getWordsForReview() async {
    if (_currentUser == null || _selectedDictionaryIds.isEmpty) return [];
    
    return await _dbService.getWordsForReview(
      _currentUser!.id,
      _selectedDictionaryIds.toList(),
    );
  }

  /// Отметить слово как "знаю" (не нужно учить)
  Future<void> markWordAsKnown(Word word) async {
    await _dbService.markWordAsKnown(word);
    _totalWordsLearned++;
    notifyListeners();
  }

  /// Начать изучение слова (добавить в очередь на повторение)
  Future<void> startLearningWord(Word word) async {
    await _dbService.startLearningWord(word);
    notifyListeners();
  }

  /// Обработать результат повторения слова с оценкой сложности
  /// difficulty: 'easy', 'normal', 'hard'
  Future<void> markWordReviewResult(Word word, String difficulty, int intervalDays) async {
    final newReviewCount = word.reviewCount + 1;
    
    // Преобразуем текстовую оценку в числовую для SM-2 алгоритма
    int quality;
    switch (difficulty) {
      case 'easy':
        quality = 3;
        break;
      case 'normal':
        quality = 2;
        break;
      case 'hard':
        quality = 1;
        break;
      default:
        quality = 2;
    }
    
    if (newReviewCount >= 7) {
      // Слово полностью изучено после 7 повторений
      await _dbService.completeWordLearning(word);
    } else {
      final updatedWord = word.copyWith(
        reviewCount: newReviewCount,
        nextReview: DateTime.now().add(Duration(days: intervalDays)),
        lastReviewedAt: DateTime.now(),
        easeFactor: _calculateEaseFactor(word.easeFactor, quality),
      );
      await _dbService.updateWordAfterReview(updatedWord);
    }

    _totalReviewsCompleted++;
    notifyListeners();
  }

  /// Отправить слово в конец колоды для повторения
  Future<void> sendWordToReview(Word word) async {
    // Пересоздаем слово с новым ID и отправляем в конец очереди
    final newWord = word.copyWith(
      id: '${word.id}_retry_${DateTime.now().millisecondsSinceEpoch}',
      nextReview: DateTime.now().add(const Duration(minutes: 5)),
      reviewCount: word.reviewCount,
    );
    await _dbService.createWord(newWord);
    await _dbService.markWordAsKnown(word); // Помечаем старое как известное
    notifyListeners();
  }

  /// Обработать результат повторения слова
  /// quality: 1 (hard) - сложно, 2 (normal) - нормально, 3 (easy) - легко
  Future<void> completeReview(Word word, int quality) async {
    final newReviewCount = word.reviewCount + 1;
    
    // Интервалы для 7 этапов повторения
    final intervals = _settings.repetitionIntervals;
    int intervalDays;
    
    if (quality < 1) quality = 1;
    if (quality > 3) quality = 3;
    
    // Корректировка интервала в зависимости от сложности
    double qualityMultiplier;
    switch (quality) {
      case 1: // Hard
        qualityMultiplier = 0.5;
        break;
      case 2: // Normal
        qualityMultiplier = 1.0;
        break;
      case 3: // Easy
        qualityMultiplier = 1.5;
        break;
      default:
        qualityMultiplier = 1.0;
    }
    
    if (newReviewCount >= 7) {
      // Слово полностью изучено после 7 повторений
      await _dbService.completeWordLearning(word);
      intervalDays = intervals.last;
    } else {
      // Рассчитать следующий интервал
      final baseInterval = intervals[newReviewCount - 1];
      intervalDays = (baseInterval * qualityMultiplier).round();
      if (intervalDays < 1) intervalDays = 1;
      
      final updatedWord = word.copyWith(
        reviewCount: newReviewCount,
        nextReview: DateTime.now().add(Duration(days: intervalDays)),
        lastReviewedAt: DateTime.now(),
        easeFactor: _calculateEaseFactor(word.easeFactor, quality),
      );
      await _dbService.updateWordAfterReview(updatedWord);
    }

    _totalReviewsCompleted++;
    notifyListeners();
  }

  double _calculateEaseFactor(double ef, int quality) {
    // SM-2 algorithm ease factor calculation
    double newEf = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    return newEf.clamp(1.3, 3.0);
  }

  Future<void> resetProgress() async {
    if (_currentUser == null) return;
    
    await _dbService.deleteAllUserWords(_currentUser!.id);
    _totalWordsLearned = 0;
    _totalReviewsCompleted = 0;
    _currentStreak = 0;
    await loadDictionaries();
    notifyListeners();
  }
}
