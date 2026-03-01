import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_model.dart';
import '../models/category.dart';

class WalloraAPI {
  static const String baseUrl = 'https://wallora-wallpapers.deno.dev';

  static Future<List<Wallpaper>> getWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'cache_wallpapers_all';

    try {
      final response = await http.get(Uri.parse('$baseUrl/wallpapers'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        final List data = json.decode(response.body);
        return data.map((e) => Wallpaper.fromJson(e)).toList();
      }
    } catch (e) {
      // Fallback to cache when offline
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final List data = json.decode(cachedData);
      return data.map((e) => Wallpaper.fromJson(e)).toList();
    }
    throw Exception('Failed to load wallpapers');
  }

  static Future<List<Wallpaper>> getWallpapersByCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cache_wallpapers_$categoryId';

    try {
      final response = await http.get(Uri.parse('$baseUrl/wallpapers/$categoryId'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        final List data = json.decode(response.body);
        return data.map((e) => Wallpaper.fromJson(e)).toList();
      }
    } catch (e) {
      // Fallback to cache when offline
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final List data = json.decode(cachedData);
      return data.map((e) => Wallpaper.fromJson(e)).toList();
    }
    throw Exception('Failed to load wallpapers for category $categoryId');
  }

  static Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'cache_categories';

    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        final List data = json.decode(response.body);
        return data.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      // Fallback to cache when offline
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final List data = json.decode(cachedData);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }
}

