import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final wordsForReview = provider.getWordsForReview();
    final newWords = provider.getNewWords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учить'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Section
            _buildStatisticsSection(context, provider),
            const SizedBox(height: 24),
            
            // Study Options
            Text(
              'Режимы обучения',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Learn New Words Card
            _buildStudyOptionCard(
              context,
              icon: Icons.auto_awesome,
              color: Colors.green,
              title: 'Учить новые слова',
              subtitle: '${newWords.length} слов доступно',
              count: newWords.length,
              onTap: () => _startLearning(context, 'new'),
            ),
            const SizedBox(height: 12),
            
            // Review Words Card
            _buildStudyOptionCard(
              context,
              icon: Icons.refresh,
              color: Colors.orange,
              title: 'Повторять слова',
              subtitle: '${wordsForReview.length} слов на повторение',
              count: wordsForReview.length,
              onTap: () => _startLearning(context, 'review'),
            ),
            const SizedBox(height: 24),
            
            // Dictionary Selection
            Text(
              'Выберите словарь',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...provider.dictionaries.map((dict) => 
              _buildDictionaryCard(context, dict),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '${provider.totalWordsLearned}',
                label: 'Слов изучено',
              ),
              _buildStatItem(
                icon: Icons.repeat,
                value: '${provider.totalReviewsCompleted}',
                label: 'Повторений',
              ),
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: '${provider.currentStreak}',
                label: 'Дней подряд',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStudyOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: count > 0 ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  'Нет слов',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDictionaryCard(BuildContext context, dynamic dict) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.menu_book, color: Colors.blue.shade700),
        ),
        title: Text(dict.name),
        subtitle: Text('${dict.learnedWords}/${dict.totalWords} слов'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDictionaryOptions(context, dict),
      ),
    );
  }

  void _startLearning(BuildContext context, String mode) {
    Navigator.pushNamed(context, '/study-session', arguments: {'mode': mode});
  }

  void _showDictionaryOptions(BuildContext context, dynamic dict) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Учить новые слова'),
              onTap: () {
                Navigator.pop(context);
                _startLearning(context, 'new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Повторить слова'),
              onTap: () {
                Navigator.pop(context);
                _startLearning(context, 'review');
              },
            ),
          ],
        ),
      ),
    );
  }
}
