import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/app_field.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/news_card.dart';
import '../widgets/site_filter.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().loadNews(refresh: true);
      context.read<ExplorerProvider>().loadFavorites(context.read<AuthProvider>());
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _tab(int index) {
    if (index == 0) return;
    final page = index == 1 ? const FavoriteScreen() : const ProfileScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExplorerProvider, AuthProvider>(
      builder: (context, data, auth, _) => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan username pengguna yang sedang login
              Text(
                'Hi, ${auth.currentUser?.username ?? 'Explorer'}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const Text(
                'Explore Spaceflight News',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          // Button pada bagian kanan AppBar yang mengarah ke halaman Bookmark
          actions: [
            IconButton(
              tooltip: 'Bookmark',
              icon: const Icon(Icons.bookmarks_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
              child: AppField(
                controller: search,
                label: 'Cari berita...',
                icon: Icons.search,
                onChanged: data.searchNews,
              ),
            ),
            // Pastikan nama getter & method di ExplorerProvider sesuai (misal: data.status & data.filterStatus)
            SiteFilter(selected: data.status, onSelected: data.filterStatus),
            const SizedBox(height: 8),
            Expanded(
              // Menampilkan loading indicator ketika data sedang dimuat
              child: data.loadingNews && data.news.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.sage),
                    )
                  : data.news.isEmpty
                      ? Center(
                          child: Text(data.error ?? 'Berita tidak ditemukan.'),
                        )
                      : RefreshIndicator(
                          color: AppColors.sage,
                          onRefresh: () => data.loadNews(refresh: true),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels >=
                                      n.metrics.maxScrollExtent - 180 &&
                                  data.hasMoreNews &&
                                  !data.loadingNews) {
                                data.loadNews();
                              }
                              return false;
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.all(14),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: data.news.length,
                              itemBuilder: (context, i) {
                                final item = data.news[i];
                                return NewsCard(
                                  news: item,
                                  favorite: data.isFavorite(item.id),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(news: item),
                                    ),
                                  ),
                                  onFavorite: () async {
                                    try {
                                      await data.toggleFavorite(item, auth);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNav(index: 0, onTap: _tab),
      ),
    );
  }
}