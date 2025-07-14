import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Padding to make it float
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners for the entire bar
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism blur effect
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Transparent black background
              borderRadius: BorderRadius.circular(30.0), // Ensure container also has rounded corners
              // Optional: Add a subtle border for more definition
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onItemSelected,
              backgroundColor: Colors.transparent, // Make the actual nav bar transparent
              elevation: 0, // Remove shadow
              selectedItemColor: Colors.deepPurpleAccent, // Color for the selected icon/label
              unselectedItemColor: Colors.white.withOpacity(0.7), // White for unselected items
              showSelectedLabels: true, // Show labels for selected items
              showUnselectedLabels: false, // Hide labels for unselected items for a cleaner look
              type: BottomNavigationBarType.fixed, // Ensure items are fixed width
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}