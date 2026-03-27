import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/wallpaper_bridge.dart';
import 'auth_screen.dart';

// async_wallpaper is Android / iOS only.
// On desktop / web we fall back to opening the image URL in the browser.
bool get _canSetWallpaper {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

/// Shows a toast on mobile, or a SnackBar on desktop/web.
void _showToast(BuildContext? ctx, String msg) {
  if (_canSetWallpaper) {
    Fluttertoast.showToast(msg: msg);
  } else if (ctx != null) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class WallpaperView extends StatefulWidget {
  final List<Wallpaper> wallpapers;
  final int initialIndex;

  const WallpaperView({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
  });

  @override
  State<WallpaperView> createState() => _WallpaperViewState();
}

class _WallpaperViewState extends State<WallpaperView> {
  late PageController _pageController;
  late int _currentIndex;

  bool _isApplying = false;
  late int _likesCount;
  late bool _isLiked;
  late bool _isSaved;
  bool _isLiking = false;
  bool _isSaving = false;

  Wallpaper get _currentWP => widget.wallpapers[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadWallpaperState();
  }

  void _loadWallpaperState() {
    _likesCount = _currentWP.likesCount;
    _isLiked = _currentWP.isLiked;
    _isSaved = _currentWP.isSaved;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _loadWallpaperState();
    });
  }

  Future<void> _toggleLike() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _showToast(context, "Please login to like wallpapers");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      // Optimistic update
      if (_isLiked) {
        _likesCount--;
        _isLiked = false;
      } else {
        _likesCount++;
        _isLiked = true;
      }
      _currentWP.isLiked = _isLiked;
      _currentWP.likesCount = _likesCount;
    });

    try {
      await WalloraAPI.toggleLike(_currentWP.id, user.id, !_isLiked);
    } catch (e) {
      // Revert on error
      setState(() {
        if (_isLiked) {
          _likesCount--;
          _isLiked = false;
        } else {
          _likesCount++;
          _isLiked = true;
        }
        _currentWP.isLiked = _isLiked;
        _currentWP.likesCount = _likesCount;
      });
      _showToast(context, "Failed to update like status");
    } finally {
      setState(() => _isLiking = false);
    }
  }

  Future<void> _toggleSave() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _showToast(context, "Please login to save wallpapers");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _isSaved = !_isSaved;
      _currentWP.isSaved = _isSaved;
    });

    try {
      await WalloraAPI.toggleSave(_currentWP.id, user.id, !_isSaved);
      _showToast(
        context,
        _isSaved ? "Saved to collection" : "Removed from collection",
      );
    } catch (e) {
      setState(() {
        _isSaved = !_isSaved;
        _currentWP.isSaved = _isSaved;
      });
      _showToast(context, "Failed to update save status");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Download / open wallpaper on platforms that can't set it natively.
  Future<void> _openWallpaperInBrowser() async {
    final uri = Uri.parse(
      _currentWP.download.isNotEmpty ? _currentWP.download : _currentWP.image,
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open image URL')));
    }
  }

  Future<void> _setWallpaper(int location) async {
    // This path is only reached on Android / iOS (see _canSetWallpaper guard).
    setState(() => _isApplying = true);
    Navigator.pop(context);

    try {
      // Dynamic import via runtime check — async_wallpaper is mobile-only.
      final result = await _AsyncWallpaperHelper.set(
        url: _currentWP.image,
        location: location,
      );

      if (result == 'Wallpaper set') {
        final prefs = await SharedPreferences.getInstance();
        List<String> savedWallpapers =
            prefs.getStringList('applied_wallpapers') ?? [];

        final wallpaperMap = {
          'id': _currentWP.id,
          'category': _currentWP.category,
          'title': _currentWP.title,
          'image': _currentWP.image,
          'download': _currentWP.download,
          'timestamp': _currentWP.timestamp,
        };

        final jsonStr = json.encode(wallpaperMap);
        if (!savedWallpapers.contains(jsonStr)) {
          savedWallpapers.add(jsonStr);
          await prefs.setStringList('applied_wallpapers', savedWallpapers);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == 'Wallpaper set'
                ? 'Successfully Applied!'
                : 'Failed to apply',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error applying wallpaper')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showApplyOptions() {
    // On desktop / web: open the image in the browser for download.
    if (!_canSetWallpaper) {
      _openWallpaperInBrowser();
      return;
    }

    // On Android / iOS: show the home/lock screen picker.
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
                onTap: () => _setWallpaper(_WallpaperLocation.homeScreen),
              ),
              const SizedBox(height: 12),
              _ApplyOptionTile(
                icon: Iconsax.lock,
                title: "Lock Screen",
                onTap: () => _setWallpaper(_WallpaperLocation.lockScreen),
              ),
              const SizedBox(height: 12),
              _ApplyOptionTile(
                icon: Iconsax.mobile,
                title: "Both Screens",
                onTap: () => _setWallpaper(_WallpaperLocation.bothScreens),
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
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.55),
            child: const BackButton(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // PageView for swiping
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = widget.wallpapers[index];
              return Hero(
                tag: wallpaper.image,
                child: CachedNetworkImage(
                  imageUrl: wallpaper.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white24),
                  ),
                ),
              );
            },
          ),

          // Applying overlay
          if (_isApplying)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // Bottom gradient + title + action buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wallpaper title
                  if (_currentWP.title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _currentWP.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 8,
                              color: Colors.black87,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Action row: Like | Save | Apply Wallpaper
                  Row(
                    children: [
                      // Like button
                      _ActionButton(
                        onPressed: _toggleLike,
                        icon: _isLiked ? Iconsax.heart5 : Iconsax.heart,
                        iconColor: _isLiked ? Colors.redAccent : Colors.white,
                        label: _likesCount > 0 ? _likesCount.toString() : null,
                      ),
                      const SizedBox(width: 10),

                      // Save button
                      _ActionButton(
                        onPressed: _toggleSave,
                        icon: _isSaved
                            ? Iconsax.archive_tick
                            : Iconsax.archive_add,
                        iconColor: _isSaved ? Colors.greenAccent : Colors.white,
                        label: null,
                      ),
                      const SizedBox(width: 10),

                      // Apply / Download Wallpaper button
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _showApplyOptions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _canSetWallpaper
                                  ? "Apply Wallpaper"
                                  : "Download Wallpaper",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact square action button with solid dark background,
/// always readable on both light and dark wallpapers.
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final String? label;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        constraints: const BoxConstraints(minWidth: 54),
        padding: label != null
            ? const EdgeInsets.symmetric(horizontal: 14)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
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

// ---------------------------------------------------------------------------
// Wallpaper location constants (mirror AsyncWallpaper constants)
// ---------------------------------------------------------------------------
class _WallpaperLocation {
  static const int homeScreen = 1;
  static const int lockScreen = 2;
  static const int bothScreens = 3;
}

// ---------------------------------------------------------------------------
// Async wallpaper helper — calls the real plugin on Android/iOS only.
// On other platforms this should never be reached (guarded by _canSetWallpaper).
// ---------------------------------------------------------------------------
class _AsyncWallpaperHelper {
  static Future<String> set({
    required String url,
    required int location,
  }) async {
    // We instantiate async_wallpaper only here, not at top-level import,
    // so desktop compilations that never call this method are unaffected.
    try {
      // ignore: avoid_print
      final result = await _callPlugin(url, location);
      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String> _callPlugin(String url, int location) async {
    // Import async_wallpaper at call-site for maximum safety.
    // Desktop never reaches this path due to the _canSetWallpaper guard.
    return await AsyncWallpaperBridge.setWallpaper(url, location);
  }
}
