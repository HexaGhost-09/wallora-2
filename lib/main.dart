import 'package:flutter/material.dart';

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

class WallpapersPage extends StatelessWidget {
  const WallpapersPage({super.key});

  final List<String> wallpapers = const [
    'https://ik.imagekit.io/xvx0it6mrf/Wallpapers/IMG_20250707_163316_050.jpg?updatedAt=1751890828875',
    'https://ik.imagekit.io/xvx0it6mrf/Wallpapers/IMG_20250707_163316_864.jpg?updatedAt=1751890828131',
    'https://ik.imagekit.io/xvx0it6mrf/Wallpapers/IMG_20250707_163316_800.jpg?updatedAt=1751890827592',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,  // 2 per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: wallpapers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(imageUrl: wallpapers[index]),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                wallpapers[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
