import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define high-contrast colors based on our new strict theme
    final backgroundColor = isDark ? Colors.grey[900]!.withOpacity(0.8) : Colors.white.withOpacity(0.9);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Container(
      // Adjusted margin to prevent "yellow marks" at bottom edge
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70, // Slightly taller for better touch targets
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: borderColor, width: 1.5),
               boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: selectedIndex == 1 ? Icons.category_rounded : Icons.category_outlined,
                  label: 'Categories',
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the primary color (Black in light mode, White in dark mode)
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onBackground.withOpacity(0.5);
    final color = selected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 4),
             // Only show text if selected for a cleaner look (optional style choice)
             if (selected)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}