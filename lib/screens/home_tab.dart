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
    // Force fetch from Neon and update cache
    final userId = AuthService.instance.currentUser?.id;
    await WalloraAPI.getWallpapers(forceRefresh: true, userId: userId);
    if (mounted) {
      setState(() {
        // Rebuild tray to show new data
        _trayKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.primary,
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
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    WallpaperTray(key: _trayKey),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
