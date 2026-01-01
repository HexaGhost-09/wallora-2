import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper_model.dart';

class WalloraAPI {
  static const String baseUrl = 'https://wallora-wallpapers.deno.dev';

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['categories']);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
    return ['nature', 'cars', 'anime'];
  }

  static Future<List<Wallpaper>> getWallpapers({String? category}) async {
    try {
      final url = category != null
          ? '$baseUrl/categories/$category'
          : '$baseUrl/wallpapers';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wallpapers = data['wallpapers'] as List;
        return wallpapers.map((w) => Wallpaper.fromJson(w)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    }
    return [];
  }
}
