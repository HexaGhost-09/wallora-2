import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter

import 'full_screen_image.dart'; // Assuming this file exists and is correctly imported

class WallpapersPage extends StatefulWidget {
  const WallpapersPage({super.key});

  @override
  State<WallpapersPage> createState() => _WallpapersPageState();
}

class _WallpapersPageState extends State<WallpapersPage> {
  List<String> wallpaperImages = [];
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

    // UPDATED: Using the new API server URL
    const String apiUrl = 'https://wallora-wallpapers.deno.dev/wallpapers';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the JSON response, which is now a list of objects
        final List<dynamic> data = json.decode(response.body);

        // Extract only the 'image' URLs from each object
        final List<String> fetchedImages = data.map((item) {
          // Ensure 'image' field exists and is a String
          if (item is Map<String, dynamic> && item.containsKey('image') && item['image'] is String) {
            return item['image'] as String;
          }
          // Handle cases where 'image' might be missing or not a String
          // You might want to log this or filter out invalid entries
          print('Warning: Invalid wallpaper item found: $item');
          return ''; // Return an empty string or null to filter out later
        }).where((url) => url.isNotEmpty).toList(); // Filter out empty strings

        setState(() {
          wallpaperImages = fetchedImages;
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
        // Updated: Make title bold and centered, matching CategoriesPage
        title: const Text(
          'Wallpapers',
          style: TextStyle(
            color: Colors.white, // Keep white color for consistency
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        foregroundColor: Colors.white, // Color for icons and title text
        elevation: 0, // Remove shadow
        flexibleSpace: ClipRect( // ClipRect is important for BackdropFilter
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur effect
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay for glass effect
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWallpapers,
          ),
        ],
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
              : wallpaperImages.isEmpty
                  ? const Center(
                      child: Text('No wallpapers found. Try refreshing.'),
                    )
                  : GridView.builder(
                      // Add padding to account for the transparent AppBar
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
                      itemCount: wallpaperImages.length,
                      itemBuilder: (context, index) {
                        final imagePath = wallpaperImages[index];
                        // The images from the new API are always network images,
                        // so the 'isNetwork' check becomes less critical but still valid.
                        final isNetwork = imagePath.startsWith('http');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Assuming FullScreenLocalImage can handle network image URLs
                                builder: (_) => FullScreenLocalImage(imagePath: imagePath),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: isNetwork
                                ? Image.network(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, color: Colors.red);
                                    },
                                  )
                                : Image.asset(
                                    imagePath, // This path would now only be used for local assets if any
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, color: Colors.red);
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
    );
  }
}
