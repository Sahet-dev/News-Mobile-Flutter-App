class NewsArticle {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String publishedAt;
  final String category;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.category,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      publishedAt: json['publishedAt'],
      category: json['category']['name'], 
    );
  }
}
