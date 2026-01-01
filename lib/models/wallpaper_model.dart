class Wallpaper {
  final String id;
  final String title;
  final String url;
  final String category;
  final String? thumbnail;

  Wallpaper({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    this.thumbnail,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'] ?? json['url'],
      title: json['title'] ?? 'Untitled',
      url: json['url'],
      category: json['category'] ?? 'unknown',
      thumbnail: json['thumbnail'],
    );
  }
}
