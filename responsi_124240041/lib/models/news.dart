class News {
  final int id;
  final String title, authors, news_site, published_at, image_url, updated_at, summary;
  

  const News({
    required this.id, required this.title, required this.authors,
    required this.news_site, required this.published_at, required this.image_url,
    required this.updated_at, required this.summary
  });

  factory News.fromJson(Map<String, dynamic> j) => News(
    id: j['id'] as int,
    title: j['title'] ?? 'Unknown',
    authors: j['authors'] ?? 'Unknown',
    news_site: j['news_site'] ?? 'Unknown',
    published_at: j['published_at'] ?? 'Unknown',
    image_url: j['image_url'] ?? '',
    updated_at: j['updated_at'] ?? 'Unknown',
    summary: j['summary'] ?? 'Unknown',
  );
}