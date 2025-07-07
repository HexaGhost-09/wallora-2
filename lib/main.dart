import 'package:flutter/material.dart';
import 'screens/wallpapers_page.dart';

void main() {
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatelessWidget {
  const WallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpapers App',
      home: const WallpapersPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
