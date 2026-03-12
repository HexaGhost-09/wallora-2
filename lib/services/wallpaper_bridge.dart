// Conditional bridge for async_wallpaper.
// Imports the real implementation on dart:io platforms (Android/iOS/desktop)
// and a stub on web.
//
// The BackgroundService + wallpaper_view also guard at runtime so this
// only actually CALLS the plugin on Android/iOS.

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart';

/// Calls AsyncWallpaper.setWallpaper with the given URL and location.
/// Location constants: 1 = home, 2 = lock, 3 = both.
class AsyncWallpaperBridge {
  static Future<String> setWallpaper(String url, int location) async {
    try {
      final bool result = await AsyncWallpaper.setWallpaper(
        url: url,
        wallpaperLocation: location,
        goToHome: false,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      );
      return result ? 'Wallpaper set' : 'Failed to set wallpaper';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }
}
