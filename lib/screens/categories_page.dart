import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter

// This is the CategoriesPage widget.
// It's a StatelessWidget now as it won't manage internal state
// related to a BottomNavigationBar on this specific page.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The Scaffold provides the basic visual structure for a Material Design app.
    return Scaffold(
      // AppBar for the top of the screen, styled to match the WallpapersPage.
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white, // Text color for the app bar title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        foregroundColor: Colors.white, // Color for icons and title text
        elevation: 0, // Remove shadow beneath the app bar
        centerTitle: true, // Center the title
        // Flexible space for the blurred background effect, copied from WallpapersPage.
        flexibleSpace: ClipRect( // ClipRect is important for BackdropFilter to work correctly
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur effect
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay for glass effect
            ),
          ),
        ),
        // You can add actions here if needed, similar to your WallpapersPage
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search, color: Colors.white),
        //     onPressed: () {
        //       // Handle search action
        //     },
        //   ),
        // ],
      ),
      // The body of the page, currently empty with a placeholder as requested.
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined, // A placeholder icon
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Categories content will be added here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'Stay tuned for updates!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      // The BottomNavigationBar has been removed from this page
      // as it's typically managed at a higher level (e.g., in a main app shell)
      // and not duplicated on every individual content page.
    );
  }
}
