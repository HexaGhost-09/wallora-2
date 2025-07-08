import 'package:flutter/material.dart';
import 'full_screen_image.dart'; // Assuming this file exists and handles full-screen image display

const List<String> localWallpapers = [
  'assets/images/img1.jpg',
  'assets/images/img2.jpg',
  'assets/images/img3.jpg',
  'https://i.rj1.dev/yavolPP', // added online image
];

class WallpapersPage extends StatelessWidget {
  const WallpapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 9 / 16, // <--- Modified this line
        ),
        itemCount: localWallpapers.length,
        itemBuilder: (context, index) {
          final imagePath = localWallpapers[index];
          final isNetwork = imagePath.startsWith('http');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenLocalImage(imagePath: imagePath),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isNetwork
                  ? Image.network(imagePath, fit: BoxFit.cover)
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}