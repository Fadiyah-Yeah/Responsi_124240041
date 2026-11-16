import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/news.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/bottom_nav.dart';
import 'detail_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().loadFavorites(context.read<AuthProvider>());
    });
  }

  void _tab(int index) {
    if (index == 1) return;
    final page = index == 0 ? const HomeScreen() : const ProfileScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty || isoDate == 'Unknown') return '-';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExplorerProvider, AuthProvider>(
      builder: (context, data, auth, _) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bookmark',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: data.loadingFavorites
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.sage),
              )
            : data.favorites.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 58,
                          color: AppColors.moss,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Belum ada bookmark',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Simpan berita dari halaman Home atau Detail.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final news = data.favorites[i];

                      return Dismissible(
                        key: ValueKey(news.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete_outline, color: Colors.white),
                            ],
                          ),
                        ),
                        onDismissed: (_) async {
                          await data.toggleFavorite(news, auth);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Berita dihapus dari Bookmark'),
                              backgroundColor: Colors.red.shade600,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: _BookmarkTile(
                          news: news,
                          formattedDate: _formatDate(news.published_at),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(news: news),
                              ),
                            );
                            if (!context.mounted) return;
                            // Refresh daftar saat kembali dari DetailScreen
                            // jaga-jaga jika user menghapus bookmark dari sana
                            data.loadFavorites(auth);
                          },
                          onRemove: () async {
                            await data.toggleFavorite(news, auth);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Berita dihapus dari Bookmark'),
                                backgroundColor: Colors.red.shade600,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        bottomNavigationBar: BottomNav(index: 1, onTap: _tab),
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final News news;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkTile({
    required this.news,
    required this.formattedDate,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sand),
        ),
        child: Row(
          children: [
            // Gambar Thumbnail Berita
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: news.image_url.isNotEmpty
                    ? Image.network(
                        news.image_url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.sand,
                          child: const Icon(Icons.broken_image, color: AppColors.muted),
                        ),
                      )
                    : Container(
                        color: AppColors.sand,
                        child: const Icon(Icons.article, color: AppColors.muted),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Sumber, Judul, & Tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.news_site,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 11, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol Hapus Alternatif selain Swipe
            IconButton(
              tooltip: 'Hapus Bookmark',
              onPressed: onRemove,
              icon: Icon(
                Icons.bookmark,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}