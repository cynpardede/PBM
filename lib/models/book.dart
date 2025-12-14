// lib/models/book.dart
import 'chapter.dart';

class Book {
  final int? id;
  final String title;
  final String summary;
  final String author;
  final String? createdAt;
  final List<Chapter> chapters;

  Book({
    this.id,
    required this.title,
    required this.summary,
    required this.author,
    this.createdAt,
    this.chapters = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var chaptersList = json['chapters'] as List?;
    List<Chapter> chaptersData = chaptersList != null
        ? chaptersList.map((i) => Chapter.fromJson(i)).toList()
        : [];

    return Book(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      title: json['title'] as String,
      summary: json['summary'] as String,
      author: json['author'] as String,
      createdAt: json['created_at'] as String?,
      chapters: chaptersData,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'author': author,
    };
  }
}