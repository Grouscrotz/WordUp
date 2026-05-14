import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

/// Экран редактирования словарей
/// Позволяет пользователю создавать, редактировать и удалять свои словари
class EditDictionariesScreen extends StatefulWidget {
  const EditDictionariesScreen({super.key});

  @override
  State<EditDictionariesScreen> createState() => _EditDictionariesScreenState();
}

class _EditDictionariesScreenState extends State<EditDictionariesScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);
  
  bool _isLoading = true;
  List<Dictionary> _userDictionaries = [];
  int? _expandedDictIndex;
  
  @override
  void initState() {
    super.initState();
    _loadDictionaries();
  }
  
  Future<void> _loadDictionaries() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    _userDictionaries = await provider.getUserDictionaries();
    setState(() => _isLoading = false);
  }
  
  void _showAddDictionaryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final languageFromController = TextEditingController(text: 'Русский');
    final languageToController = TextEditingController(text: 'Английский');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Новый словарь'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например: Мои слова',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Краткое описание словаря',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: languageFromController,
                      decoration: const InputDecoration(
                        labelText: 'С языка',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: languageToController,
                      decoration: const InputDecoration(
                        labelText: 'На язык',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final provider = Provider.of<AppProvider>(context, listen: false);
                final newDict = Dictionary(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  totalWords: 0,
                  learnedWords: 0,
                  languageFrom: languageFromController.text,
                  languageTo: languageToController.text,
                  isPreset: false,
                  createdAt: DateTime.now(),
                );
                await provider.createDictionary(newDict);
                await _loadDictionaries();
                Navigator.pop(context);
                
                // Показать сообщение об успехе
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Словарь успешно создан'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Создать', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showEditDictionaryDialog(Dictionary dictionary) {
    final nameController = TextEditingController(text: dictionary.name);
    final descriptionController = TextEditingController(text: dictionary.description);
    final languageFromController = TextEditingController(text: dictionary.languageFrom);
    final languageToController = TextEditingController(text: dictionary.languageTo);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Редактировать словарь'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: languageFromController,
                      decoration: const InputDecoration(
                        labelText: 'С языка',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: languageToController,
                      decoration: const InputDecoration(
                        labelText: 'На язык',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final provider = Provider.of<AppProvider>(context, listen: false);
                final updatedDict = dictionary.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  languageFrom: languageFromController.text,
                  languageTo: languageToController.text,
                  updatedAt: DateTime.now(),
                );
                await provider.updateDictionary(updatedDict);
                await _loadDictionaries();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Словарь обновлён'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteDictionary(Dictionary dictionary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Удалить словарь?'),
        content: Text(
          'Вы уверены, что хотите удалить словарь "${dictionary.name}"? Все слова в этом словаре также будут удалены.',
          style: const TextStyle(fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final provider = Provider.of<AppProvider>(context, listen: false);
              await provider.deleteDictionary(dictionary.id);
              await _loadDictionaries();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Словарь удалён'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
          'Редактирование словарей',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
            onPressed: _showAddDictionaryDialog,
            tooltip: 'Добавить словарь',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userDictionaries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 24),
                      const Text(
                        'Нет пользовательских словарей',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Создайте свой первый словарь',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _showAddDictionaryDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Создать словарь', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userDictionaries.length,
                  itemBuilder: (context, index) {
                    final dictionary = _userDictionaries[index];
                    final isExpanded = _expandedDictIndex == index;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: orangeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: orangeColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              dictionary.name,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${dictionary.totalWords} слов • ${dictionary.languageFrom} → ${dictionary.languageTo}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _expandedDictIndex = isExpanded ? null : index;
                                    });
                                  },
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditDictionaryDialog(dictionary);
                                    } else if (value == 'delete') {
                                      _confirmDeleteDictionary(dictionary);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20, color: Colors.orange),
                                          SizedBox(width: 8),
                                          Text('Редактировать'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Удалить'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1, indent: 72),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (dictionary.description.isNotEmpty) ...[
                                    Text(
                                      dictionary.description,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatItem(
                                          'Всего слов',
                                          dictionary.totalWords.toString(),
                                          Icons.list_alt,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStatItem(
                                          'Изучено',
                                          dictionary.learnedWords.toString(),
                                          Icons.check_circle_outline,
                                          isComplete: dictionary.learnedWords > 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Создан: ${_formatDate(dictionary.createdAt)}',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (dictionary.updatedAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Обновлён: ${_formatDate(dictionary.updatedAt!)}',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, {bool isComplete = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isComplete ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isComplete ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
