import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper_model.dart';

class WalloraAPI {
  static const String baseUrl = 'https://wallora-wallpapers.deno.dev/api';

  static Future<List<Wallpaper>> getWallpapers() async {
    final uri = Uri.parse('$baseUrl/wallpapers');

    final response = await http.get(uri);

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // IMPORTANT: API returns LIST directly
      final List data = decoded;

      return data.map((e) => Wallpaper.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}
