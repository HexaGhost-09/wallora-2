import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';

class WallpaperTray extends StatefulWidget {
  const WallpaperTray({super.key});

  @override
  State<WallpaperTray> createState() => _WallpaperTrayState();
}

class _WallpaperTrayState extends State<WallpaperTray> {
  late Future<List<Wallpaper>> wallpapers;

  @override
  void initState() {
    super.initState();
    wallpapers = WalloraAPI.getWallpapers(); // ✅ FIXED
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wallpaper>>(
      future: wallpapers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading wallpapers'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No wallpapers'));
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              final w = data[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(w.thumbnail, fit: BoxFit.cover),
              );
            },
          ),
        );
      },
    );
  }
}
