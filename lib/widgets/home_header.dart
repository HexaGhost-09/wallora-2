import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: Padding(
        // REDUCED PADDING
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // LOGO (Original Colors)
                Image.asset(
                  'assets/icon/icon.png',
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  'Wallora',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_rounded, size: 28, color: textColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}