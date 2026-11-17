import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeAccent {
  final String name;
  final Color color;
  const ThemeAccent(this.name, this.color);
}

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();
  ThemeService._internal();

  static const String _themeKey = 'theme_mode';
  static const String _accentKey = 'theme_accent';
  static const String _adaptiveKey = 'adaptive_wallpaper_accent';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = const Color(0xFF6366F1);
  bool _adaptiveWallpaperAccent = false;

  static const List<ThemeAccent> presets = [
    ThemeAccent('Indigo', Color(0xFF6366F1)),
    ThemeAccent('Ocean', Color(0xFF0284C7)),
    ThemeAccent('Emerald', Color(0xFF059669)),
    ThemeAccent('Rose', Color(0xFFE11D48)),
    ThemeAccent('Amber', Color(0xFFD97706)),
    ThemeAccent('Violet', Color(0xFF8B5CF6)),
    ThemeAccent('Teal', Color(0xFF0D9488)),
    ThemeAccent('Slate', Color(0xFF64748B)),
  ];

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get adaptiveWallpaperAccent => _adaptiveWallpaperAccent;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme != null) {
      _themeMode = ThemeMode.system;
    }
    _accentColor = Color(_prefs.getInt(_accentKey) ?? 0xFF6366F1);
    _adaptiveWallpaperAccent = _prefs.getBool(_adaptiveKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _prefs.setString(_themeKey, value);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    _adaptiveWallpaperAccent = false;
    await _prefs.setInt(_accentKey, color.value);
    await _prefs.setBool(_adaptiveKey, false);
    notifyListeners();
  }

  Future<void> setAdaptiveWallpaperAccent(bool enabled) async {
    _adaptiveWallpaperAccent = enabled;
    await _prefs.setBool(_adaptiveKey, enabled);
    notifyListeners();
  }

  Future<bool> applyWallpaperAccent(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) return false;
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: 32,
        targetHeight: 32,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (data == null) return false;

      Color? best;
      double bestScore = 0;
      for (int i = 0; i < data.lengthInBytes; i += 4) {
        final red = data.getUint8(i);
        final green = data.getUint8(i + 1);
        final blue = data.getUint8(i + 2);
        final color = Color.fromARGB(255, red, green, blue);
        final hsv = HSVColor.fromColor(color);
        if (hsv.value < 0.28 || hsv.value > 0.92 || hsv.saturation < 0.28) {
          continue;
        }
        final score = hsv.saturation * (1 - (hsv.value - 0.62).abs());
        if (score > bestScore) {
          bestScore = score;
          best = color;
        }
      }
      frame.image.dispose();
      codec.dispose();
      if (best == null) return false;
      _accentColor = best;
      _adaptiveWallpaperAccent = true;
      await _prefs.setInt(_accentKey, best.value);
      await _prefs.setBool(_adaptiveKey, true);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
