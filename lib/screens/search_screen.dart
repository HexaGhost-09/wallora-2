import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/responsive_helper.dart';
import '../widgets/wallpaper_card.dart';
import 'category_wallpapers_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Wallpaper> _results = [];
  List<Category> _categoryResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _searchCategories = false;
  int _requestId = 0;

  void _performSearch(String query) async {
    final requestId = ++_requestId;
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _categoryResults = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    if (_searchCategories) {
      try {
        final categories = await WalloraAPI.getCategories();
        final normalized = query.trim().toLowerCase();
        final matches = categories.where((Category category) {
          return category.title.toLowerCase().contains(normalized) ||
              category.details.toLowerCase().contains(normalized);
        }).toList();
        if (!mounted || requestId != _requestId) return;
        setState(() {
          _categoryResults = matches;
          _results = [];
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted || requestId != _requestId) return;
        setState(() {
          _categoryResults = [];
          _isLoading = false;
        });
      }
      return;
    }

    final userId = AuthService.instance.currentUser?.id;
    final results = await WalloraAPI.searchWallpapers(
      query.trim(),
      userId: userId,
    );

    if (mounted && requestId == _requestId) {
      setState(() {
        _results = results;
        _categoryResults = [];
        _isLoading = false;
      });
    }
  }

  void _setSearchMode(bool categories) {
    if (_searchCategories == categories) return;
    setState(() {
      _searchCategories = categories;
      _results = [];
      _categoryResults = [];
      _hasSearched = false;
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  void dispose() {
    _requestId++;
    _searchController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 8),
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
                          hintText: _searchCategories
                              ? 'Search categories...'
                              : 'Search wallpapers...',
                          hintStyle: TextStyle(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.35),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Iconsax.search_normal,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Row(
                children: [
                  _SearchModeChip(
                    label: 'Wallpapers',
                    icon: Iconsax.gallery,
                    selected: !_searchCategories,
                    onTap: () => _setSearchMode(false),
                  ),
                  const SizedBox(width: 10),
                  _SearchModeChip(
                    label: 'Categories',
                    icon: Iconsax.category,
                    selected: _searchCategories,
                    onTap: () => _setSearchMode(true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : !_hasSearched
                      ? _buildEmptyState(
                          _searchCategories
                              ? 'Search for a category'
                              : 'Search for your favorite wallpapers',
                          _searchCategories
                              ? Iconsax.category
                              : Iconsax.search_favorite,
                        )
                      : _searchCategories
                          ? _categoryResults.isEmpty
                              ? _buildEmptyState(
                                  'No categories found for "${_searchController.text}"',
                                  Iconsax.search_status,
                                )
                              : _buildCategoryResults()
                          : _results.isEmpty
                              ? _buildEmptyState(
                                  'No wallpapers found for "${_searchController.text}"',
                                  Iconsax.search_status,
                                )
                              : _buildWallpaperResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperResults() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: MasonryGridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          itemCount: _results.length,
          itemBuilder: (context, index) {
            return WallpaperCard(wallpapers: _results, index: index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryResults() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
          ),
          itemCount: _categoryResults.length,
          itemBuilder: (context, index) {
            final category = _categoryResults[index];
            return Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryWallpapersScreen(category: category),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: category.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.expand(),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Iconsax.gallery_slash),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.78),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Text(
                        category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: MasonryGridView.count(
        crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor:
                isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            highlightColor:
                isDark ? const Color(0xFF2D3A4F) : const Color(0xFFF1F5F9),
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

class _SearchModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SearchModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: theme.colorScheme.primary.withOpacity(0.14),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary.withOpacity(0.4)
            : theme.colorScheme.onSurface.withOpacity(0.08),
      ),
    );
  }
}
