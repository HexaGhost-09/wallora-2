import 'package:workmanager/workmanager.dart';
import 'update_service.dart';
import 'notification_service.dart';

const updateTaskString = "checkUpdatesTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == updateTaskString) {
      await NotificationService.instance.init();
      // Force a check and show the notification if there's an update
      await UpdateService.instance.checkForUpdates(force: true, showNotification: true);
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static final BackgroundService instance = BackgroundService._();
  BackgroundService._();

  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register a periodic task to run approximately once a day
    await Workmanager().registerPeriodicTask(
      "1",
      updateTaskString,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
