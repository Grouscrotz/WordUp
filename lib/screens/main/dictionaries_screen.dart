import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class DictionariesScreen extends StatefulWidget {
  const DictionariesScreen({super.key});

  @override
  State<DictionariesScreen> createState() => _DictionariesScreenState();
}

class _DictionariesScreenState extends State<DictionariesScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  int _expandedDictIndex = -1;
  final List<Map<String, dynamic>> _userCategories = [
    {'name': 'Свои слова', 'icon': Icons.bookmark_outline},
  ];

  // Пример данных для предзаполненных словарей
  final List<Map<String, dynamic>> _presetDictionaries = [
    {
      'name': 'New General Service List',
      'icon': Icons.library_books_outlined,
      'categories': [
        {'name': 'Анатомия', 'count': 130},
        {'name': 'Археология', 'count': 85},
        {'name': 'География', 'count': 210},
      ],
    },
    {
      'name': 'Oxford 3000&5000',
      'icon': Icons.school_outlined,
      'categories': [
        {'name': 'Oxford 3000', 'count': 3000},
        {'name': 'Oxford 5000', 'count': 5000},
      ],
    },
  ];

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Новая категория'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Название категории',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _userCategories.add({
                    'name': controller.text,
                    'icon': Icons.folder_outlined,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Словари',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Logic for import
                    },
                    child: Text(
                      'Импортировать',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        color: orangeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Искать слова',
                    hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Manrope'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // User Categories CardView (Combined)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: Colors.black54),
                      title: const Text('Добавить категорию', style: TextStyle(fontFamily: 'Manrope')),
                      onTap: _showAddCategoryDialog,
                    ),
                    const Divider(height: 1, margin: EdgeInsets.symmetric(horizontal: 16)),
                    ..._userCategories.map((cat) => ListTile(
                      leading: Icon(cat['icon'] as IconData, color: Colors.black54),
                      title: Text(cat['name'] as String, style: const TextStyle(fontFamily: 'Manrope')),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Predefined Dictionaries CardView
              ..._presetDictionaries.asMap().entries.map((entry) {
                final index = entry.key;
                final dict = entry.value;
                final isExpanded = _expandedDictIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(dict['icon'] as IconData, color: Colors.black54, size: 24),
                        title: Text(dict['name'] as String, style: const TextStyle(fontFamily: 'Manrope')),
                        trailing: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            _expandedDictIndex = isExpanded ? -1 : index;
                          });
                        },
                      ),
                      if (isExpanded) ...[
                        const Divider(height: 1),
                        ...(dict['categories'] as List<Map<String, dynamic>>).map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_open, size: 20, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['name'] as String,
                                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${category['count']} слов',
                                        style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Manrope'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                );
              }).toList(),
              
              const Spacer(),

              // Add Word Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Logic to add word
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '+ Слово',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: orangeColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Словари'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'Учить'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Настройки'),
        ],
      ),
    );
  }
}
