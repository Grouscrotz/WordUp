import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<int> _intervals = [1, 3, 7, 14, 30];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionTitle('Внешний вид'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Тёмная тема'),
                  subtitle: const Text('Использовать тёмную тему оформления'),
                  value: settings.darkTheme,
                  onChanged: (value) {
                    provider.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Язык интерфейса'),
                  subtitle: Text(_getLanguageName(settings.interfaceLanguage)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionTitle('Уведомления'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Уведомления о повторении'),
              subtitle: const Text('Напоминать о необходимости повторения слов'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                provider.toggleNotifications();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Spaced Repetition Section
          _buildSectionTitle('Интервалы повторения'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Настройте интервалы между повторениями (в днях)',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ..._intervals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final interval = entry.value;
                    return Row(
                      children: [
                        Text(
                          'Повторение #${index + 1}:',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: interval.toDouble(),
                            min: 1,
                            max: 90,
                            divisions: 89,
                            label: '$interval дн.',
                            onChanged: (value) {
                              setState(() {
                                _intervals[index] = value.round();
                              });
                            },
                          ),
                        ),
                        Text(
                          '$interval дн.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.updateReviewIntervals(_intervals);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Интервалы сохранены')),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить интервалы'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionTitle('Данные'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Экспорт данных'),
                  subtitle: const Text('Сохранить прогресс в файл'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функция в разработке')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Импорт данных'),
                  subtitle: const Text('Загрузить прогресс из файла'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Функция в разработке')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Сбросить прогресс',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Удалить весь прогресс обучения'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _confirmResetProgress(context, provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionTitle('Аккаунт'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text(
                'Выйти из аккаунта',
                style: TextStyle(color: Colors.orange),
              ),
              subtitle: Text(provider.currentUser?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmLogout(context, provider),
            ),
          ),
          const SizedBox(height: 16),

          // App Info
          Center(
            child: Text(
              'WordUp v1.0.0',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'Русский';
    }
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                provider.setInterfaceLanguage('ru');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                provider.setInterfaceLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Español'),
              onTap: () {
                provider.setInterfaceLanguage('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Deutsch'),
              onTap: () {
                provider.setInterfaceLanguage('de');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetProgress(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс прогресса'),
        content: const Text(
          'Вы уверены? Это действие нельзя отменить. Весь ваш прогресс будет удалён.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Прогресс сброшен')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
