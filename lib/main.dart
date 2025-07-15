import 'package:flutter/material.dart';
import 'screens/wallpapers_page.dart';
import 'screens/categories_page.dart';
import 'screens/settings/settings_page.dart';
import 'screens/settings/update_service.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({super.key});

  @override
  State<WallpaperApp> createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp> {
  int _selectedIndex = 0;
  
  // Use lazy initialization with PageController for better performance
  late final PageController _pageController;
  
  // Create pages lazily only when needed
  final List<Widget Function()> _pageBuilders = [
    () => const WallpapersPage(),
    () => const CategoriesPage(),
    () => const SettingsPage(),
  ];
  
  // Cache pages to avoid rebuilding
  final Map<int, Widget> _pageCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Delay update check to not block initial rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          UpdateService.checkForUpdatesAutomatically(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Optimized page building with caching
  Widget _buildPage(int index) {
    return _pageCache.putIfAbsent(index, () => _pageBuilders[index]());
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid unnecessary rebuilds
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Smooth page transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpapers App',
      debugShowCheckedModeBanner: false,
      
      // Optimize theme creation
      theme: _buildTheme(),
      
      // Use builder to avoid unnecessary widget creation
      builder: (context, child) {
        return MediaQuery(
          // Disable animations if performance is critical
          data: MediaQuery.of(context).copyWith(
            // Reduce animation scale if needed
            // accessibleNavigation: true,
          ),
          child: child!,
        );
      },
      
      home: Scaffold(
        extendBodyBehindAppBar: true,
        
        // Use PageView for better memory management
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          itemCount: _pageBuilders.length,
          itemBuilder: (context, index) {
            // Only build visible and adjacent pages
            if ((index - _selectedIndex).abs() <= 1) {
              return _buildPage(index);
            }
            return Container(); // Empty container for distant pages
          },
        ),
        
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }

  // Extract theme building to separate method to avoid rebuilding
  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      
      // Optimize AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevent elevation changes
      ),
      
      // Optimize bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Better performance
        elevation: 0,
      ),
      
      // Optimize visual density for performance
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      useMaterial3: true,
    );
  }
}