import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AuthService {
  static const String authBaseUrl = 'https://ep-sparkling-dust-a7v4is48.neonauth.ap-southeast-2.aws.neon.tech/neondb/auth';

  static final AuthService _instance = AuthService._internal();
  AuthService._internal();
  static AuthService get instance => _instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/sign-up/email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'image': image,
          'callbackURL': 'https://localhost:3000', // Neon Auth needs a callback even for mobile
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentUser = UserModel.fromJson(data['user'] ?? data['data']?['user']);
        await _saveUserToPrefs(data);
        return true;
      }
      return false;
    } catch (e) {
      print('SignUp Error: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/sign-in/email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'rememberMe': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // data usually contains { user: {...}, session: {...} }
        final userData = data['user'] ?? data['data']?['user'] ?? data;
        _currentUser = UserModel.fromJson(userData);
        await _saveUserToPrefs(data);
        return true;
      }
      return false;
    } catch (e) {
      print('SignIn Error: $e');
      return false;
    }
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
      print('OAuth SignIn Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
  }

  Future<void> _saveUserToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = data['user'] ?? data['data']?['user'] ?? data;
    final token = data['session']?['token'] ?? data['data']?['session']?['token'] ?? '';
    
    await prefs.setString('user_data', json.encode(userData));
    await prefs.setString('auth_token', token);
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _currentUser = UserModel.fromJson(json.decode(userData));
      return true;
    }
    return false;
  }

  String? get token {
    // Ideally retrieve from prefs or state
    return null;
  }
}
