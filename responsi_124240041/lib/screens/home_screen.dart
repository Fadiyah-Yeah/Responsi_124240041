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
      context
          .read<ExplorerProvider>()
          .loadFavorites(context.read<AuthProvider>());
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
  Widget build(BuildContext context) =>
      Consumer2<ExplorerProvider, AuthProvider>(
        builder: (context, data, auth, _) => Scaffold(
          appBar: AppBar(
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hi, ${auth.currentUser?.username ?? 'Explorer'}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Text('Explore the Rick & Morty universe',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
              child: AppField(
                controller: search,
                label: 'Cari berita...',
                icon: Icons.search,
                onChanged: data.searchNews,
              ),
            ),
            //SiteFilter(selected: data.site, onSelected: data.filterSite),
            const SizedBox(height: 8),
            Expanded(
              child: data.loadingNews && data.news.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.sage))
                  : data.news.isEmpty
                      ? Center(
                          child: Text(data.error ?? 'Berita tidak ditemukan.'))
                      : NotificationListener<ScrollNotification>(
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
                              childAspectRatio: .88,
                            ),
                            itemCount: data.news.length,
                            itemBuilder: (context, i) {
                              final c = data.news[i];
                              return NewsCard(
                                news: c,
                                favorite: data.isFavorite(c.id),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DetailScreen(news: c))),
                                onFavorite: () async {
                                  try {
                                    await data.toggleFavorite(c, auth);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())));
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ),
          ]),
          bottomNavigationBar: BottomNav(index: 0, onTap: _tab),
        ),
      );
}
