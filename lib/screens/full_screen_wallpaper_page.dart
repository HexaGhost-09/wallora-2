import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for MethodChannel
import 'package:http/http.dart' as http;
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For temporary file storage
import 'package:wallora/data/models/wallpaper_model.dart'; // Import the WallpaperItem model
import 'dart:ui';

// Define constants for wallpaper types
enum WallpaperType { homeScreen, lockScreen, both }

class FullScreenWallpaperPage extends StatefulWidget {
  final WallpaperItem wallpaperItem; // Now accepts a WallpaperItem object

  const FullScreenWallpaperPage({super.key, required this.wallpaperItem});

  @override
  State<FullScreenWallpaperPage> createState() => _FullScreenWallpaperPageState();
}

class _FullScreenWallpaperPageState extends State<FullScreenWallpaperPage> {
  // MethodChannel to communicate with native code
  static const platform = MethodChannel('com.hexaghost.wallora/wallpaper_setter');

  bool _isApplying = false; // To show loading indicator during apply

  // Function to download the image from the download URL
  Future<String?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        _showSnackBar('Failed to download image: ${response.statusCode}', Colors.red);
        return null;
      }
    } catch (e) {
      _showSnackBar('Error downloading image: $e', Colors.red);
      return null;
    }
  }

  // Function to apply the wallpaper using platform channel
  Future<void> _applyWallpaper(WallpaperType type) async {
    setState(() {
      _isApplying = true;
    });

    _showSnackBar('Downloading wallpaper...', Colors.blue);

    final String? imageFilePath = await _downloadImage(widget.wallpaperItem.downloadUrl);

    if (imageFilePath == null) {
      setState(() {
        _isApplying = false;
      });
      return;
    }

    try {
      final String result = await platform.invokeMethod('setWallpaper', {
        'filePath': imageFilePath,
        'type': type.index, // Pass the index of the enum for native side
      });
      _showSnackBar(result, Colors.green);
    } on PlatformException catch (e) {
      _showSnackBar("Failed to set wallpaper: '${e.message}'. Please ensure permissions are granted.", Colors.red);
    } finally {
      // Clean up the temporary file after attempting to set wallpaper
      try {
        final file = File(imageFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting temporary file: $e');
      }

      setState(() {
        _isApplying = false;
      });
    }
  }

  // Helper to show a SnackBar message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Dialog to choose wallpaper type
  void _showApplyOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext bc) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: const Text('Home Screen', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(bc);
                      _applyWallpaper(WallpaperType.homeScreen);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.white),
                    title: const Text('Lock Screen', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(bc);
                      _applyWallpaper(WallpaperType.lockScreen);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.white),
                    title: const Text('Both', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(bc);
                      _applyWallpaper(WallpaperType.both);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for full-screen image
      body: Stack(
        children: [
          // Full-screen image display
          Positioned.fill(
            child: Image.network(
              widget.wallpaperItem.imageUrl, // Use imageUrl for display
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 50),
                );
              },
            ),
          ),
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title (optional, can be removed if not desired in full screen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 60,
            right: 60,
            child: Text(
              widget.wallpaperItem.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
          // Apply button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isApplying ? null : _showApplyOptionsDialog,
              icon: _isApplying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.wallpaper),
              label: Text(_isApplying ? 'Applying...' : 'Apply Wallpaper'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button background color
                foregroundColor: Colors.white, // Text and icon color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
