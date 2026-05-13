import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  String _quietModeStart = '22:00';
  String _quietModeEnd = '08:00';
  String _notificationFrequency = 'Раз в 2 часа';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.person, size: 48, color: orangeColor),
              ),
              const SizedBox(height: 12),
              Text(
                user?.email ?? 'user@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Appearance Section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Внешний вид',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showThemeDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.palette_outlined, color: Colors.purple, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Тема',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Как в системе',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: orangeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.language_outlined, color: Colors.blue, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Язык интерфейса',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Как в системе',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: orangeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Notifications Section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Уведомления',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _notificationsEnabled = !_notificationsEnabled;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_outlined, color: Colors.green, size: 24),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Включить уведомления',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _notificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                },
                                activeColor: orangeColor,
                                activeTrackColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showQuietModeDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.bedtime_outlined, color: Colors.indigo, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Тихий режим',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_quietModeStart - $_quietModeEnd',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: orangeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showNotificationFrequencyDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.orange, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ограничить частоту уведомлений',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _notificationFrequency,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: orangeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Account Section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Аккаунт',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _confirmLogout(context, provider);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_outlined, color: Colors.red, size: 24),
                              const SizedBox(width: 16),
                              const Text(
                                'Выйти из аккаунта',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _confirmResetProgress(context, provider);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever_outlined, color: Colors.grey, size: 24),
                              const SizedBox(width: 16),
                              const Text(
                                'Сбросить весь прогресс',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
              
              // Additional info
              Center(
                child: Text(
                  'WordUp v1.0.0',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Светлая'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Тёмная'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Как в системе'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Русский'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('English'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Español'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showQuietModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тихий режим'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Начало', hintText: '22:00'),
              onChanged: (value) => _quietModeStart = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Конец', hintText: '08:00'),
              onChanged: (value) => _quietModeEnd = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: orangeColor),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showNotificationFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Частота уведомлений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Раз в 30 минут'),
              onTap: () {
                setState(() => _notificationFrequency = 'Раз в 30 минут');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Раз в час'),
              onTap: () {
                setState(() => _notificationFrequency = 'Раз в час');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Раз в 2 часа'),
              onTap: () {
                setState(() => _notificationFrequency = 'Раз в 2 часа');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Раз в 4 часа'),
              onTap: () {
                setState(() => _notificationFrequency = 'Раз в 4 часа');
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
        content: const Text('Вы уверены? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              provider.resetProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Прогресс сброшен')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
