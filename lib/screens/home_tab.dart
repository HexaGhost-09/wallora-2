import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/wallpaper_tray.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HomeHeader(),
        // FIX: Expanded takes all remaining space, preventing overflow
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                WallpaperTray(),
                // Space for floating nav bar
                SizedBox(height: 100), 
              ],
            ),
          ),
        ),
      ],
    );
  }
}