// lib/data/models/wallpaper_model.dart

class WallpaperItem {
  final String id;
  final String category;
  final String title;
  final String imageUrl;
  final String downloadUrl;
  final String timestamp;
  
  // Cache hashCode for better performance in lists
  int? _hashCode;

  WallpaperItem({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.downloadUrl,
    required this.timestamp,
  });

  // Optimized factory constructor with better error handling
  factory WallpaperItem.fromJson(Map<String, dynamic> json) {
    try {
      return WallpaperItem(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        imageUrl: json['image']?.toString() ?? '',
        downloadUrl: json['download']?.toString() ?? '',
        timestamp: json['timestamp']?.toString() ?? '',
      );
    } catch (e) {
      // Return a default item if parsing fails
      return WallpaperItem(
        id: '',
        category: '',
        title: 'Unknown',
        imageUrl: '',
        downloadUrl: '',
        timestamp: '',
      );
    }
  }

  // Add toJson for potential caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'image': imageUrl,
      'download': downloadUrl,
      'timestamp': timestamp,
    };
  }

  // Implement equality operators for better list performance
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WallpaperItem &&
        other.id == id &&
        other.category == category &&
        other.title == title &&
        other.imageUrl == imageUrl &&
        other.downloadUrl == downloadUrl &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    _hashCode ??= Object.hash(
      id,
      category,
      title,
      imageUrl,
      downloadUrl,
      timestamp,
    );
    return _hashCode!;
  }

  // Add copyWith method for immutable updates
  WallpaperItem copyWith({
    String? id,
    String? category,
    String? title,
    String? imageUrl,
    String? downloadUrl,
    String? timestamp,
  }) {
    return WallpaperItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Add validation method
  bool get isValid {
    return id.isNotEmpty && 
           imageUrl.isNotEmpty && 
           downloadUrl.isNotEmpty;
  }

  @override
  String toString() {
    return 'WallpaperItem(id: $id, title: $title, category: $category)';
  }
}