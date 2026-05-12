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
  bool _isFlipped = false;
  
  // Пример данных для слов
  final List<Map<String, String>> _words = [
    {'word': 'Achieve', 'translation': 'Достигать', 'example': 'She achieved her goal.'},
    {'word': 'Benefit', 'translation': 'Преимущество', 'example': 'The benefit of exercise is clear.'},
    {'word': 'Challenge', 'translation': 'Вызов', 'example': 'This is a big challenge.'},
    {'word': 'Develop', 'translation': 'Развивать', 'example': 'Develop your skills daily.'},
    {'word': 'Enable', 'translation': 'Позволять', 'example': 'This enables us to work faster.'},
  ];

  void _nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isFlipped = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _prevWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
        _isFlipped = false;
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
              // Progress bar
              LinearProgressIndicator(
                value: (_currentWordIndex + 1) / _words.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 24),
              
              // Word card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFlipped = !_isFlipped;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFlipped 
                                ? Icons.school 
                                : Icons.auto_awesome,
                              size: 48,
                              color: _isFlipped ? Colors.blue : Colors.green,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _isFlipped ? currentWord['translation']! : currentWord['word']!,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_isFlipped) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      currentWord['example']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Manrope',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            Text(
                              _isFlipped ? 'Нажмите, чтобы продолжить' : 'Нажмите, чтобы увидеть перевод',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFirstWord ? null : _prevWord,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Назад'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextWord,
                      icon: Icon(isLastWord ? Icons.check : Icons.arrow_forward),
                      label: Text(isLastWord ? 'Готово' : 'Далее'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
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
}
