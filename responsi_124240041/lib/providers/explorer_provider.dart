import 'package:flutter/foundation.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class ExplorerProvider extends ChangeNotifier {
  final _api = ApiService();
  List<News> news = [];
  List<News> favorites = [];
  bool loadingNews = false, loadingFavorites = false, loadingEpisodes = false;
  bool hasMoreNews = true, hasMoreEpisodes = true;
  int _newsPage = 1;
  String search = '', status = 'All';
  String? error;

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
      final data = await _api.news(page: _newsPage, title: search, news_site: status);
      final items = (data['results'] as List)
          .map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
      news = refresh ? items : [...news, ...items];
      hasMoreNews = data['info']?['next'] != null;
      _newsPage++;
    } catch (e) {
      error = e.toString();
    } finally {
      loadingNews = false;
      notifyListeners();
    }
  }

  Future<void> searchNews(String value) async {
    search = value;
    await loadNews(refresh: true);
  }

  Future<void> filterStatus(String value) async {
    status = value;
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
      final ids = await DatabaseService.instance.favoriteIds(user.id);
      favorites = await _api.newsByIds(ids);
    } catch (e) {
      error = e.toString();
    } finally {
      loadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(int id) => favorites.any((e) => e.id == id);

  Future<void> toggleFavorite(News news, AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');
    final exists = isFavorite(news.id);
    if (exists) {
      favorites.removeWhere((e) => e.id == news.id);
    } else {
      favorites.insert(0, news);
    }
    notifyListeners();
    try {
      if (exists) {
        await DatabaseService.instance.removeFavorite(user.id, news.id);
      } else {
        await DatabaseService.instance.addFavorite(user.id, news.id);
      }
    } catch (e) {
      if (exists) {
        favorites.add(news);
      } else {
        favorites.removeWhere((e) => e.id == news.id);
      }
      notifyListeners();
      rethrow;
    }
  }
}