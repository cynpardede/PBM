// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/chapter.dart';

class ApiService {
  // PENTING: Gunakan 10.0.2.2 jika menggunakan Emulator Android, atau IP LAN jika HP Fisik.
  // Gunakan localhost jika menjalankan di browser (Chrome/Web).
  final String baseUrl = 'http://192.168.100.192/seebook_api'; 

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/book_api.php?action=read_all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((bookJson) => Book.fromJson(bookJson)).toList();
      } else {
        return []; 
      }
    } else {
      throw Exception('Failed to load books. Status code: ${response.statusCode}');
    }
  }

  Future<int> createBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book_api.php?action=create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return int.parse(data['book_id'].toString());
      } else {
        throw Exception('Failed to create book: ${data['message']}');
      }
    } else {
      throw Exception('Failed to send request. Status code: ${response.statusCode}');
    }
  }

  Future<int> createChapter(int bookId, String content) async {
    final chapterData = {'book_id': bookId, 'content': content};
    
    final response = await http.post(
      Uri.parse('$baseUrl/chapter_api.php?action=create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(chapterData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return int.parse(data['chapter_number'].toString());
      } else {
        throw Exception('Failed to create chapter: ${data['message']}');
      }
    } else {
      throw Exception('Failed to send request. Status code: ${response.statusCode}');
    }
  }
  
  // FUNGSI fetchBookDetail DITEMPATKAN DENGAN BENAR DI DALAM CLASS
  Future<Book> fetchBookDetail(int bookId) async {
    // Menggunakan action=read_detail dan book_id sebagai parameter GET
    final response = await http.get(Uri.parse('$baseUrl/book_api.php?action=read_detail&book_id=$bookId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is Map) {
        // Menggunakan Book.fromJson untuk memproses data['data']
        return Book.fromJson(data['data']);
      } else {
        // Jika API PHP merespons success: false atau data tidak ditemukan
        throw Exception('Book not found: ${data['message'] ?? 'Unknown error'}');
      }
    } else {
      // Jika terjadi error HTTP (misalnya 404, 500)
      throw Exception('Failed to load book detail. Status code: ${response.statusCode}');
    }
  }
} // KURUNG KURAWAL PENUTUP CLASS HANYA ADA DI AKHIR