import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallora/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('take screenshot', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.pumpAndSettle(const Duration(seconds: 5));

    await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot('screenshot.png');
  });
}
