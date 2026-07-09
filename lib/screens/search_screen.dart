import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/responsive_helper.dart';
import '../widgets/wallpaper_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Wallpaper> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final userId = AuthService.instance.currentUser?.id;
    final results = await WalloraAPI.searchWallpapers(query.trim(), userId: userId);

    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141B2D)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _performSearch,
                        autofocus: true,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search wallpapers...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.35),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Iconsax.search_normal,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : _hasSearched && _results.isEmpty
                      ? _buildEmptyState(
                          'No results for "${_searchController.text}"',
                          Iconsax.search_status,
                        )
                      : !_hasSearched
                          ? _buildEmptyState(
                              'Search for your favorite wallpapers',
                              Iconsax.search_favorite,
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: MasonryGridView.count(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  crossAxisCount:
                                      ResponsiveHelper.getCrossAxisCount(context),
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  itemCount: _results.length,
                                  itemBuilder: (context, index) {
                                    return WallpaperCard(
                                      wallpapers: _results,
                                      index: index,
                                    );
                                  },
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: MasonryGridView.count(
        crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
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

  Widget _buildEmptyState(String message, IconData icon) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
