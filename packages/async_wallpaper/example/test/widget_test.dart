// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  const channel = MethodChannel('async_wallpaper');

  testWidgets('Verify platform version is displayed', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getPlatformVersion') {
        return 'Test platform';
      }
      return null;
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const MaterialApp(home: MyApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Running on: Test platform'), findsOneWidget);
  });
}
