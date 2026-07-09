import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/responsive_helper.dart';
import 'wallpaper_card.dart';

class WallpaperTray extends StatefulWidget {
  const WallpaperTray({super.key});

  @override
  State<WallpaperTray> createState() => _WallpaperTrayState();
}

class _WallpaperTrayState extends State<WallpaperTray> {
  late Future<List<Wallpaper>> _wallpapers;

  @override
  void initState() {
    super.initState();
    final userId = AuthService.instance.currentUser?.id;
    _wallpapers = WalloraAPI.getWallpapers(userId: userId);
    _wallpapers.then((list) {
      if (list.isNotEmpty) {
        WalloraAPI.syncLikes(list, userId).then((changed) {
          if (changed && mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wallpaper>>(
      future: _wallpapers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Wallpapers"));
        }

        final wallpapers = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MasonryGridView.count(
            crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: wallpapers.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return WallpaperCard(wallpapers: wallpapers, index: index);
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            highlightColor: isDark
                ? const Color(0xFF2D3A4F)
                : const Color(0xFFF1F5F9),
            child: Container(
              height: index.isEven ? 200 : 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      ),
    );
  }
}
