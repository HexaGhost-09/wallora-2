// Mobile implementation using workmanager.
// This file is only imported on dart:io platforms (Android, iOS, desktop).
// The BackgroundService.init() method further guards execution to
// Android & iOS only at runtime.

import 'package:workmanager/workmanager.dart';
import 'update_service.dart';
import 'notification_service.dart';

const _updateTaskString = "checkUpdatesTask";

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _updateTaskString) {
      await NotificationService.instance.init();
      await UpdateService.instance.checkForUpdates(
        force: true,
        showNotification: true,
      );
    }
    return Future.value(true);
  });
}

/// Initialises workmanager and registers a daily update-check task.
/// Only called by [BackgroundService.init()] when running on Android/iOS.
Future<void> initBackgroundWorker() async {
  await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);

  await Workmanager().registerPeriodicTask(
    "1",
    _updateTaskString,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
