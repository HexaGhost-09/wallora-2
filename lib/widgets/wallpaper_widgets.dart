import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalloraAppBar extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onFavoritesPressed;

  const WalloraAppBar({
    super.key,
    required this.onSearchPressed,
    required this.onFavoritesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      title: Text(
        'Wallora',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: onSearchPressed,
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded),
          onPressed: onFavoritesPressed,
        ),
      ],
    );
  }
}
