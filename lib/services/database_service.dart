import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Сервис для работы с базой данных SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wordup.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        dark_theme INTEGER DEFAULT 0,
        interface_language TEXT DEFAULT 'ru',
        notifications_enabled INTEGER DEFAULT 1,
        max_new_words_per_day INTEGER DEFAULT 10,
        created_at TEXT NOT NULL
      )
    ''');

    // Таблица словарей
    await db.execute('''
      CREATE TABLE dictionaries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        total_words INTEGER DEFAULT 0,
        learned_words INTEGER DEFAULT 0,
        language_from TEXT,
        language_to TEXT,
        is_preset INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Таблица слов
    await db.execute('''
      CREATE TABLE words (
        id TEXT PRIMARY KEY,
        dictionary_id TEXT NOT NULL,
        word TEXT NOT NULL,
        translation TEXT NOT NULL,
        example TEXT,
        transcription TEXT,
        status INTEGER DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        ease_factor REAL DEFAULT 2.5,
        created_at TEXT NOT NULL,
        first_learned_at TEXT,
        next_review TEXT,
        last_reviewed_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (dictionary_id) REFERENCES dictionaries(id) ON DELETE CASCADE
      )
    ''');

    // Индексы для оптимизации запросов
    await db.execute('CREATE INDEX idx_words_dictionary ON words(dictionary_id)');
    await db.execute('CREATE INDEX idx_words_status ON words(status)');
    await db.execute('CREATE INDEX idx_words_next_review ON words(next_review)');
    await db.execute('CREATE INDEX idx_dictionaries_user ON dictionaries(user_id)');

    // Таблица настроек повторений
    await db.execute('''
      CREATE TABLE repetition_intervals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        stage INTEGER NOT NULL,
        interval_days INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Миграции при обновлении версии БД
    if (oldVersion < 2) {
      // Добавить новые поля при необходимости
    }
  }

  // ==================== Пользователи ====================

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'dark_theme': user.settings.darkTheme ? 1 : 0,
      'interface_language': user.settings.interfaceLanguage,
      'notifications_enabled': user.settings.notificationsEnabled ? 1 : 0,
      'max_new_words_per_day': user.settings.maxNewWordsPerDay,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final map = maps.first;
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      settings: UserSettings(
        darkTheme: map['dark_theme'] == 1,
        interfaceLanguage: map['interface_language'] as String? ?? 'ru',
        notificationsEnabled: map['notifications_enabled'] == 1,
        maxNewWordsPerDay: map['max_new_words_per_day'] as int? ?? 10,
      ),
    );
  }

  Future<int> updateUserSettings(String userId, UserSettings settings) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'dark_theme': settings.darkTheme ? 1 : 0,
        'interface_language': settings.interfaceLanguage,
        'notifications_enabled': settings.notificationsEnabled ? 1 : 0,
        'max_new_words_per_day': settings.maxNewWordsPerDay,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== Словари ====================

  Future<int> createDictionary(Dictionary dictionary, String userId) async {
    final db = await database;
    return await db.insert('dictionaries', {
      ...dictionary.toMap(),
      'user_id': userId,
    });
  }

  Future<List<Dictionary>> getAllDictionaries(String userId) async {
    final db = await database;
    final maps = await db.query(
      'dictionaries',
      where: 'user_id = ? OR is_preset = 1',
      whereArgs: [userId],
      orderBy: 'is_preset ASC, created_at DESC',
    );
    return maps.map((map) => Dictionary.fromMap(map)).toList();
  }

  Future<List<Dictionary>> getUserDictionaries(String userId) async {
    final db = await database;
    final maps = await db.query(
      'dictionaries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Dictionary.fromMap(map)).toList();
  }

  Future<List<Dictionary>> getPresetDictionaries() async {
    final db = await database;
    final maps = await db.query(
      'dictionaries',
      where: 'is_preset = 1',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Dictionary.fromMap(map)).toList();
  }

  Future<Dictionary?> getDictionaryById(String id) async {
    final db = await database;
    final maps = await db.query('dictionaries', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Dictionary.fromMap(maps.first);
  }

  Future<int> updateDictionary(Dictionary dictionary) async {
    final db = await database;
    return await db.update(
      'dictionaries',
      dictionary.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [dictionary.id],
    );
  }

  Future<int> deleteDictionary(String id) async {
    final db = await database;
    return await db.delete('dictionaries', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Слова ====================

  Future<int> createWord(Word word) async {
    final db = await database;
    return await db.insert('words', word.toMap());
  }

  Future<int> createWordsBulk(List<Word> words) async {
    final db = await database;
    int count = 0;
    await db.transaction((txn) async {
      for (final word in words) {
        await txn.insert('words', word.toMap());
        count++;
      }
    });
    return count;
  }

  Future<List<Word>> getWordsByDictionaryId(String dictionaryId) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'dictionary_id = ?',
      whereArgs: [dictionaryId],
      orderBy: 'word ASC',
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  Future<Word?> getWordById(String id) async {
    final db = await database;
    final maps = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Word.fromMap(maps.first);
  }

  /// Получить слова для изучения (новые или которые пользователь отметил как "надо учить")
  Future<List<Word>> getWordsForLearning(String userId, List<String> dictionaryIds) async {
    final db = await database;
    if (dictionaryIds.isEmpty) return [];

    final placeholders = List.filled(dictionaryIds.length, '?').join(',');
    final maps = await db.query(
      'words',
      where: 'dictionary_id IN ($placeholders) AND status IN (?, ?)',
      whereArgs: [...dictionaryIds, WordStatus.newWord.index, WordStatus.learning.index],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  /// Получить слова для повторения (статус learning и пришло время повторения)
  Future<List<Word>> getWordsForReview(String userId, List<String> dictionaryIds) async {
    final db = await database;
    if (dictionaryIds.isEmpty) return [];

    final now = DateTime.now().toIso8601String();
    final placeholders = List.filled(dictionaryIds.length, '?').join(',');
    final maps = await db.query(
      'words',
      where: '''
        dictionary_id IN ($placeholders) 
        AND status = ? 
        AND (next_review IS NULL OR next_review <= ?)
      ''',
      whereArgs: [...dictionaryIds, WordStatus.learning.index, now],
      orderBy: 'next_review ASC, created_at ASC',
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  /// Обновить слово после повторения
  Future<int> updateWordAfterReview(Word word) async {
    final db = await database;
    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  /// Отметить слово как известное (пользователь уже знал его)
  Future<int> markWordAsKnown(Word word) async {
    final updatedWord = word.copyWith(
      status: WordStatus.known,
      firstLearnedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    return await updateWordAfterReview(updatedWord);
  }

  /// Начать изучение нового слова
  Future<int> startLearningWord(Word word) async {
    final updatedWord = word.copyWith(
      status: WordStatus.learning,
      firstLearnedAt: DateTime.now(),
      nextReview: DateTime.now(), // Повторить сразу
    );
    return await updateWordAfterReview(updatedWord);
  }

  /// Завершить изучение слова (7 повторений выполнено)
  Future<int> completeWordLearning(Word word) async {
    final updatedWord = word.copyWith(
      status: WordStatus.learned,
      completedAt: DateTime.now(),
    );
    return await updateWordAfterReview(updatedWord);
  }

  /// Удалить все слова пользователя
  Future<int> deleteAllUserWords(String userId) async {
    final db = await database;
    return await db.delete(
      'words',
      where: 'dictionary_id IN (SELECT id FROM dictionaries WHERE user_id = ?)',
      whereArgs: [userId],
    );
  }

  /// Очистить базу данных
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('words');
    await db.delete('dictionaries');
    await db.delete('users');
    await db.delete('repetition_intervals');
  }

  /// Инициализировать предустановленные словари
  Future<void> initializePresetDictionaries() async {
    final db = await database;
    
    // Проверить, есть ли уже предустановленные словари
    final existing = await getPresetDictionaries();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final presets = [
      Dictionary(
        id: 'preset_1',
        name: 'New General Service List',
        description: 'Базовая лексика английского языка',
        totalWords: 2800,
        learnedWords: 0,
        languageFrom: 'Русский',
        languageTo: 'Английский',
        isPreset: true,
        createdAt: now,
      ),
      Dictionary(
        id: 'preset_2',
        name: 'Oxford 3000',
        description: '3000 самых важных слов английского языка',
        totalWords: 3000,
        learnedWords: 0,
        languageFrom: 'Русский',
        languageTo: 'Английский',
        isPreset: true,
        createdAt: now,
      ),
      Dictionary(
        id: 'preset_3',
        name: 'Oxford 5000',
        description: '5000 слов для продвинутого уровня',
        totalWords: 5000,
        learnedWords: 0,
        languageFrom: 'Русский',
        languageTo: 'Английский',
        isPreset: true,
        createdAt: now,
      ),
    ];

    for (final dict in presets) {
      await db.insert('dictionaries', dict.toMap());
    }
  }
}
