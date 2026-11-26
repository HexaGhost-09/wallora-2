import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../screens/categories_tab.dart';
import '../screens/saved_wallpapers_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_page.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/wallpaper_tray.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  int _selectedIndex = 0;
  Key _wallpaperKey = UniqueKey();

  static const _sections = [
    _DesktopSection('Discover', Iconsax.discover, Iconsax.discover5),
    _DesktopSection('Explore', Iconsax.category, Iconsax.category5),
    _DesktopSection('Saved', Iconsax.archive, Iconsax.archive_tick),
    _DesktopSection('Settings', Iconsax.setting_2, Iconsax.setting_2),
  ];

  Future<void> _refresh() async {
    final userId = AuthService.instance.currentUser?.id;
    await WalloraAPI.getWallpapers(forceRefresh: true, userId: userId);
    if (mounted) setState(() => _wallpaperKey = UniqueKey());
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = theme.colorScheme.onSurface;
    final border = theme.colorScheme.outlineVariant.withOpacity(0.42);

    final pages = <Widget>[
      _DesktopDiscoverView(
        key: ValueKey(_wallpaperKey),
        onRefresh: _refresh,
      ),
      const CategoriesTab(),
      const SavedWallpapersScreen(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 244,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111318) : const Color(0xFFF5F6F8),
              border: Border(right: BorderSide(color: border)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 18, 30),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Iconsax.gallery5,
                              color: Colors.white, size: 21),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WALLORA',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                )),
                            Text('DESKTOP',
                                style: TextStyle(
                                  color: foreground.withOpacity(.42),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.1,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
                    child: Text('LIBRARY',
                        style: TextStyle(
                          color: foreground.withOpacity(.42),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        )),
                  ),
                  for (var i = 0; i < _sections.length; i++)
                    _DesktopNavItem(
                      section: _sections[i],
                      selected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(.045)
                            : Colors.white,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.monitor, size: 17,
                              color: foreground.withOpacity(.55)),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text('Wallora for desktop',
                                style: TextStyle(
                                  color: foreground.withOpacity(.68),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          Icon(Iconsax.tick_circle5,
                              size: 16, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(bottom: BorderSide(color: border)),
                  ),
                  child: Row(
                    children: [
                      Text(_sections[_selectedIndex].label,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.45,
                          )),
                      const Spacer(),
                      SizedBox(
                        width: 270,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: _openSearch,
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.search_normal, size: 15,
                                  color: foreground.withOpacity(.48)),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text('Search wallpapers',
                                    style: TextStyle(
                                      color: foreground.withOpacity(.48),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              Text('⌘ K',
                                  style: TextStyle(
                                    color: foreground.withOpacity(.35),
                                    fontSize: 10,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Refresh wallpapers',
                        onPressed: _selectedIndex == 0 ? _refresh : null,
                        icon: const Icon(Iconsax.refresh, size: 19),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: pages[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopDiscoverView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _DesktopDiscoverView({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(.56);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(34, 30, 34, 18),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A world of wallpapers.',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.1,
                            )),
                        const SizedBox(height: 7),
                        Text('Find the perfect look for your screen.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            )),
                      ],
                    ),
                  ),
                  Text('CURATED FOR YOUR DISPLAY',
                      style: TextStyle(
                        color: muted.withOpacity(.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              child: WallpaperTray(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSection {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _DesktopSection(this.label, this.icon, this.activeIcon);
}

class _DesktopNavItem extends StatelessWidget {
  final _DesktopSection section;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withOpacity(.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            height: 43,
            child: Row(
              children: [
                const SizedBox(width: 13),
                Icon(selected ? section.activeIcon : section.icon,
                    size: 18,
                    color: selected
                        ? theme.colorScheme.primary
                        : foreground.withOpacity(.62)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(section.label,
                      style: TextStyle(
                        color: selected
                            ? theme.colorScheme.primary
                            : foreground.withOpacity(.78),
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      )),
                ),
                if (selected)
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
