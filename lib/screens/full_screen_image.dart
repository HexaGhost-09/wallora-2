import 'package:flutter/material.dart';

class FullScreenLocalImage extends StatelessWidget {
  final String imagePath;
  const FullScreenLocalImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: isNetwork
              ? Image.network(
                  imagePath,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red, size: 50);
                  },
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red, size: 50);
                  },
                ),
        ),
      ),
    );
  }
}
