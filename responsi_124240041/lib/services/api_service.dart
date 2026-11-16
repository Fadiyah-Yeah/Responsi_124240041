import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class ApiService {
  static const base = 'https://api.spaceflightnewsapi.net/v4/articles';

  Future<Map<String, dynamic>> news({
    int page = 1,
    int limit = 12, // Memastikan minimal 10 berita tampil
    String title = '',
    String newsSite = 'All',
  }) async {
    final offset = (page - 1) * limit;
    final q = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };

    if (title.trim().isNotEmpty) q['title_contains'] = title.trim();
    if (newsSite != 'All' && newsSite.isNotEmpty) q['news_site'] = newsSite;

    final r = await http.get(Uri.parse(base).replace(queryParameters: q));
    if (r.statusCode == 404) return {'results': [], 'next': null};
    if (r.statusCode != 200) {
      throw Exception('Gagal mengambil berita. Periksa koneksi internet.');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<News>> newsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    // Spaceflight News v4 mendukung filter berdasarkan daftar ID jika diperlukan,
    // atau ambil satu per satu secara paralel
    final futures = ids.map((id) async {
      final r = await http.get(Uri.parse('$base/$id'));
      if (r.statusCode == 200) {
        return News.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return null;
    });
    final results = await Future.wait(futures);
    return results.whereType<News>().toList();
  }
}