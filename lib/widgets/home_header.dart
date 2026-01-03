import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LOGO + TEXT
            Row(
              children: [
                Image.asset(
                  'assets/icon/icon.png',
                  height: 28, // ✅ perfect for title text
                  width: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  'Wallora',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            /// RIGHT ICON
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
