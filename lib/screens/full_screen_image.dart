import 'package:flutter/material.dart';

class FullScreenLocalImage extends StatelessWidget {
  final String imagePath;
  const FullScreenLocalImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black, // Background for the full-screen view
      body: Stack(
        children: [
          // The wallpaper image, filling the entire screen
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Tap anywhere to go back
              child: isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain, // Ensures the whole image is visible and auto-fits
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // White loading indicator
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red, size: 50),
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.contain, // Ensures the whole image is visible and auto-fits
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red, size: 50),
                        );
                      },
                    ),
            ),
          ),
          // Floating back arrow button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Position below status bar
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54, // Semi-transparent background for visibility
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners for the button
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
