import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class DetailBookScreen extends StatefulWidget {
  final int bookId;

  const DetailBookScreen({super.key, required this.bookId});

  @override
  State<DetailBookScreen> createState() => _DetailBookScreenState();
}

class _DetailBookScreenState extends State<DetailBookScreen> {
  late Future<Book> _bookDetailFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _bookDetailFuture = _apiService.fetchBookDetail(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: FutureBuilder<Book>(
        future: _bookDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final book = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'by ${book.author}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(book.summary),
                const Divider(height: 32),

                const Text(
                  'Chapters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (book.chapters.isEmpty)
                  const Text(
                    'No chapters available.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),

                ...book.chapters.map((chapter) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(chapter.chapterNumber.toString()),
                        ),
                        title: Text('Chapter ${chapter.chapterNumber}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  'Chapter ${chapter.chapterNumber}'),
                              content: SingleChildScrollView(
                                child: Text(chapter.content),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Close'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
