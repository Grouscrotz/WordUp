import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/dictionaries_screen.dart';
import 'screens/main/study_screen.dart';
import 'screens/main/settings_screen.dart';
import 'screens/main/learn_screen.dart';
import 'screens/main/review_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация базы данных
  final dbService = DatabaseService();
  await dbService.database;
  
  // Очищаем базу данных для пересоздания с новыми данными (для отладки)
  await dbService.clearDatabase();
  
  await dbService.initializePresetDictionaries();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WordUpApp(),
    ),
  );
}

class WordUpApp extends StatelessWidget {
  const WordUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'WordUp',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: provider.settings.darkTheme ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/study-session') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => StudySessionScreen(
                  mode: args?['mode'] ?? 'new',
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class StudySessionScreen extends StatelessWidget {
  final String mode;

  const StudySessionScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == 'new' ? 'Новые слова' : 'Повторение'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode == 'new' ? Icons.auto_awesome : Icons.refresh,
              size: 80,
              color: mode == 'new' ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              mode == 'new' ? 'Режим изучения новых слов' : 'Режим повторения',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Здесь будет интерфейс для изучения слов\nс карточками и оценкой запоминания',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться назад'),
            ),
          ],
        ),
      ),
    );
  }
}
