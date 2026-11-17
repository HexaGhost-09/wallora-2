import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/wallpaper_tray.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Key _trayKey = UniqueKey();

  Future<void> _handleRefresh() async {
    final userId = AuthService.instance.currentUser?.id;
    await WalloraAPI.getWallpapers(forceRefresh: true, userId: userId);
    if (mounted) {
      setState(() {
        _trayKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                primary: false,
                floating: true,
                snap: true,
                pinned: false,
                toolbarHeight: 112,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: const SizedBox(
                  width: double.infinity,
                  child: HomeHeader(),
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    WallpaperTray(key: _trayKey),
                    const SizedBox(height: 24),
                    _buildEndOfWallpapers(theme),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfWallpapers(ThemeData theme) {
    final muted = theme.colorScheme.onSurface.withOpacity(0.42);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Row(
        children: [
          Expanded(child: Divider(color: muted.withOpacity(0.35))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 19, color: muted),
                const SizedBox(height: 8),
                Text(
                  'You’re all caught up',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You’ve reached the end of wallpapers',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Expanded(child: Divider(color: muted.withOpacity(0.35))),
        ],
      ),
    );
  }
}
