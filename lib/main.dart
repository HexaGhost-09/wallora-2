import 'package:flutter/material.dart';
import 'screens/wallpapers_page.dart'; // Import the WallpapersPage
import 'screens/categories_page.dart'; // Import the CategoriesPage
import 'screens/settings/settings_page.dart'; // Import the SettingsPage
import 'widgets/bottom_nav_bar.dart'; // Import the BottomNavBar component

void main() {
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({super.key});

  @override
  State<WallpaperApp> createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp> {
  int _selectedIndex = 0; // Current selected index for the bottom navigation bar

  // List of pages to display
  static const List<Widget> _pages = <Widget>[
    WallpapersPage(),
    CategoriesPage(),
    SettingsPage(), // Added SettingsPage
  ];

  // Function to handle item taps on the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpapers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Set the overall theme to dark
        primaryColor: Colors.deepPurple, // Primary color for the app
        scaffoldBackgroundColor: Colors.black, // Default background for scaffolds
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make default AppBar background transparent
          foregroundColor: Colors.white, // Default foreground color for AppBar content
          elevation: 0, // Remove shadow from AppBar
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // Dark background for the bottom bar
          selectedItemColor: Colors.deepPurpleAccent, // Highlight color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
        ),
        useMaterial3: true, // Use Material 3 design
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true, // Allows body to extend behind the AppBar
        body: _pages[_selectedIndex], // Display the selected page
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }
}