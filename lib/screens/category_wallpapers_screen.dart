import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/category.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../widgets/wallpaper_card.dart';

class CategoryWallpapersScreen extends StatefulWidget {
  final Category category;

  const CategoryWallpapersScreen({super.key, required this.category});

  @override
  State<CategoryWallpapersScreen> createState() => _CategoryWallpapersScreenState();
}

class _CategoryWallpapersScreenState extends State<CategoryWallpapersScreen> {
  late Future<List<Wallpaper>> _wallpapersFuture;

  @override
  void initState() {
    super.initState();
    _wallpapersFuture = WalloraAPI.getWallpapersByCategory(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: FutureBuilder<List<Wallpaper>>(
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

          return MasonryGridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              return WallpaperCard(
                wallpaper: wallpapers[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}
