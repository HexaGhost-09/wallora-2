class Wallpaper {
  final String id;
  final String category;
  final String url;
  final String thumbnail;
  final String timestamp;

  Wallpaper({
    required this.id,
    required this.category,
    required this.url,
    required this.thumbnail,
    required this.timestamp,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      category: json['category'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      timestamp: json['timestamp'],
    );
  }
}
