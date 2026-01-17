import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import 'wallpaper_card.dart';

class WallpaperTray extends StatefulWidget {
  const WallpaperTray({super.key});

  @override
  State<WallpaperTray> createState() => _WallpaperTrayState();
}

class _WallpaperTrayState extends State<WallpaperTray> {
  late Future<List<Wallpaper>> _wallpapersFuture;

  @override
  void initState() {
    super.initState();
    _wallpapersFuture = WalloraAPI.getWallpapers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wallpaper>>(
      future: _wallpapersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No wallpapers found'));
        }

        final wallpapers = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wallpapers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              return WallpaperCard(wallpaper: wallpapers[index]);
            },
          ),
        );
      },
    );
  }
}