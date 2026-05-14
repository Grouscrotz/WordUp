import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

/// Экран повторения слов
/// На этом этапе пользователь повторяет слова, которые начал учить
/// Для каждого слова выбирается сложность вспоминания (Сложно/Нормально/Легко)
/// что определяет интервал до следующего повторения
/// После 7 успешных повторений слово считается полностью изученным
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  int _currentWordIndex = 0;
  bool _isRevealed = false;
  bool _isLoading = true;
  List<Word> _words = [];
  Set<int> _expandedExamples = {}; // Отслеживание раскрытых примеров
  
  // Интервалы для 7 этапов повторения (в днях)
  final List<int> _repetitionIntervals = [1, 2, 4, 7, 14, 30, 60];
  
  @override
  void initState() {
    super.initState();
    _loadWords();
  }
  
  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    _words = await provider.getWordsForReview();
    setState(() => _isLoading = false);
  }

  /// Обработать оценку сложности вспоминания
  /// quality: 1 - сложно, 2 - нормально, 3 - легко
  void _handleDifficultySelection(int quality) async {
    final word = _words[_currentWordIndex];
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.completeReview(word, quality);
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isRevealed = false;
        _expandedExamples.clear(); // Очищаем раскрытые примеры при переходе к следующему слову
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _prevWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
        _isRevealed = false;
        _expandedExamples.clear(); // Очищаем раскрытые примеры при переходе к предыдущему слову
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Отлично!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Вы завершили эту сессию повторения!'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: orangeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Слов повторено',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_words.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('К обучению', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Повторение',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Повторение',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              const Text(
                'Нет слов для повторения',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Все слова повторены вовремя!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Вернуться', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = _words[_currentWordIndex];
    final isLastWord = _currentWordIndex == _words.length - 1;
    final isFirstWord = _currentWordIndex == 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Повторение',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentWordIndex + 1}/${_words.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: orangeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              // Progress bar with back arrow
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: (_currentWordIndex + 1) / _words.length,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                  if (!isFirstWord)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: _prevWord,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Word card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with repetition info
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Повторение',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Этап ${currentWord.reviewCount + 1}/7',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Word display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentWord.word,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            if (currentWord.transcription != null && currentWord.transcription!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '[${currentWord.transcription}]',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Reveal button or translation
                        if (!_isRevealed)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRevealed = true;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.visibility_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1, thickness: 1),
                              const SizedBox(height: 16),
                              Text(
                                currentWord.translation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              if (currentWord.example != null && currentWord.example!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Примеры:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Example sentences list - parse multiple examples separated by semicolon or newline
                                ..._parseExamples(currentWord.example!).asMap().entries.map((entry) {
                                  return _buildExampleItem(entry.value, currentWord.word, entry.key);
                                }),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Difficulty selection buttons - always visible after reveal
              if (!_isRevealed)
                const SizedBox.shrink()
              else
                Column(
                  children: [
                    const Text(
                      'Как хорошо вы вспомнили значение?',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _handleDifficultySelection(1),
                            child: const Column(
                              children: [
                                Text('Сложно', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('через 1 день', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _handleDifficultySelection(2),
                            child: const Column(
                              children: [
                                Text('Нормально', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('через 2 дня', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _handleDifficultySelection(3),
                            child: const Column(
                              children: [
                                Text('Легко', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('через 4 дня', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleItem(String example, String word, int index) {
    // Parse example sentences - they are stored as "english sentence | russian translation"
    final parts = example.split('|');
    final englishSentence = parts.length > 0 ? parts[0].trim() : '';
    final russianTranslation = parts.length > 1 ? parts[1].trim() : '';
    
    final isExpanded = _expandedExamples.contains(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedExamples.remove(index);
            } else {
              _expandedExamples.add(index);
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_right,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      englishSentence,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Manrope',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    russianTranslation,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseExamples(String examples) {
    // Split examples by semicolon or newline, then filter out empty strings
    return examples
        .split(RegExp(r'[;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
