import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter
import 'package:cached_network_image/cached_network_image.dart'; // Added for image caching

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

// This is the CategoriesPage widget.
// It's now a StatefulWidget to manage its own data fetching state.
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryItem> categories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const String apiUrl = 'https://wallora-wallpapers.deno.dev/categories';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<CategoryItem> fetchedCategories = data.map((item) {
          try {
            return CategoryItem.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing category item: $e, item: $item');
            return null;
          }
        }).whereType<CategoryItem>().toList(); // Filter out nulls

        setState(() {
          categories = fetchedCategories;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load categories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching categories: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold provides the basic visual structure for a Material Design app.
    return Scaffold(
      // AppBar for the top of the screen, styled to match the WallpapersPage.
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white, // Text color for the app bar title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        foregroundColor: Colors.white, // Color for icons and title text
        elevation: 0, // Remove shadow beneath the app bar
        centerTitle: true, // Center the title
        // Flexible space for the blurred background effect, copied from WallpapersPage.
        flexibleSpace: ClipRect( // ClipRect is important for BackdropFilter to work correctly
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur effect
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay for glass effect
            ),
          ),
        ),
        // Removed the actions property as the refresh button is no longer needed
      ),
      // The body of the page, now displaying fetched categories or loading/error states.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  : RefreshIndicator( // Added RefreshIndicator for pull-to-refresh
                      onRefresh: _fetchCategories, // Call _fetchCategories when pulled down
                      child: GridView.builder(
                        // Removed redundant top padding calculation
                        padding: const EdgeInsets.only(
                          top: 10, // Adjusted to remove the extra space
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two columns for categories
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0, // Square aspect ratio for category cards
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              // TODO: Navigate to a page displaying wallpapers for this category
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tapped on ${category.title} category!')),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              clipBehavior: Clip.antiAlias, // Ensures content is clipped to border radius
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Category thumbnail image
                                  CachedNetworkImage(
                                    imageUrl: category.thumbnail,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
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
                                  // Gradient overlay for text readability
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        stops: const [0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                  // Category title
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: Text(
                                      category.title,
                                      textAlign: TextAlign.center,
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
                        },
                      ),
                    ),
    );
  }
}
