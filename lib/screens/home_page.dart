import 'package:flutter/material.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/wallpaper_tray.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: Column(
        children: const [
          HomeHeader(), // 🔝 Header
          SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: WallpaperTray(), // 🧱 Wallpaper tray
            ),
          ),
        ],
      ),

      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }
}
