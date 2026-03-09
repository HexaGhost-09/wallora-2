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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBarItem(
                    icon: Iconsax.home,
                    activeIcon: Iconsax.home_1,
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavBarItem(
                    icon: Iconsax.grid_5,
                    activeIcon: Iconsax.grid_1,
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavBarItem(
                    icon: Iconsax.setting_2,
                    activeIcon: Iconsax.setting,
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavBarItem(
                    icon: Iconsax.monitor,
                    activeIcon: Iconsax.monitor,
                    isSelected: selectedIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavBarItem(
                    icon: Iconsax.user,
                    activeIcon: Iconsax.user_tick,
                    isSelected: selectedIndex == 4,
                    onTap: () => onTap(4),
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
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : Colors.grey.withOpacity(0.6),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isSelected ? 4 : 0,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}