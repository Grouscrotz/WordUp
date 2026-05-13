import 'package:flutter/material.dart';

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

  void _nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isRevealed = false;
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

  String _highlightWordInText(String text, String word, bool isBold) {
    return text.replaceAllMapped(
      RegExp(word, caseSensitive: false),
      (match) => isBold ? '**${match.group(0)}**' : match.group(0)!,
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
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: (_currentWordIndex + 1) / _words.length,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  if (!isFirstWord)
                    Positioned(
                      right: 0,
                      top: -6,
                      bottom: -6,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black54),
                        onPressed: _prevWord,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                            Expanded(
                              child: Column(
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
                                    '${currentWord['dictionary']} - ${currentWord['category']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Silhouette image placeholder
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Word in bold
                        Center(
                          child: Text(
                            currentWord['word'] as String,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Transcription
                        Center(
                          child: Text(
                            currentWord['transcription'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Reveal button or translation list
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
                              // Translation in bold
                              Text(
                                currentWord['translation'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Example sentences list
                              ...(currentWord['examples'] as List<Map<String, String>>).asMap().entries.map((entry) {
                                final index = entry.key;
                                final example = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
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
              const SizedBox(height: 24),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isFirstWord ? null : _prevWord,
                      child: Opacity(
                        opacity: isFirstWord ? 0.5 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Я уже знаю слово',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _nextWord,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Начать учить это слово',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableExample(String english, String russian, String word) {
    return ExpansionTile(
      contentPadding: EdgeInsets.zero,
      collapsedIconColor: Colors.grey,
      iconColor: Colors.grey,
      leading: const Icon(Icons.chevron_right, size: 20),
      title: _buildHighlightedText(
        english,
        word,
        TextStyle(
          fontSize: 14,
          fontFamily: 'Manrope',
          color: Colors.grey.shade700,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 36, bottom: 8, right: 16),
          child: _buildHighlightedText(
            russian,
            word,
            TextStyle(
              fontSize: 14,
              fontFamily: 'Manrope',
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
