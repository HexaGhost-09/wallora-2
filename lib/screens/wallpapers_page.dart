import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter
import 'package:cached_network_image/cached_network_image.dart'; // Added for image caching

import 'package:wallora/data/models/wallpaper_model.dart'; // Import the new model
import 'full_screen_wallpaper_page.dart'; // We will rename and update this file next

class WallpapersPage extends StatefulWidget {
  const WallpapersPage({super.key});

  @override
  State<WallpapersPage> createState() => _WallpapersPageState();
}

class _WallpapersPageState extends State<WallpapersPage> {
  List<WallpaperItem> wallpapers = []; // Changed to list of WallpaperItem
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  Future<void> _fetchWallpapers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const String apiUrl = 'https://wallora-wallpapers.deno.dev/wallpapers';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Map the dynamic data to a list of WallpaperItem objects
        final List<WallpaperItem> fetchedWallpapers = data.map((item) {
          try {
            return WallpaperItem.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing wallpaper item: $e, item: $item');
            return null; // Return null for invalid items
          }
        }).whereType<WallpaperItem>().toList(); // Filter out nulls

        setState(() {
          wallpapers = fetchedWallpapers;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load wallpapers: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching wallpapers: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallpapers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        // Removed the actions property as the refresh button is no longer needed
      ),
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
                          onPressed: _fetchWallpapers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : wallpapers.isEmpty
                  ? const Center(
                      child: Text('No wallpapers found. Try refreshing.'),
                    )
                  : RefreshIndicator( // Added RefreshIndicator for pull-to-refresh
                      onRefresh: _fetchWallpapers, // Call _fetchWallpapers when pulled down
                      child: GridView.builder(
                        padding: EdgeInsets.only(
                          top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 10,
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 9 / 16,
                        ),
                        itemCount: wallpapers.length,
                        itemBuilder: (context, index) {
                          final wallpaper = wallpapers[index]; // Get the WallpaperItem
                          final imagePath = wallpaper.imageUrl; // Use imageUrl for preview

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Pass the entire WallpaperItem to the full-screen page
                                  builder: (_) => FullScreenWallpaperPage(wallpaperItem: wallpaper),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage( // Changed from Image.network to CachedNetworkImage
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                                // Placeholder shown while the image is loading
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                                    ),
                                  ),
                                ),
                                // Widget shown if the image fails to load
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
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
