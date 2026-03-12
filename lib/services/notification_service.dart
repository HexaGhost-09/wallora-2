import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
void notificationTapBackground(
  NotificationResponse notificationResponse,
) async {
  if (notificationResponse.payload != null) {
    final uri = Uri.parse(notificationResponse.payload!);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $uri: $e');
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether this platform supports local notifications.
  bool get _isSupported {
    if (kIsWeb) return false;
    // flutter_local_notifications supports:
    //   Android, iOS, macOS, Linux
    // It does NOT support Windows or Web.
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> init() async {
    if (!_isSupported) return;

    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // macOS / iOS settings
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux settings
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final uri = Uri.parse(response.payload!);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('Could not launch $uri: $e');
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permissions on Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showUpdateNotification(String version, String url) async {
    if (!_isSupported) return;

    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'update_channel_id',
      'App Updates',
      channelDescription: 'Notifications for new app updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Darwin (iOS/macOS) notification details
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Linux notification details
    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    await _plugin.show(
      id: 0,
      title: 'Update Available!',
      body: 'Wallora v$version is available to download.',
      notificationDetails: details,
      payload: url,
    );
  }
}
