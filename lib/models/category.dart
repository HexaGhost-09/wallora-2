class Category {
  final String id;
  final String title;
  final String thumbnail;
  final String details;

  Category({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.details,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      details: json['details'] ?? '',
    );
  }
}
