import 'package:flutter/material.dart';

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
  bool _isImageRevealed = false;
  
  // Интервалы повторения в днях для разных уровней сложности
  final Map<String, int> _repetitionIntervals = {
    'easy': 4,      // Легко - следующий повтор через 4 дня
    'normal': 2,    // Нормально - через 2 дня
    'hard': 1,      // Сложно - через 1 день
  };
  
  // Пример данных для слов
  final List<Map<String, dynamic>> _words = [
    {
      'word': 'Expensive',
      'transcription': "[ik'speniv]",
      'translation': 'дорогой (по цене)',
      'dictionary': 'Oxford 3000 & 5000',
      'category': 'А1',
      'examples': [
        {'en': 'This car is too expensive for me.', 'ru': 'Эта машина слишком дорогая для меня.'},
        {'en': 'The restaurant was expensive but good.', 'ru': 'Ресторан был дорогим, но хорошим.'},
      ],
    },
    {
      'word': 'Beautiful',
      'transcription': "['bju:tifl]",
      'translation': 'красивый',
      'dictionary': 'Oxford 3000 & 5000',
      'category': 'А2',
      'examples': [
        {'en': 'She has a beautiful voice.', 'ru': 'У неё красивый голос.'},
        {'en': 'The view was beautiful.', 'ru': 'Вид был красивым.'},
      ],
    },
    {
      'word': 'Interesting',
      'transcription': "['intristɪŋ]",
      'translation': 'интересный',
      'dictionary': 'New General Service List',
      'category': 'B1',
      'examples': [
        {'en': 'This is an interesting book.', 'ru': 'Это интересная книга.'},
        {'en': 'I find history very interesting.', 'ru': 'Я нахожу историю очень интересной.'},
      ],
    },
  ];

  void _handleDifficultySelection(String difficulty) {
    debugPrint('Слово "${_words[_currentWordIndex]['word']}" оценено как: $difficulty');
    debugPrint('Следующее повторение через: ${_repetitionIntervals[difficulty]} дн.');
    
    _nextWord();
  }

  void _sendToReview() {
    debugPrint('Слово отправлено в конец колоды для повторения');
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

  Widget _buildHighlightedText(String text, String word, TextStyle style) {
    final pattern = RegExp('(${word})', caseSensitive: false);
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
                                  'Повторение',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${currentWord['dictionary']} - ${currentWord['category']}',
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
                        
                        // Image and word info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Text(
                              currentWord['word'] as String,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentWord['transcription'] as String,
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
                              const Divider(height: 1, thickness: 1),
                              const SizedBox(height: 16),
                              Text(
                                currentWord['translation'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              ...(currentWord['examples'] as List<Map<String, String>>).asMap().entries.map((entry) {
                                final index = entry.key;
                                final example = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildExpandableExample(
                                    example['en']!,
                                    example['ru']!,
                                    currentWord['word'] as String,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // CardView оценки сложности вспоминания (для повторения - всегда виден)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок
                    const Text(
                      'Как сложно было вспомнить?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Кнопка "Показать снова" справа в углу (под заголовком)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
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
                    ),
                    const SizedBox(height: 8),
                    // Кнопки сложности на всю ширину (уменьшенные)
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
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

  Widget _buildExpandableExample(String english, String russian, String word) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.grey,
        iconColor: Colors.grey,
        trailing: const SizedBox.shrink(),
        leading: const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        title: Align(
          alignment: Alignment.centerLeft,
          child: _buildHighlightedText(
            english,
            word,
            const TextStyle(
              fontSize: 15,
              fontFamily: 'Manrope',
              color: Colors.black87,
            ),
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildHighlightedText(
                russian,
                word,
                const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: EdgeInsets.zero,
      ),
    );
  }
}
