// lib/data/models/wallpaper_model.dart
// You might want to create a 'data' folder and 'models' subfolder for better project structure.

class WallpaperItem {
  final String id;
  final String category;
  final String title;
  final String imageUrl; // This will be the preview image URL
  final String downloadUrl; // This will be the high-resolution download URL
  final String timestamp;

  WallpaperItem({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.downloadUrl,
    required this.timestamp,
  });

  // Factory constructor to create a WallpaperItem from a JSON map
  factory WallpaperItem.fromJson(Map<String, dynamic> json) {
    return WallpaperItem(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      imageUrl: json['image'] as String, // 'image' field for preview
      downloadUrl: json['download'] as String, // 'download' field for applying
      timestamp: json['timestamp'] as String,
    );
  }
}
