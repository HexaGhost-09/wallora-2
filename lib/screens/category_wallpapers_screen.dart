import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/category.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/wallpaper_card.dart';

class CategoryWallpapersScreen extends StatefulWidget {
  final Category category;

  const CategoryWallpapersScreen({super.key, required this.category});

  @override
  State<CategoryWallpapersScreen> createState() =>
      _CategoryWallpapersScreenState();
}

class _CategoryWallpapersScreenState extends State<CategoryWallpapersScreen> {
  late Future<List<Wallpaper>> _wallpapersFuture;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  void _loadWallpapers({bool force = false}) {
    final userId = AuthService.instance.currentUser?.id;
    setState(() {
      _wallpapersFuture = WalloraAPI.getWallpapersByCategory(
        widget.category.id,
        forceRefresh: force,
        userId: userId,
      );
    });
  }

  Future<void> _handleRefresh() async {
    _loadWallpapers(force: true);
    await _wallpapersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: FutureBuilder<List<Wallpaper>>(
          future: _wallpapersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                // Use ListView to ensure it's scrollable for RefreshIndicator
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No wallpapers found')),
                ],
              );
            }

            final wallpapers = snapshot.data!;

            return MasonryGridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: wallpapers.length,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              itemBuilder: (context, index) {
                return WallpaperCard(
                  wallpaper: wallpapers[index],
                  index: index,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
