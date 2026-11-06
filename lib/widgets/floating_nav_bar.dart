import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAction;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF171923);
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
        child: Row(
          children: [
            Expanded(
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
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavBarItem(
                            icon: Iconsax.home_2,
                            activeIcon: Iconsax.home_25,
                            label: 'Home',
                            isSelected: selectedIndex == 0,
                            foreground: foreground,
                            isDark: isDark,
                            onTap: () => onTap(0),
                          ),
                        ),
                        Expanded(
                          child: _NavBarItem(
                            icon: Iconsax.category,
                            activeIcon: Iconsax.category5,
                            label: 'Explore',
                            isSelected: selectedIndex == 1,
                            foreground: foreground,
                            isDark: isDark,
                            onTap: () => onTap(1),
                          ),
                        ),
                        Expanded(
                          child: _NavBarItem(
                            icon: Iconsax.setting_2,
                            activeIcon: Iconsax.setting_25,
                            label: 'Settings',
                            isSelected: selectedIndex == 2,
                            foreground: foreground,
                            isDark: isDark,
                            onTap: () => onTap(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Material(
                  color: glassColor,
                  child: InkWell(
                    onTap: onAction,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.add,
                        size: 29,
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color foreground;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.foreground,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? Colors.white : const Color(0xFF171923);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withOpacity(0.13)
                  : Colors.black.withOpacity(0.055))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(29),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.055)
                      : Colors.black.withOpacity(0.035),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(29),
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      size: 22,
                      color: isSelected
                          ? selectedColor
                          : foreground.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      color: isSelected
                          ? selectedColor
                          : foreground.withOpacity(0.72),
                      fontSize: 11,
                      height: 1,
                      fontWeight:
                          isSelected ? FontWeight.w650 : FontWeight.w500,
                      letterSpacing: 0.05,
                    ),
                    child: Text(label),
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
