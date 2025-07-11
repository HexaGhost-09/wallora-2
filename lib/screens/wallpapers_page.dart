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

    // IMPORTANT: Using the GitHub Gist URL provided by the user
    const String apiUrl = 'https://gist.githubusercontent.com/HexaGhost-09/d279e6df015bf16a6ef259feda4d0359/raw/f282c196ca3e8d262a369b20b0ed8b84b71ecdb9/wallpapers.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          wallpaperImages = data.cast<String>();
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
                        final isNetwork = imagePath.startsWith('http');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
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
                                    imagePath,
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
