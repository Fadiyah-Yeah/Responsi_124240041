import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../models/news.dart';
import '../providers/auth_provider.dart';
import '../providers/explorer_provider.dart';

class DetailScreen extends StatelessWidget {
  final News news;
  const DetailScreen({super.key, required this.news});

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty || isoDate == 'Unknown') return '-';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
    } catch (_) {
      return isoDate.split('T').first;
    }
  }

  Future<void> _openBrowser(BuildContext context, String urlString) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan artikel tidak tersedia.')),
      );
      return;
    }
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka browser.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Consumer2<ExplorerProvider, AuthProvider>(
        builder: (context, data, auth, _) {
          final isBookmarked = data.isFavorite(news.id);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Detail Berita'),
              actions: [
                IconButton(
                  tooltip: isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
                  onPressed: () async {
                    final wasBookmarked = isBookmarked;
                    try {
                      await data.toggleFavorite(news, auth);
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasBookmarked
                                ? 'Berita dihapus dari Bookmark'
                                : 'Berita ditambahkan ke Bookmark',
                          ),
                          backgroundColor:
                              wasBookmarked ? Colors.red.shade600 : Colors.green.shade600,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red.shade600,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.green.shade600 : AppColors.ink,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Gambar Berita
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: news.image_url.isNotEmpty
                        ? Image.network(
                            news.image_url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.sand,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 60,
                                color: AppColors.moss,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.sand,
                            child: const Icon(
                              Icons.article_outlined,
                              size: 60,
                              color: AppColors.moss,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Sumber Berita (News Site)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    backgroundColor: AppColors.mist,
                    side: BorderSide.none,
                    label: Text(
                      news.news_site,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.sage,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Judul Berita
                Text(
                  news.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 16),

                // 4. Penulis & Tanggal Publikasi
                _infoCard(
                  icon: Icons.person_outline,
                  label: 'Penulis',
                  value: news.authors,
                ),
                const SizedBox(height: 10),
                _infoCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Publikasi',
                  value: _formatDate(news.published_at),
                ),
                const SizedBox(height: 10),

                // 5. Ringkasan Berita
                _infoCard(
                  icon: Icons.notes_rounded,
                  label: 'Ringkasan Berita',
                  value: news.summary,
                ),
                const SizedBox(height: 24),

                // 6. Tombol Read Full Article
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openBrowser(context, news.url),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text(
                      'Read Full Article',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Card(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.sand),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.sage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}