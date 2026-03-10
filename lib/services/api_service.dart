import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_model.dart';
import '../models/category.dart';

/// Database credentials — same Neon instance used by the web admin.
const _neonHost     = 'ep-sparkling-dust-a7v4is48-pooler.ap-southeast-2.aws.neon.tech';
const _neonDatabase = 'neondb';
const _neonUser     = 'neondb_owner';
const _neonPassword = 'npg_tuKfs4nH0wZa';

class WalloraAPI {
  /// Open a short-lived Neon connection, run [query], then close it.
  static Future<Connection> _connect() async {
    return Connection.open(
      Endpoint(
        host: _neonHost,
        database: _neonDatabase,
        username: _neonUser,
        password: _neonPassword,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
  }

  // ── Wallpapers ─────────────────────────────────────────────────────────────

  static Future<List<Wallpaper>> getWallpapers({bool forceRefresh = false}) async {
    const cacheKey = 'cache_wallpapers_all';
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final List data = json.decode(cached);
          final wallpapers = data.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>)).toList();
          if (wallpapers.isNotEmpty) return wallpapers;
        } catch (_) {}
      }
    }

    try {
      final conn = await _connect();
      final result = await conn.execute(
        'SELECT id, category, title, image, download, timestamp FROM wallpapers ORDER BY timestamp DESC',
      );
      await conn.close();

      final wallpapers = _rowsToWallpapers(result);
      await prefs.setString(cacheKey, json.encode(wallpapers.map(_wpToJson).toList()));
      return wallpapers;
    } catch (e) {
      // Final fallback if fetch fails and we didn't return from cache already
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final List data = json.decode(cached);
        return data.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  static Future<List<Wallpaper>> getWallpapersByCategory(String categoryId, {bool forceRefresh = false}) async {
    final cacheKey = 'cache_wallpapers_$categoryId';
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final List data = json.decode(cached);
          final wallpapers = data.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>)).toList();
          if (wallpapers.isNotEmpty) return wallpapers;
        } catch (_) {}
      }
    }

    try {
      final conn = await _connect();
      final result = await conn.execute(
        Sql.named(
          'SELECT id, category, title, image, download, timestamp '
          'FROM wallpapers WHERE category = @cat ORDER BY timestamp DESC',
        ),
        parameters: {'cat': categoryId},
      );
      await conn.close();

      final wallpapers = _rowsToWallpapers(result);
      await prefs.setString(cacheKey, json.encode(wallpapers.map(_wpToJson).toList()));
      return wallpapers;
    } catch (e) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final List data = json.decode(cached);
        return data.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  static Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    const cacheKey = 'cache_categories';
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final List data = json.decode(cached);
          final categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
          if (categories.isNotEmpty) return categories;
        } catch (_) {}
      }
    }

    try {
      final conn = await _connect();
      final result = await conn.execute(
        'SELECT id, title, thumbnail, details FROM categories ORDER BY title ASC',
      );
      await conn.close();

      final categories = result.map((row) {
        return Category(
          id:        row[0].toString(),
          title:     row[1].toString(),
          thumbnail: row[2].toString(),
          details:   row[3]?.toString() ?? '',
        );
      }).toList();

      await prefs.setString(
        cacheKey,
        json.encode(categories.map((c) => {
          'id': c.id, 'title': c.title,
          'thumbnail': c.thumbnail, 'details': c.details,
        }).toList()),
      );
      return categories;
    } catch (e) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        final List data = json.decode(cached);
        return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<Wallpaper> _rowsToWallpapers(List<ResultRow> rows) {
    return rows.map((row) {
      return Wallpaper(
        id:        row[0].toString(),
        category:  row[1].toString(),
        title:     row[2].toString(),
        image:     row[3].toString(),
        download:  row[4].toString(),
        timestamp: row[5]?.toString() ?? '',
      );
    }).toList();
  }

  static Map<String, dynamic> _wpToJson(Wallpaper w) => {
    'id': w.id,
    'category': w.category,
    'title': w.title,
    'image': w.image,
    'download': w.download,
    'timestamp': w.timestamp,
  };
}
