import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wallora/data/models/wallpaper_model.dart';
import 'full_screen_wallpaper_page.dart';

class WallpapersPage extends StatefulWidget {
  const WallpapersPage({super.key});

  @override
  State<WallpapersPage> createState() => _WallpapersPageState();
}

class _WallpapersPageState extends State<WallpapersPage> with AutomaticKeepAliveClientMixin {
  List<WallpaperItem> wallpapers = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Cache for performance
  static const String apiUrl = 'https://wallora-wallpapers.deno.dev/wallpapers';
  static const SliverGridDelegateWithFixedCrossAxisCount gridDelegate = 
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 9 / 16,
      );

  // Cache text styles
  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  @override
  bool get wantKeepAlive => true; // Keep this page alive for better performance

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  // Optimized fetch with better error handling and parsing
  Future<void> _fetchWallpapers() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Optimized parsing with better error handling
        final List<WallpaperItem> fetchedWallpapers = [];
        
        for (int i = 0; i < data.length; i++) {
          try {
            final item = data[i];
            if (item is Map<String, dynamic>) {
              final wallpaper = WallpaperItem.fromJson(item);
              if (wallpaper.isValid) {
                fetchedWallpapers.add(wallpaper);
              }
            }
          } catch (e) {
            debugPrint('Error parsing wallpaper item at index $i: $e');
            // Continue with other items instead of failing completely
          }
        }

        if (mounted) {
          setState(() {
            wallpapers = fetchedWallpapers;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Failed to load wallpapers: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error fetching wallpapers: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  // Optimized wallpaper item widget with better performance
  Widget _buildWallpaperItem(WallpaperItem wallpaper, int index) {
    return Hero(
      tag: 'wallpaper-${wallpaper.id}',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenWallpaperPage(wallpaperItem: wallpaper),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: wallpaper.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 400, // Limit memory cache size
              memCacheHeight: 700, // Maintain aspect ratio
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Optimized error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: errorTextStyle,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchWallpapers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Optimized empty state widget
  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wallpaper,
            color: Colors.grey,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'No wallpapers found',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpapers', style: appBarTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.8), // Solid color instead of blur
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : errorMessage != null
              ? _buildErrorWidget()
              : wallpapers.isEmpty
                  ? _buildEmptyWidget()
                  : RefreshIndicator(
                      onRefresh: _fetchWallpapers,
                      color: Colors.deepPurple,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: gridDelegate,
                        itemCount: wallpapers.length,
                        // Optimize scroll performance
                        cacheExtent: 1000,
                        itemBuilder: (context, index) {
                          return _buildWallpaperItem(wallpapers[index], index);
                        },
                      ),
                    ),
    );
  }
}