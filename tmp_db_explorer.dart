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

  print('Connected to database.');

  try {
    final tables = await conn.execute(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';",
    );
    print('Tables:');
    for (final row in tables) {
      print(' - ${row[0]}');
    }

    final columns = await conn.execute(
      "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' ORDER BY table_name;",
    );
    print('\nColumns:');
    for (final row in columns) {
      print(' - ${row[0]}.${row[1]} (${row[2]})');
    }
  } finally {
    await conn.close();
  }
}
