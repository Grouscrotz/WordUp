import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

/// Экран изучения новых слов и повторения
class LearnScreen extends StatefulWidget {
  final String mode; // 'new' или 'review'
  final int wordsCount;
  
  const LearnScreen({super.key, required this.mode, this.wordsCount = 0});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  int _currentWordIndex = 0;
  bool _isRevealed = false;
  bool _isImageRevealed = false;
  bool _isLoading = true;
  List<Word> _words = [];
  
  // Интервалы повторения в днях для разных уровней сложности
  final Map<String, int> _repetitionIntervals = {
    'easy': 4,      // Легко - следующий повтор через 4 дня
    'normal': 2,    // Нормально - через 2 дня
    'hard': 1,      // Сложно - через 1 день
  };

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.mode == 'new') {
      _words = await provider.getWordsForInitialLearning();
    } else {
      _words = await provider.getWordsForReview();
    }
    setState(() => _isLoading = false);
  }

  void _handleDifficultySelection(String difficulty) async {
    final word = _words[_currentWordIndex];
    final provider = Provider.of<AppProvider>(context, listen: false);
    final intervalDays = _repetitionIntervals[difficulty] ?? 1;
    await provider.markWordReviewResult(word, difficulty, intervalDays);
    debugPrint('Слово "${word.word}" оценено как: $difficulty');
    debugPrint('Следующее повторение через: $intervalDays дн.');
    _nextWord();
  }

  void _sendToReview() async {
    final word = _words[_currentWordIndex];
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.sendWordToReview(word);
    debugPrint('Слово отправлено в конец колоды для повторения');
    _nextWord();
  }

  void _markAsKnown() async {
    final word = _words[_currentWordIndex];
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.markWordAsKnown(word);
    _nextWord();
  }

  void _startLearning() async {
    final word = _words[_currentWordIndex];
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.startLearningWord(word);
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isRevealed = false;
        _isImageRevealed = false;
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
        _isImageRevealed = false;
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
            const Text('Вы завершили эту сессию!'),
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
                  Text(
                    widget.mode == 'new' ? 'Новых слов выучено' : 'Слов повторено',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

  Widget _buildHighlightedText(String text, String word, TextStyle style) {
    final pattern = RegExp('(${RegExp.escape(word)})', caseSensitive: false);
    final parts = text.split(pattern);
    
    return RichText(
      text: TextSpan(
        style: style,
        children: parts.map((part) {
          final isWord = part.toLowerCase() == word.toLowerCase();
          return TextSpan(
            text: part,
            style: isWord ? const TextStyle(fontWeight: FontWeight.bold) : null,
          );
        }).toList(),
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
          title: Text(
            widget.mode == 'new' ? 'Новые слова' : 'Повторение',
            style: const TextStyle(
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
          title: Text(
            widget.mode == 'new' ? 'Новые слова' : 'Повторение',
            style: const TextStyle(
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
              Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                widget.mode == 'new' ? 'Нет новых слов для изучения' : 'Нет слов для повторения',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                widget.mode == 'new' ? 'Все слова из выбранных словарей уже изучены' : 'Все слова повторены',
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
        title: Text(
          widget.mode == 'new' ? 'Новые слова' : 'Повторение',
          style: const TextStyle(
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: GestureDetector(
                      onTap: isFirstWord ? null : _prevWord,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: isFirstWord ? Colors.grey.shade400 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
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
                        // Small gray square and header
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
                                  'Новое слово',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Oxford - A1',
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
                        
                        // Image and word info - image on left, word below image
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image container
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: _isImageRevealed ? Colors.white : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _isImageRevealed
                                    ? Image.network(
                                        'https://picsum.photos/400/300',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.image_outlined,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                      )
                                    : Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: Colors.grey.shade400,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Word and transcription aligned left
                            Text(
                              currentWord.word,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (currentWord.transcription != null && currentWord.transcription!.isNotEmpty)
                              Text(
                                '[${currentWord.transcription}]',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Reveal button or translation list
                        if (!_isRevealed)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRevealed = true;
                                  _isImageRevealed = true;
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
                              // Divider line
                              const Divider(height: 1, thickness: 1),
                              const SizedBox(height: 16),
                              // Translation in bold
                              Text(
                                currentWord.translation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Example sentences header with eye icon
                              if (currentWord.example != null && currentWord.example!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Примеры:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Example sentences list
                                _buildExpandableExample(
                                  currentWord.example!,
                                  currentWord.word,
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Верхняя панель с кнопкой "Показать снова" и кнопки сложности (только для режима повторения)
              if (widget.mode == 'review' && _isRevealed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок и кнопка "Показать снова" в одном ряду
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Как сложно было вспомнить?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          GestureDetector(
                            onTap: _sendToReview,
                            child: Text(
                              'Показать снова',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: orangeColor,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Кнопки сложности на всю ширину
                      Row(
                        children: [
                          Expanded(
                            child: _buildDifficultyButton(
                              'Легко',
                              '4 дня',
                              Colors.green,
                              () => _handleDifficultySelection('easy'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDifficultyButton(
                              'Нормально',
                              '2 дня',
                              orangeColor,
                              () => _handleDifficultySelection('normal'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDifficultyButton(
                              'Сложно',
                              '1 день',
                              Colors.red.shade400,
                              () => _handleDifficultySelection('hard'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
              ] else ...[
                // Навигационные кнопки (для новых слов или если слово ещё не открыто)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Левая кнопка: "Я уже знаю это слово"
                      Expanded(
                        child: GestureDetector(
                          onTap: _markAsKnown,
                          child: Opacity(
                            opacity: isFirstWord ? 0.5 : 1.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Я уже знаю\nэто слово',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_left, size: 24, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Правая кнопка: "Начать учить это слово"
                      Expanded(
                        child: GestureDetector(
                          onTap: _startLearning,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Начать учить\nэто слово',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String label, String days, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              days,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableExample(String example, String word) {
    // Parse example sentences - they are stored as "english sentence | russian translation"
    final parts = example.split('|');
    final englishSentence = parts.length > 0 ? parts[0].trim() : '';
    final russianTranslation = parts.length > 1 ? parts[1].trim() : word;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              englishSentence,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Manrope',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              russianTranslation,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Manrope',
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
