import 'package:postgres/postgres.dart';

const _neonHost =
    'ep-sparkling-dust-a7v4is48-pooler.ap-southeast-2.aws.neon.tech';
const _neonDatabase = 'neondb';
const _neonUser = 'neondb_owner';
const _neonPassword = 'npg_tuKfs4nH0wZa';

Future<void> main() async {
  final conn = await Connection.open(
    Endpoint(
      host: _neonHost,
      database: _neonDatabase,
      username: _neonUser,
      password: _neonPassword,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  try {
    print('Creating wallpaper_likes table...');
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS wallpaper_likes (
        id SERIAL PRIMARY KEY,
        user_id TEXT NOT NULL,
        wallpaper_id TEXT NOT NULL,
        UNIQUE(user_id, wallpaper_id)
      );
    ''');

    print('Checking for likes_count column in wallpapers...');
    final result = await conn.execute(
      "SELECT column_name FROM information_schema.columns WHERE table_name = 'wallpapers' AND column_name = 'likes_count';",
    );

    if (result.isEmpty) {
      print('Adding likes_count column to wallpapers...');
      await conn.execute(
        'ALTER TABLE wallpapers ADD COLUMN likes_count INTEGER DEFAULT 0;',
      );
    } else {
      print('likes_count column already exists.');
    }

    print('Database migration completed.');
  } finally {
    await conn.close();
  }
}
