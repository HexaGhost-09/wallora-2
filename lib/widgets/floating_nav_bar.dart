import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171923);
    final accent = Theme.of(context).colorScheme.primary;
    final selectedForeground = Theme.of(context).colorScheme.onPrimary;
    final glassColor = isDark
        ? const Color(0xFF202127).withOpacity(0.78)
        : Colors.white.withOpacity(0.78);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 76,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: glassColor,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.24 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(isDark ? 0.035 : 0.5),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedAlign(
                      alignment:
                          Alignment(-1.0 + selectedIndex.toDouble(), 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: FractionallySizedBox(
                        widthFactor: 1 / 3,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(29),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _NavBarItem(
                          icon: Iconsax.home_2,
                          label: 'Home',
                          isSelected: selectedIndex == 0,
                          foreground: foreground,
                          isDark: isDark,
                          accent: accent,
                          selectedForeground: selectedForeground,
                          onTap: () => onTap(0),
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: Iconsax.category,
                          label: 'Explore',
                          isSelected: selectedIndex == 1,
                          foreground: foreground,
                          isDark: isDark,
                          accent: accent,
                          selectedForeground: selectedForeground,
                          onTap: () => onTap(1),
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: Iconsax.setting_2,
                          label: 'Settings',
                          isSelected: selectedIndex == 2,
                          foreground: foreground,
                          isDark: isDark,
                          accent: accent,
                          selectedForeground: selectedForeground,
                          onTap: () => onTap(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color foreground;
  final bool isDark;
  final Color accent;
  final Color selectedForeground;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.foreground,
    required this.isDark,
    required this.accent,
    required this.selectedForeground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedForeground : foreground.withOpacity(0.72);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(29),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.06 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: AnimatedRotation(
                  turns: isSelected && label == 'Settings' ? 0.035 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: Icon(icon, size: 22, color: color),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  height: 1,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.05,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
