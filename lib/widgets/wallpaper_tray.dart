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
  late Future<List<Wallpaper>> _wallpapers;

  @override
  void initState() {
    super.initState();
    _wallpapers = WalloraAPI.getWallpapers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Wallpaper>>(
      future: _wallpapers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Wallpapers"));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return WallpaperCard(wallpaper: snapshot.data![index]);
            },
          ),
        );
      },
    );
  }
}