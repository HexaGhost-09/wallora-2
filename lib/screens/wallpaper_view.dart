import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:async_wallpaper/async_wallpaper.dart'; // The magic wallpaper tool
import 'package:flutter/services.dart';
import '../models/wallpaper_model.dart';

class WallpaperView extends StatefulWidget {
  final Wallpaper wallpaper;
  const WallpaperView({super.key, required this.wallpaper});

  @override
  State<WallpaperView> createState() => _WallpaperViewState();
}

class _WallpaperViewState extends State<WallpaperView> {
  bool _isApplying = false;

  // This function does the hard work of setting the wallpaper
  Future<void> _setWallpaper(int location) async {
    setState(() => _isApplying = true);
    Navigator.pop(context); // Close the little menu

    try {
      // This line tells the phone to change the background
      String result = (await AsyncWallpaper.setWallpaper(
        url: widget.wallpaper.image,
        wallpaperLocation: location,
        goToHome: false,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      )).toString();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result == 'Wallpaper set' ? 'Success!' : 'Failed')),
      );
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error!')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  // This shows the menu to choose "Home Screen" or "Lock Screen"
  void _showApplyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Set Wallpaper", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home Screen"),
              onTap: () => _setWallpaper(AsyncWallpaper.HOME_SCREEN),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Lock Screen"),
              onTap: () => _setWallpaper(AsyncWallpaper.LOCK_SCREEN),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text("Both Screens"),
              onTap: () => _setWallpaper(AsyncWallpaper.BOTH_SCREENS),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // This shows the big full-screen picture
          SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: widget.wallpaper.image,
              fit: BoxFit.cover,
            ),
          ),
          // Show a spinning circle while it's working
          if (_isApplying)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
      // The big "Apply" button at the bottom
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showApplyOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xB3000000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Apply Wallpaper"),
          ),
        ),
      ),
    );
  }
}