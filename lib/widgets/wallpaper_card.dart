import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/wallpaper_model.dart';
import '../screens/wallpaper_view.dart';
import '../screens/auth_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class WallpaperCard extends StatelessWidget {
  final List<Wallpaper> wallpapers;
  final int index;

  const WallpaperCard({
    super.key,
    required this.wallpapers,
    required this.index,
  });

  Wallpaper get wallpaper => wallpapers[index];

  Future<void> _showQuickActions(BuildContext context) async {
    if (ThemeService.instance.adaptiveWallpaperAccent) {
      unawaited(ThemeService.instance.applyWallpaperAccent(wallpaper.image));
    }
    if (!context.mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Wallpaper actions',
      barrierColor: Colors.black.withOpacity(0.48),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final theme = Theme.of(dialogContext);
            Future<void> requireUser() async {
              if (AuthService.instance.currentUser == null) {
                Navigator.pop(dialogContext);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
                return;
              }
            }

            Future<void> toggleLike() async {
              final user = AuthService.instance.currentUser;
              if (user == null) {
                await requireUser();
                return;
              }
              final wasLiked = wallpaper.isLiked;
              try {
                await WalloraAPI.toggleLike(wallpaper.id, user.id, wasLiked);
                wallpaper.isLiked = !wasLiked;
                wallpaper.likesCount += wasLiked ? -1 : 1;
                setDialogState(() {});
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not update like.')),
                  );
                }
              }
            }

            Future<void> toggleSave() async {
              final user = AuthService.instance.currentUser;
              if (user == null) {
                await requireUser();
                return;
              }
              final wasSaved = wallpaper.isSaved;
              try {
                await WalloraAPI.toggleSave(wallpaper.id, user.id, wasSaved);
                wallpaper.isSaved = !wasSaved;
                setDialogState(() {});
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not update saved status.')),
                  );
                }
              }
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(color: Colors.black.withOpacity(0.24)),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Material(
                          color: theme.colorScheme.surface.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                    aspectRatio: 0.82,
                                    child: CachedNetworkImage(
                                      imageUrl: wallpaper.image,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image_outlined, size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                                if (wallpaper.title.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
                                    child: Text(
                                      wallpaper.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _FocusAction(
                                        icon: wallpaper.isSaved
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        label: 'Save',
                                        selected: wallpaper.isSaved,
                                        onTap: toggleSave,
                                      ),
                                    ),
                                    Expanded(
                                      child: _FocusAction(
                                        icon: wallpaper.isLiked
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        label: 'Like',
                                        selected: wallpaper.isLiked,
                                        onTap: toggleLike,
                                      ),
                                    ),
                                    Expanded(
                                      child: _FocusAction(
                                        icon: Icons.wallpaper_rounded,
                                        label: 'Apply',
                                        selected: true,
                                        onTap: () {
                                          Navigator.pop(dialogContext);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => WallpaperView(
                                                wallpapers: wallpapers,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onLongPress: () => _showQuickActions(context),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WallpaperView(
              wallpapers: wallpapers,
              initialIndex: index,
            ),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: wallpaper.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    highlightColor: isDark
                        ? const Color(0xFF2D3A4F)
                        : const Color(0xFFF1F5F9),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  ),
                ),
                // Subtle gradient overlay at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (wallpaper.likesCount > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            wallpaper.likesCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ),
    )
    .animate(delay: (index * 50).ms)
    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
    .scale(
      begin: const Offset(0.92, 0.92),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }
}


class _FocusAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FocusAction({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          tooltip: label,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            foregroundColor: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            backgroundColor: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            fixedSize: const Size(54, 54),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
