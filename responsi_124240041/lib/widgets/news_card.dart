import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final bool favorite;
  final VoidCallback onTap, onFavorite;
  const NewsCard({
    super.key, required this.news, required this.favorite,
    required this.onTap, required this.onFavorite,
  });

  Color get _statusColor {
    switch (news.news_site.toLowerCase()) {
      case 'alive': return AppColors.sage;
      case 'dead': return AppColors.danger;
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.sand.withOpacity(.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onFavorite,
                child: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? AppColors.danger : AppColors.ink,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    news.image_url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_outline, size: 42, color: AppColors.moss,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              news.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(children: [
              CircleAvatar(radius: 4, backgroundColor: _statusColor),
              const SizedBox(width: 6),
              Text(news.news_site, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ],
        ),
      ),
    ),
  );
}