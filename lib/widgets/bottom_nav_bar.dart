import 'package:flutter/material.dart';
import 'dart:ui';

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
  // Cache decoration to avoid recreating on every build
  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: Colors.black.withOpacity(0.5),
    borderRadius: BorderRadius.circular(30.0),
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
  );

  // Cache the blur filter to avoid recreating
  static final ImageFilter _cachedBlurFilter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  // Cache navigation items to avoid recreating
  static const List<BottomNavigationBarItem> _navigationItems = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: _cachedBlurFilter,
          child: Container(
            decoration: _cachedDecoration,
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onItemSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: _navigationItems,
              
              // Additional optimizations
              mouseCursor: SystemMouseCursors.click,
              enableFeedback: true,
              
              // Optimize animations
              selectedFontSize: 12.0,
              unselectedFontSize: 10.0,
              iconSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative optimized version with reduced blur effects for better performance
class BottomNavBarOptimized extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomNavBarOptimized({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  // Cached decoration without expensive blur
  static final BoxDecoration _optimizedDecoration = BoxDecoration(
    color: Colors.black.withOpacity(0.8), // Slightly more opaque to compensate for no blur
    borderRadius: BorderRadius.circular(30.0),
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const List<BottomNavigationBarItem> _navigationItems = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: _optimizedDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onItemSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.white.withOpacity(0.7),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: _navigationItems,
            mouseCursor: SystemMouseCursors.click,
            enableFeedback: true,
            selectedFontSize: 12.0,
            unselectedFontSize: 10.0,
            iconSize: 24.0,
          ),
        ),
      ),
    );
  }
}