// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Verify platform version is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyApp()));

    // Allow the asynchronous platform-version method call to complete.
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && (widget.data ?? '').startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
}
