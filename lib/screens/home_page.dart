import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../widgets/wallpaper_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> categories = [];
  List<Wallpaper> wallpapers = [];
  String? selectedCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final cats = await WalloraAPI.getCategories();
    final walls = await WalloraAPI.getWallpapers(category: selectedCategory);

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      categories = cats;
      wallpapers = walls;
      isLoading = false;
    });
  }

  void _onCategorySelected(String? category) {
    setState(() => selectedCategory = category);
    _loadData();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _surpriseMe() async {
    final random = await WalloraAPI.getWallpapers();
    if (!mounted) return; // Check mounted before using context

    if (random.isNotEmpty) {
      random.shuffle();
      _showSnackBar('Surprise: ${random.first.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          WalloraAppBar(
            onSearchPressed: () => _showSnackBar('Search coming soon!'),
            onFavoritesPressed: () => _showSnackBar('Favorites coming soon!'),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Beautiful wallpapers for every mood',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (selectedCategory != null)
                        TextButton(
                          onPressed: () => _onCategorySelected(null),
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: CategoryCard(
                                category: category,
                                isSelected: isSelected,
                                onTap: () => _onCategorySelected(
                                  isSelected ? null : category,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Wallpapers Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory != null
                        ? '${selectedCategory![0].toUpperCase()}${selectedCategory!.substring(1)} Wallpapers'
                        : 'All Wallpapers',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${wallpapers.length} items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Wallpapers Grid
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (wallpapers.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No wallpapers found',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => WallpaperCard(
                    wallpaper: wallpapers[index],
                    onTap: () =>
                        _showSnackBar('Opening: ${wallpapers[index].title}'),
                    onFavoritePressed: () =>
                        _showSnackBar('Added to favorites!'),
                  ),
                  childCount: wallpapers.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _surpriseMe,
        icon: const Icon(Icons.shuffle_rounded),
        label: const Text('Surprise Me'),
        elevation: 4,
      ),
    );
  }
}
