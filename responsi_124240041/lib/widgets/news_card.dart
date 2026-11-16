import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const NewsCard({
    super.key,
    required this.news,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '-';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sand),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Berita + Tombol Bookmark
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
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
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.white.withOpacity(0.9),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: Icon(
                        favorite ? Icons.bookmark : Icons.bookmark_border,
                        color: favorite ? AppColors.sage : AppColors.ink,
                      ),
                      onPressed: onFavorite,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Sumber Berita, Judul, & Tanggal Publikasi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sumber Berita (news_site)
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
                    // Judul Berita
                    Expanded(
                      child: Text(
                        news.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tanggal Publikasi
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 11, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(news.published_at),
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
            ),
          ],
        ),
      ),
    );
  }
}