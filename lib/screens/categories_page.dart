import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter
import 'package:cached_network_image/cached_network_image.dart';

// Define a simple model for a Category item based on your API example
class CategoryItem {
  final String id;
  final String title;
  final String thumbnail;
  final String details;

  CategoryItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.details,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      details: json['details'] as String,
    );
  }
}

// Optimized AppBar widget to prevent rebuilds
class OptimizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OptimizedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Categories',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Optimized Category Card widget with better memory management
class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Optimized image loading with memory cache management
            CachedNetworkImage(
              imageUrl: category.thumbnail,
              fit: BoxFit.cover,
              memCacheWidth: 300, // Limit memory cache size
              memCacheHeight: 300,
              maxWidthDiskCache: 600, // Limit disk cache size
              maxHeightDiskCache: 600,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[400],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
            // Optimized gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
            // Category title with optimized text rendering
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main Categories Page with optimizations
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with AutomaticKeepAliveClientMixin {
  List<CategoryItem> categories = [];
  bool isLoading = true;
  String? errorMessage;

  // Keep the state alive to prevent rebuilds when navigating
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const String apiUrl = 'https://wallora-wallpapers.deno.dev/categories';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'max-age=300', // Cache for 5 minutes
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<CategoryItem> fetchedCategories = data
            .map((item) {
              try {
                return CategoryItem.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing category item: $e, item: $item');
                return null;
              }
            })
            .whereType<CategoryItem>()
            .toList();

        if (mounted) {
          setState(() {
            categories = fetchedCategories;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load categories: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error fetching categories: $e';
          isLoading = false;
        });
      }
    }
  }

  void _onCategoryTap(CategoryItem category) {
    // TODO: Navigate to a page displaying wallpapers for this category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on ${category.title} category!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: const OptimizedAppBar(),
      body: isLoading
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchCategories,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : categories.isEmpty
                  ? const Center(
                      child: Text('No categories found. Try refreshing.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchCategories,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        physics: const BouncingScrollPhysics(), // Smoother scrolling
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: categories.length,
                        // Optimize item builder to prevent unnecessary rebuilds
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            key: ValueKey(category.id), // Add key for better performance
                            category: category,
                            onTap: () => _onCategoryTap(category),
                          );
                        },
                      ),
                    ),
    );
  }
}