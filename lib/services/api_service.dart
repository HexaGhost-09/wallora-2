import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper_model.dart';

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
}
