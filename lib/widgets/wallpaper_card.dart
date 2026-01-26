import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../screens/wallpaper_view.dart'; // This tells it where the big screen is

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 1. This part makes the card "clickable"
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperView(wallpaper: wallpaper),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: wallpaper.image,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[900]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}