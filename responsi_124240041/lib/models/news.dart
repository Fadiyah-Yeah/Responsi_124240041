class News {
  final int id;
  final String title;
  final String url; 
  final String authors;
  final String news_site;
  final String published_at;
  final String image_url;
  final String updated_at;
  final String summary;

  const News({
    required this.id,
    required this.title,
    required this.url,
    required this.authors,
    required this.news_site,
    required this.published_at,
    required this.image_url,
    required this.updated_at,
    required this.summary,
  });

  factory News.fromJson(Map<String, dynamic> j) {
    String parsedAuthors = 'Unknown';
    if (j['authors'] is List && (j['authors'] as List).isNotEmpty) {
      parsedAuthors = (j['authors'] as List)
          .map((a) => a['name'] ?? '')
          .where((name) => name.toString().isNotEmpty)
          .join(', ');
    }

    return News(
      id: j['id'] as int,
      title: j['title'] ?? 'Unknown',
      url: j['url'] ?? '',
      authors: parsedAuthors.isEmpty ? 'Unknown' : parsedAuthors,
      news_site: j['news_site'] ?? 'Unknown',
      published_at: j['published_at'] ?? '',
      image_url: j['image_url'] ?? '',
      updated_at: j['updated_at'] ?? '',
      summary: j['summary'] ?? 'Unknown',
    );
  }
}