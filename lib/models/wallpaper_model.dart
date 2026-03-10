class Wallpaper {
  final String id;
  final String category;
  final String title;
  final String image;
  final String download;
  final String timestamp;

  int likesCount;
  bool isLiked;
  bool isSaved;

  Wallpaper({
    required this.id,
    required this.category,
    required this.title,
    required this.image,
    required this.download,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      image: json['image'],
      download: json['download'],
      timestamp: json['timestamp'],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
    );
  }
}
