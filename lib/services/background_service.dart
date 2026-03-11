import 'package:flutter/foundation.dart';
import 'background_service_impl.dart';

const updateTaskString = "checkUpdatesTask";


class BackgroundService {
  static final BackgroundService instance = BackgroundService._();
  BackgroundService._();

  Future<void> init() async {
    // workmanager only works on Android & iOS.
    // On desktop (Windows, Linux, macOS) and Web we skip background tasks.
    if (kIsWeb) return;

    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!isMobile) return;

    await _initWorkmanager();
  }

  Future<void> _initWorkmanager() async {
    try {
      await BackgroundServiceImpl.run();
    } catch (e) {
      debugPrint('[BackgroundService] workmanager init error: $e');
    }
  }
}
