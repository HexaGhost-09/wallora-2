import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper_model.dart';
import '../models/category.dart';


class WalloraAPI {
  static const String baseUrl = 'https://wallora-wallpapers.deno.dev';

  static Future<List<Wallpaper>> getWallpapers() async {
    final response = await http.get(Uri.parse('$baseUrl/wallpapers'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Wallpaper.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  static Future<List<Wallpaper>> getWallpapersByCategory(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/wallpapers/$categoryId'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Wallpaper.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load wallpapers for category $categoryId');
    }
  }

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

