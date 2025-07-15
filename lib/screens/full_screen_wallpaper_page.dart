import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:wallora/data/models/wallpaper_model.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

enum WallpaperType { homeScreen, lockScreen, both }

class FullScreenWallpaperPage extends StatefulWidget {
  final WallpaperItem wallpaperItem;

  const FullScreenWallpaperPage({super.key, required this.wallpaperItem});

  @override
  State<FullScreenWallpaperPage> createState() => _FullScreenWallpaperPageState();
}

class _FullScreenWallpaperPageState extends State<FullScreenWallpaperPage> {
  static const platform = MethodChannel('com.hexaghost.wallora/wallpaper_setter');
  
  bool _isApplying = false;
  bool _isImageLoaded = false;
  
  // Cache frequently used values
  late final String _title;
  late final String _imageUrl;
  late final String _downloadUrl;
  
  // Cache gradient for better performance
  static final BoxDecoration _gradientDecoration = BoxDecoration(
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
  );

  // Cache text style
  static const TextStyle _titleStyle = TextStyle(
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
  );

  // Cache button style
  static final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    elevation: 5,
  );

  @override
  void initState() {
    super.initState();
    // Cache values to avoid repeated property access
    _title = widget.wallpaperItem.title;
    _imageUrl = widget.wallpaperItem.imageUrl;
    _downloadUrl = widget.wallpaperItem.downloadUrl;
  }

  // Optimized download with better error handling and progress tracking
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

  // Optimized wallpaper application with better state management
  Future<void> _applyWallpaper(WallpaperType type) async {
    if (_isApplying) return; // Prevent multiple simultaneous calls
    
    setState(() {
      _isApplying = true;
    });

    _showSnackBar('Downloading wallpaper...', Colors.blue);

    final String? imageFilePath = await _downloadImage(_downloadUrl);

    if (imageFilePath == null) {
      setState(() {
        _isApplying = false;
      });
      return;
    }

    try {
      final String result = await platform.invokeMethod('setWallpaper', {
        'filePath': imageFilePath,
        'type': type.index,
      });
      _showSnackBar(result, Colors.green);
    } on PlatformException catch (e) {
      _showSnackBar("Failed to set wallpaper: '${e.message}'. Please ensure permissions are granted.", Colors.red);
    } finally {
      // Clean up the temporary file
      _cleanupTempFile(imageFilePath);
      
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  // Extracted cleanup method
  Future<void> _cleanupTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting temporary file: $e');
    }
  }

  // Optimized SnackBar with better styling
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Optimized modal bottom sheet with reduced blur
  void _showApplyOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87, // Solid color instead of blur for better performance
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Options
                _buildOptionTile(
                  icon: Icons.home,
                  title: 'Home Screen',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperType.homeScreen);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.lock,
                  title: 'Lock Screen',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperType.lockScreen);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.phone_android,
                  title: 'Both',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperType.both);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build option tiles
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets padding = mediaQuery.padding;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen image with loading callback
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                        size: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              imageBuilder: (context, imageProvider) {
                // Mark image as loaded for potential optimizations
                if (!_isImageLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isImageLoaded = true;
                      });
                    }
                  });
                }
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Gradient overlay (only show when image is loaded)
          if (_isImageLoaded)
            Positioned.fill(
              child: Container(decoration: _gradientDecoration),
            ),
          
          // Back button
          Positioned(
            top: padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Title
          Positioned(
            top: padding.top + 15,
            left: 60,
            right: 60,
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: _titleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Apply button
          Positioned(
            bottom: padding.bottom + 20,
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
              style: _buttonStyle,
            ),
          ),
        ],
      ),
    );
  }
}