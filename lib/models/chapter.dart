// lib/models/chapter.dart
class Chapter {
  final int? id;
  final int bookId;
  final int chapterNumber;
  final String content;

  Chapter({
    this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      bookId: int.parse(json['book_id'].toString()),
      chapterNumber: int.parse(json['chapter_number'].toString()),
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'content': content,
    };
  }
}