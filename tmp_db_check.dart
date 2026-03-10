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
    print('Checking wallpapers table columns...');
    final result = await conn.execute(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'wallpapers';",
    );
    for (final row in result) {
      print(' - ${row[0]}: ${row[1]}');
    }

    print('\nTotal wallpapers:');
    final count = await conn.execute("SELECT count(*) FROM wallpapers;");
    print(count[0][0]);
  } finally {
    await conn.close();
  }
}
