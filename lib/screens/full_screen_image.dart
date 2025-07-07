import 'package:flutter/material.dart';

class FullScreenLocalImage extends StatelessWidget {
  final String imagePath;
  const FullScreenLocalImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: isNetwork
              ? Image.network(imagePath, fit: BoxFit.contain)
              : Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
