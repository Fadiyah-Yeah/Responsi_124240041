import 'package:flutter/foundation.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class ExplorerProvider extends ChangeNotifier {
  final _api = ApiService();

  List<News> news = [];
  List<News> favorites = [];

  bool loadingNews = false;
  bool loadingFavorites = false;
  bool hasMoreNews = true;

  int _newsPage = 1;
  String search = '';
  String site = 'All';
  String? error;

  // Alias agar tetap kompatibel jika ada widget lama yang memanggil status / filterStatus
  String get status => site;
  Future<void> filterStatus(String value) => filterSite(value);

  Future<void> loadNews({bool refresh = false}) async {
    if (loadingNews) return;
    if (refresh) {
      _newsPage = 1;
      hasMoreNews = true;
      news = [];
    }
    if (!hasMoreNews) return;

    loadingNews = true;
    error = null;
    notifyListeners();

    try {
      final data = await _api.news(
        page: _newsPage,
        limit: 12, // Memastikan minimal 10 berita tampil sejak awal
        title: search,
        newsSite: site,
      );

      final items = (data['results'] as List)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList();

      news = refresh ? items : [...news, ...items];

      // Spaceflight News API v4 menyimpan URL halaman berikutnya langsung di key 'next'
      hasMoreNews = data['next'] != null;
      _newsPage++;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loadingNews = false;
      notifyListeners();
    }
  }

  Future<void> searchNews(String value) async {
    search = value;
    await loadNews(refresh: true);
  }

  Future<void> filterSite(String value) async {
    site = value;
    await loadNews(refresh: true);
  }

  Future<void> loadFavorites(AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) {
      favorites = [];
      notifyListeners();
      return;
    }

    loadingFavorites = true;
    notifyListeners();

    try {
      // Membaca daftar berita bookmark langsung dari Local Database (SQLite)
      favorites = await DatabaseService.instance.getBookmarkedNews(user.id);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id) => favorites.any((e) => e.id == id);

  Future<void> toggleFavorite(News item, AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');

    final exists = isFavorite(item.id);

    // Optimistic UI update agar responsif seketika
    if (exists) {
      favorites.removeWhere((e) => e.id == item.id);
    } else {
      favorites.insert(0, item);
    }
    notifyListeners();

    try {
      if (exists) {
        await DatabaseService.instance.removeFavorite(user.id, item.id);
      } else {
        // Menyimpan seluruh data objek News ke SQLite
        await DatabaseService.instance.addFavorite(user.id, item);
      }
    } catch (e) {
      // Rollback jika gagal menulis ke database
      if (exists) {
        favorites.insert(0, item);
      } else {
        favorites.removeWhere((e) => e.id == item.id);
      }
      notifyListeners();
      rethrow;
    }
  }
}