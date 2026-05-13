import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ImportDictionaryScreen extends StatefulWidget {
  const ImportDictionaryScreen({super.key});

  @override
  State<ImportDictionaryScreen> createState() => _ImportDictionaryScreenState();
}

class _ImportDictionaryScreenState extends State<ImportDictionaryScreen> {
  final Color orangeColor = const Color(0xFFDAA87D);
  final Color backgroundColor = const Color(0xFFEFEFEF);

  String? _selectedFilePath;
  String? _fileName;
  bool _isImporting = false;
  int _importProgress = 0;
  String _importStatus = '';

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _fileName = result.files.single.name;
          _importStatus = '';
          _importProgress = 0;
        });
      }
    } catch (e) {
      setState(() {
        _importStatus = 'Ошибка при выборе файла: $e';
      });
    }
  }

  Future<void> _importDictionary() async {
    if (_selectedFilePath == null) {
      setState(() {
        _importStatus = 'Пожалуйста, выберите файл для импорта';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _importProgress = 0;
    });

    // Имитация процесса импорта
    for (int i = 1; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _importProgress = i;
      });
    }

    setState(() {
      _isImporting = false;
      _importStatus = 'Словарь успешно импортирован!';
    });

    // Показываем диалог успеха
    if (mounted) {
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
              const Text('Успешно!'),
            ],
          ),
          content: const Text('Словарь был успешно импортирован в ваше приложение.'),
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
              child: const Text('К словарям', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showFormatHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Формат файла'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Поддерживаемые форматы:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFormatItem(
                'CSV',
                'Формат: слово,транскрипция,перевод,пример_en,пример_ru',
                'expensive,[ɪkˈspensɪv],дорогой,This car is expensive.,Эта машина дорогая.',
              ),
              const SizedBox(height: 12),
              _buildFormatItem(
                'TXT',
                'Формат: каждая строка - новое слово',
                'word - translation',
              ),
              const SizedBox(height: 12),
              _buildFormatItem(
                'JSON',
                'Формат: массив объектов',
                '[{"word": "expensive", "translation": "дорогой"}]',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatItem(String format, String description, String example) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(format, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              example,
              style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey.shade700),
            ),
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
          'Импорт словаря',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: orangeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.upload_file, color: orangeColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Импортировать словарь',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Загрузите слова из файла CSV, TXT или JSON',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // File selection card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Выберите файл',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          GestureDetector(
                            onTap: _showFormatHelp,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: orangeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.help_outline, color: orangeColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // File picker button
                      GestureDetector(
                        onTap: _isImporting ? null : _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedFilePath != null ? orangeColor : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedFilePath != null 
                                ? orangeColor.withOpacity(0.05) 
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFilePath != null ? Icons.insert_drive_file : Icons.add_box_outlined,
                                size: 48,
                                color: _selectedFilePath != null ? orangeColor : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedFilePath != null 
                                    ? 'Файл выбран'
                                    : 'Нажмите для выбора файла',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedFilePath != null 
                                      ? orangeColor 
                                      : Colors.grey.shade500,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              if (_fileName != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _fileName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      if (_importStatus.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _importStatus.contains('успешно') || _importStatus.contains('Успешно')
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _importStatus.contains('успешно') || _importStatus.contains('Успешно')
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _importStatus.contains('успешно') || _importStatus.contains('Успешно')
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _importStatus,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _importStatus.contains('успешно') || _importStatus.contains('Успешно')
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (_isImporting) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _importProgress / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Импорт: $_importProgress%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Import button
              Center(
                child: GestureDetector(
                  onTap: _isImporting ? null : _importDictionary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    decoration: BoxDecoration(
                      color: _isImporting ? Colors.grey.shade300 : orangeColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isImporting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(Icons.file_upload, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _isImporting ? 'Импорт...' : 'Импортировать',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
