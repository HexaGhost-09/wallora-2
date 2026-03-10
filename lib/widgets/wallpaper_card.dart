import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../screens/wallpaper_view.dart';

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final int index;

  const WallpaperCard({super.key, required this.wallpaper, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperView(wallpaper: wallpaper),
          ),
        );
      },
      child: Hero(
        tag: wallpaper.image,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CachedNetworkImage(
              imageUrl: wallpaper.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                child: Container(color: Colors.white),
              ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Icon(Icons.error_outline),
                ),
              ),
            ),
            if (wallpaper.likesCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        wallpaper.likesCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    )
    .animate(delay: (index * 50).ms)
    .fadeIn(duration: 500.ms)
    .moveY(begin: 20, end: 0, curve: Curves.easeOutBack);
  }
}