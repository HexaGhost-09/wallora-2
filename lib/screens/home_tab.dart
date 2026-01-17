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
        // REMOVED: SizedBox(height: 10) - This removes the gap between Header and Grid
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                WallpaperTray(),
                // REDUCED: Changed from 100 to 80 (Just enough to clear the floating bar)
                SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ],
    );
  }
}