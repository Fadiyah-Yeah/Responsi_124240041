import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class ApiService {
  static const base = 'https://api.spaceflightnewsapi.net/v4/articles';

  Future<Map<String, dynamic>> news({
    int page = 1, String title = '', String news_site = 'All',
  }) async {
    final q = <String, String>{'page': '$page'};
    if (title.trim().isNotEmpty) q['title'] = title.trim();
    if (news_site != 'All') q['news_site'] = news_site.toLowerCase();
    final r = await http.get(Uri.parse('$base/news').replace(queryParameters: q));
    if (r.statusCode == 404) return {'results': [], 'info': {'next': null}};
    if (r.statusCode != 200) throw Exception('Gagal mengambil berita. Periksa internet.');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<News>> newsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final r = await http.get(Uri.parse('$base/news/${ids.join(',')}'));
    if (r.statusCode != 200) throw Exception('Gagal memuat favorite.');
    final decoded = jsonDecode(r.body);
    final list = decoded is List ? decoded : [decoded];
    return list.map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
  }
}