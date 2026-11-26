class Category {
  final String id;
  final String title;
  final String thumbnail;
  final String details;
  final bool isTag;

  Category({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.details,
    this.isTag = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      details: json['details'] ?? '',
      isTag: json['is_tag'] ?? (json['id']?.toString().startsWith('tag:') ?? false),
    );
  }
}
