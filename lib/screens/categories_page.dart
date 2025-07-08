import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Explore different wallpaper categories here!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
