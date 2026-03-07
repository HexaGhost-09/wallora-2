import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class WallpaperView extends StatefulWidget {
  final Wallpaper wallpaper;
  const WallpaperView({super.key, required this.wallpaper});

  @override
  State<WallpaperView> createState() => _WallpaperViewState();
}

class _WallpaperViewState extends State<WallpaperView> {
  bool _isApplying = false;

  Future<void> _setWallpaper(int location) async {
    setState(() => _isApplying = true);
    Navigator.pop(context);

    try {
      String result = (await AsyncWallpaper.setWallpaper(
        url: widget.wallpaper.image,
        wallpaperLocation: location,
        goToHome: false,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      )).toString();

      if (result == 'Wallpaper set') {
        final prefs = await SharedPreferences.getInstance();
        List<String> savedWallpapers = prefs.getStringList('applied_wallpapers') ?? [];
        
        Map<String, dynamic> wallpaperMap = {
          'id': widget.wallpaper.id,
          'category': widget.wallpaper.category,
          'title': widget.wallpaper.title,
          'image': widget.wallpaper.image,
          'download': widget.wallpaper.download,
          'timestamp': widget.wallpaper.timestamp,
        };
        
        String jsonStr = json.encode(wallpaperMap);
        if (!savedWallpapers.contains(jsonStr)) {
          savedWallpapers.add(jsonStr);
          await prefs.setStringList('applied_wallpapers', savedWallpapers);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result == 'Wallpaper set' ? 'Successfully Applied!' : 'Failed to apply'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error applying wallpaper')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showApplyOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Set as wallpaper",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _ApplyOptionTile(
                icon: Iconsax.home,
                title: "Home Screen",
                onTap: () => _setWallpaper(AsyncWallpaper.HOME_SCREEN),
              ),
              const SizedBox(height: 12),
              _ApplyOptionTile(
                icon: Iconsax.lock,
                title: "Lock Screen",
                onTap: () => _setWallpaper(AsyncWallpaper.LOCK_SCREEN),
              ),
              const SizedBox(height: 12),
              _ApplyOptionTile(
                icon: Iconsax.mobile,
                title: "Both Screens",
                onTap: () => _setWallpaper(AsyncWallpaper.BOTH_SCREENS),
              ),
            ],
          ),
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.14),
            child: const BackButton(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Hero(
              tag: widget.wallpaper.image,
              child: CachedNetworkImage(
                imageUrl: widget.wallpaper.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isApplying)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _showApplyOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                child: Text(
                  "Apply Wallpaper",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplyOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ApplyOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}