import 'package:postgres/postgres.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: 'ep-sparkling-dust-a7v4is48-pooler.ap-southeast-2.aws.neon.tech',
      database: 'neondb',
      username: 'neondb_owner',
      password: 'npg_tuKfs4nH0wZa',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  await conn.execute('''
    CREATE TABLE IF NOT EXISTS wallpaper_saved (
      wallpaper_id VARCHAR(255) NOT NULL,
      user_id VARCHAR(255) NOT NULL,
      saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (wallpaper_id, user_id)
    );
  ''');

  print('Table wallpaper_saved created successfully.');
  await conn.close();
}
