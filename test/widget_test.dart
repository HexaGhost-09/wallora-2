// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallora/main.dart';

void main() {
  testWidgets('Wallora app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WalloraApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that app title "Wallora" exists
    expect(find.text('Wall'), findsOneWidget);
    expect(find.text('ora'), findsOneWidget);

    // Verify search icon exists
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // Verify favorites icon exists
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);

    // Verify "Discover" header exists
    expect(find.text('Discover'), findsOneWidget);

    // Verify Categories section exists
    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('Test surprise me button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const WalloraApp());
    await tester.pumpAndSettle();

    // Verify "Surprise Me" FAB exists
    expect(find.text('Surprise Me'), findsOneWidget);
    expect(find.byIcon(Icons.shuffle_rounded), findsOneWidget);
  });

  testWidgets('Test navigation elements', (WidgetTester tester) async {
    await tester.pumpWidget(const WalloraApp());
    await tester.pumpAndSettle();

    // Test search button tap (should not crash)
    final searchButton = find.byIcon(Icons.search_rounded);
    await tester.tap(searchButton);
    await tester.pump();

    // App should still be running
    expect(find.text('Wall'), findsOneWidget);
  });
}
