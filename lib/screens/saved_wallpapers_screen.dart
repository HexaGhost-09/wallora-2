import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/responsive_helper.dart';
import '../widgets/wallpaper_card.dart';

class SavedWallpapersScreen extends StatefulWidget {
  const SavedWallpapersScreen({super.key});

  @override
  State<SavedWallpapersScreen> createState() => _SavedWallpapersScreenState();
}

class _SavedWallpapersScreenState extends State<SavedWallpapersScreen> {
  late Future<List<Wallpaper>> _wallpapersFuture;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  void _loadWallpapers({bool force = false}) {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      setState(() {
        _wallpapersFuture = Future.value([]);
      });
      return;
    }

    setState(() {
      _wallpapersFuture = WalloraAPI.getSavedWallpapers(
        forceRefresh: force,
        userId: userId,
      );
      _wallpapersFuture.then((list) {
        if (list.isNotEmpty && !force) {
          WalloraAPI.syncLikes(list, userId).then((changed) {
            if (changed && mounted) {
              setState(() {});
            }
          });
        }
      });
    });
  }

  Future<void> _handleRefresh() async {
    _loadWallpapers(force: true);
    await _wallpapersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Wallpapers')),
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
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No saved wallpapers found')),
                ],
              );
            }

            final wallpapers = snapshot.data!;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: MasonryGridView.count(
                  padding: const EdgeInsets.all(24),
                  crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: wallpapers.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return WallpaperCard(
                      wallpaper: wallpapers[index],
                      index: index,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
