import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../screens/wallpaper_view.dart';

class WallpaperCard extends StatelessWidget {
  final List<Wallpaper> wallpapers;
  final int index;

  const WallpaperCard({
    super.key,
    required this.wallpapers,
    required this.index,
  });

  Wallpaper get wallpaper => wallpapers[index];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperView(
              wallpapers: wallpapers,
              initialIndex: index,
            ),
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: wallpaper.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    highlightColor: isDark
                        ? const Color(0xFF2D3A4F)
                        : const Color(0xFFF1F5F9),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  ),
                ),
                // Subtle gradient overlay at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (wallpaper.likesCount > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 11,
                            color: Colors.white,
                          ),
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
        ),
      ),
    )
    .animate(delay: (index * 50).ms)
    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
    .scale(
      begin: const Offset(0.92, 0.92),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }
}
