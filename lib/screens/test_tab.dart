import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';

class TestTab extends StatefulWidget {
  const TestTab({super.key});

  @override
  State<TestTab> createState() => _TestTabState();
}

class _TestTabState extends State<TestTab> {
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTestWallpapers();
  }

  Future<void> _fetchTestWallpapers() async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: 'ep-sparkling-dust-a7v4is48-pooler.ap-southeast-2.aws.neon.tech',
          database: 'neondb',
          username: 'neondb_owner',
          password: 'npg_tuKfs4nH0wZa',
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );

      final result = await connection.execute('SELECT * FROM test_wallpapers');
      
      final wallpapers = result.map((row) {
        return Wallpaper(
          id: row[0].toString(),
          category: row[1].toString(),
          title: row[2].toString(),
          image: row[3].toString(),
          download: row[4].toString(),
          timestamp: row[5].toString(),
        );
      }).toList();

      await connection.close();

      if (mounted) {
        setState(() {
          _wallpapers = wallpapers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load test wallpapers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchTestWallpapers();
                },
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Neon Test'),
        centerTitle: true,
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Bottom padding for navbar
        itemCount: _wallpapers.length,
        itemBuilder: (context, index) {
          final aspectRatios = [1.2, 1.5, 1.8];
          final ratio = aspectRatios[index % aspectRatios.length];
          return AspectRatio(
            aspectRatio: 1 / ratio,
            child: WallpaperCard(
              wallpaper: _wallpapers[index],
              index: index,
            ),
          );
        },
      ),
    );
  }
}
