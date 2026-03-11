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

class BackgroundServiceImpl {
  static Future<void> run() async {
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      "1",
      _updateTaskString,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
