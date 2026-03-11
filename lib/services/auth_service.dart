import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AuthService {
  static const String authBaseUrl =
      'https://ep-sparkling-dust-a7v4is48.neonauth.ap-southeast-2.aws.neon.tech/neondb/auth';
  static const String _origin = 'https://localhost:3000';

  static final AuthService _instance = AuthService._internal();
  AuthService._internal();
  static AuthService get instance => _instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Cross-platform POST using the `http` package (works on all platforms
  /// including Web, unlike dart:io HttpClient).
  Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$authBaseUrl$path');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Origin': _origin,
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('[AuthService] $path → ${response.statusCode}: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('[AuthService] POST $path exception: $e');
      return null;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? image,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'callbackURL': _origin,
    };
    if (image != null) body['image'] = image;

    final data = await _post('/sign-up/email', body);
    if (data == null) return false;

    _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _saveUserToPrefs(data);

    // Clear cache
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('cache_wallpapers_'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }

    return true;
  }

  Future<bool> signIn({required String email, required String password}) async {
    final data = await _post('/sign-in/email', {
      'email': email,
      'password': password,
      'rememberMe': true,
    });
    if (data == null) return false;

    final userData = data['user'] as Map<String, dynamic>?;
    if (userData == null) return false;

    _currentUser = UserModel.fromJson(userData);
    await _saveUserToPrefs(data);

    // Clear wallpaper cache so we fetch new likes for this user
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('cache_wallpapers_'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }

    return true;
  }

  Future<bool> signInWithProvider(String provider) async {
    try {
      final url = Uri.parse('$authBaseUrl/sign-in/$provider');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AuthService] OAuth SignIn Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');

    // Clear wallpaper cache on sign out
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('cache_wallpapers_'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> _saveUserToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = data['user'];
    // Better Auth returns token at root level: { token, user, redirect }
    final token =
        data['token']?.toString() ??
        (data['session']?['token'])?.toString() ??
        '';

    await prefs.setString('user_data', json.encode(userData));
    await prefs.setString('auth_token', token);
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(
          json.decode(userData) as Map<String, dynamic>,
        );
        return true;
      } catch (_) {
        await prefs.remove('user_data');
      }
    }
    return false;
  }

  String? get token => null;
}
