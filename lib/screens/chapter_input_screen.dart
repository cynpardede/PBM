// lib/screens/chapter_input_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_book_screen.dart';

class ChapterInputScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  final OnBookCreated onPublish; // Callback untuk refresh Home Page

  const ChapterInputScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.onPublish,
  });

  @override
  State<ChapterInputScreen> createState() => _ChapterInputScreenState();
}

class _ChapterInputScreenState extends State<ChapterInputScreen> {
  final _contentController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;
  int _currentChapterNumber = 0;

  @override
  void initState() {
    super.initState();
    // Bab awal dimulai dari 0, setelah simpan pertama akan menjadi Bab 1.
  }

  Future<void> _saveChapter(bool isPublishing) async {
    if (_contentController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter content cannot be empty.')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newChapterNum = await _apiService.createChapter(
        widget.bookId,
        _contentController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chapter $newChapterNum saved successfully!')),
        );
        _currentChapterNumber = newChapterNum;
        _contentController.clear(); // Clear area input
      }

      if (isPublishing) {
        // 1. Panggil callback untuk refresh Home Page
        widget.onPublish();
        // 2. Kembali ke MainScreen
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save chapter: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing: ${widget.bookTitle}', style: const TextStyle(fontSize: 16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chapter Number Display
            Text(
              _currentChapterNumber == 0 
                ? 'Start Chapter 1' 
                : 'Current Chapter: ${_currentChapterNumber + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 10),

            // Input Area
            Expanded(
              child: TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Start writing your story here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null, // Membuatnya multi-line
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi (+Chapter dan Publish)
            Row(
              children: [
                // + Chapter (Simpan dan Lanjutkan Bab Baru)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('+ Chapter', style: TextStyle(color: Colors.white)),
                    onPressed: _isSaving ? null : () => _saveChapter(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Merah
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Publish (Simpan Bab Terakhir dan Kembali ke Home)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Publish', style: TextStyle(color: Colors.white)),
                    onPressed: _isSaving ? null : () => _saveChapter(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary, // Orange
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}