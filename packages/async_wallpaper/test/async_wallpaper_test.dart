import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:async_wallpaper/async_wallpaper.dart';

void main() {
  const channel = MethodChannel('async_wallpaper');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await AsyncWallpaper.platformVersion, '42');
  });
}
