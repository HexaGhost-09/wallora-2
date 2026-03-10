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
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WallpaperView extends StatefulWidget {
  final Wallpaper wallpaper;
  const WallpaperView({super.key, required this.wallpaper});

  @override
  State<WallpaperView> createState() => _WallpaperViewState();
}

class _WallpaperViewState extends State<WallpaperView> {
  bool _isApplying = false;
  late int _likesCount;
  late bool _isLiked;
  late bool _isSaved;
  bool _isLiking = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.wallpaper.likesCount;
    _isLiked = widget.wallpaper.isLiked;
    _isSaved = widget.wallpaper.isSaved;
  }

  Future<void> _toggleLike() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "Please login to like wallpapers");
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
      widget.wallpaper.isLiked = _isLiked;
      widget.wallpaper.likesCount = _likesCount;
    });

    try {
      await WalloraAPI.toggleLike(widget.wallpaper.id, user.id, !_isLiked);
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
        widget.wallpaper.isLiked = _isLiked;
        widget.wallpaper.likesCount = _likesCount;
      });
      Fluttertoast.showToast(msg: "Failed to update like status");
    } finally {
      setState(() => _isLiking = false);
    }
  }

  Future<void> _toggleSave() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "Please login to save wallpapers");
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
      widget.wallpaper.isSaved = _isSaved;
    });

    try {
      await WalloraAPI.toggleSave(widget.wallpaper.id, user.id, !_isSaved);
      Fluttertoast.showToast(
        msg: _isSaved ? "Saved to collection" : "Removed from collection",
      );
    } catch (e) {
      setState(() {
        _isSaved = !_isSaved;
        widget.wallpaper.isSaved = _isSaved;
      });
      Fluttertoast.showToast(msg: "Failed to update save status");
    } finally {
      setState(() => _isSaving = false);
    }
  }

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
        List<String> savedWallpapers =
            prefs.getStringList('applied_wallpapers') ?? [];

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
          // Full-screen wallpaper
          SizedBox.expand(
            child: Hero(
              tag: widget.wallpaper.image,
              child: CachedNetworkImage(
                imageUrl: widget.wallpaper.image,
                fit: BoxFit.cover,
              ),
            ),
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
                  if (widget.wallpaper.title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        widget.wallpaper.title,
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
                            ? Iconsax.archive_tick5
                            : Iconsax.archive_add,
                        iconColor:
                            _isSaved ? Colors.greenAccent : Colors.white,
                        label: null,
                      ),
                      const SizedBox(width: 10),

                      // Apply Wallpaper button (expands to fill remaining space)
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
                              "Apply Wallpaper",
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            if (label != null) ...[
              const SizedBox(width: 6),
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
