import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/category.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/responsive_helper.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: FutureBuilder<List<Wallpaper>>(
          future: _wallpapersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeleton();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.gallery_slash,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.08),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No wallpapers found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      wallpapers: wallpapers,
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

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.count(
        crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
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
