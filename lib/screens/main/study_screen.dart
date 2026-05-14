import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import 'learn_screen.dart';
import 'review_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  int _wordsLearnedToday = 0;
  int _learningStreak = 0;
  int _recordStreak = 0;
  int _totalWordsLearned = 0;

  int _getCurrentWeekdayIndex() {
    return DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interval Repetition Section
              const Text(
                'Интервальное повторение',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 12),
              
              // Combined Card for Categories, Learn New Words, and Review Words
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Selected Categories Card
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showCategorySelectionDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${provider.selectedDictionaryIds.length} выбрано',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<List<Dictionary>>(
                                      future: _getSelectedDictionaries(provider),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return Text(
                                            'Выберите словари для изучения',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          );
                                        }
                                        final names = snapshot.data!.map((d) => d.name).take(3).join(', ');
                                        return Text(
                                          names,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (provider.selectedDictionaryIds.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSmallDictionaryIcon(Icons.book, Colors.green),
                                    const SizedBox(width: 8),
                                    if (provider.selectedDictionaryIds.length > 1)
                                      _buildSmallDictionaryIcon(Icons.menu_book, Colors.blue),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // Learn New Words Card
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (provider.selectedDictionaryIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Сначала выберите словари для изучения')),
                            );
                            return;
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LearnScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_outlined, color: Colors.green, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Учить новые слова',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Выучено сегодня $_wordsLearnedToday из ${provider.settings.maxNewWordsPerDay}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // Review Words Card
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (provider.selectedDictionaryIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Сначала выберите словари для изучения')),
                            );
                            return;
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReviewScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.refresh_outlined, color: Colors.orange, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Повторить слова',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<int>(
                                      future: _getReviewCount(provider),
                                      builder: (context, snapshot) {
                                        final count = snapshot.data ?? 0;
                                        return Text(
                                          'Слов для повторения: $count',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Statistics Section
              const Text(
                'Статистика',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      // Week days
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeekDay('Пн', 0),
                          _buildWeekDay('Вт', 1),
                          _buildWeekDay('Ср', 2),
                          _buildWeekDay('Чт', 3),
                          _buildWeekDay('Пт', 4),
                          _buildWeekDay('Сб', 5),
                          _buildWeekDay('Вс', 6),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Learning streak cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Вы учите слова',
                              '$_learningStreak дней',
                              Icons.local_fire_department,
                              orangeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Рекорд',
                              '$_recordStreak дней',
                              Icons.emoji_events,
                              Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Divider
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 16),
                      
                      // Words learned today with edit button
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Выучено слов сегодня',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_wordsLearnedToday / ${provider.settings.maxNewWordsPerDay}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showMaxWordsDialog(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: orangeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.edit, color: orangeColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Dictionary>> _getSelectedDictionaries(AppProvider provider) async {
    final allDicts = provider.dictionaries;
    return allDicts.where((d) => provider.selectedDictionaryIds.contains(d.id)).toList();
  }

  Future<int> _getReviewCount(AppProvider provider) async {
    final words = await provider.getWordsForReview();
    return words.length;
  }

  Widget _buildSmallDictionaryIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildWeekDay(String day, int weekdayIndex) {
    final currentWeekdayIndex = _getCurrentWeekdayIndex();
    final isCurrent = weekdayIndex == currentWeekdayIndex;
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrent ? orangeColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isCurrent ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите словари'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('New General Service List'),
              value: true,
              onChanged: (value) {},
              activeColor: orangeColor,
            ),
            CheckboxListTile(
              title: const Text('Oxford 3000&5000'),
              value: true,
              onChanged: (value) {},
              activeColor: orangeColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showMaxWordsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Максимум слов в день'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$_maxWordsPerDay',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Лимит обновлён')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
