import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:afos_app/main.dart';

void main() {
  testWidgets('AfosApp renders adaptive navigation and toggles language',
      (WidgetTester tester) async {
    // Set a desktop surface size for the test
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: AfosApp()));
    await tester.pumpAndSettle();

    // Verify initial Indonesian localization renders
    expect(find.text('Ashvin FleetOS'), findsWidgets);
    expect(find.text('Katalog'), findsWidgets);
    expect(find.text('ID'), findsOneWidget);

    // Toggle language to English
    await tester.tap(find.text('ID'));
    await tester.pumpAndSettle();

    // Verify English localization renders
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('EN'), findsOneWidget);
  });
}
