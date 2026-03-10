import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallora',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Explore unique wallpapers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Iconsax.search_normal, size: 24, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
