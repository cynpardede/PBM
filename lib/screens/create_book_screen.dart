// lib/screens/create_book_screen.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'chapter_input_screen.dart';

// Definisi callback untuk memberitahu MainScreen bahwa buku telah dibuat
typedef OnBookCreated = void Function();

class CreateBookScreen extends StatefulWidget {
  final OnBookCreated onBookCreated;

  const CreateBookScreen({super.key, required this.onBookCreated});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _authorController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _startStory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newBook = Book(
        title: _titleController.text,
        summary: _summaryController.text,
        author: _authorController.text,
      );

      try {
        // 1. Kirim data buku ke API untuk mendapatkan book_id
        final bookId = await _apiService.createBook(newBook);
        
        // 2. Navigasi ke Chapter Input Page sambil membawa book_id
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterInputScreen(
              bookId: bookId,
              bookTitle: newBook.title,
              onPublish: widget.onBookCreated, // Callback ke MainScreen
            ),
          ),
        );
        
        // Bersihkan field setelah navigasi
        _titleController.clear();
        _summaryController.clear();
        _authorController.clear();

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create book: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Judul Buku
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title of the Book',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Ringkasan Buku (Summary)
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary / Synopsis',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a summary.';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Penulis (Author)
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the author name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Button Start Your Own Story
            ElevatedButton(
              onPressed: _isLoading ? null : _startStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary, // Orange
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Start Your Own Story',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}