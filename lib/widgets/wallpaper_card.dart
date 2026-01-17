import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: wallpaper.image,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      ),
    );
  }
}