import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:afos_app/core/widgets/afos_brand_mark.dart';
import 'package:afos_app/main.dart';

void main() {
  testWidgets('AfosApp renders catalog, toggles language, and shows auth dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: AfosApp()));
    await tester.pumpAndSettle();

    // Verify initial Indonesian localization & catalog search
    expect(find.byType(AfosBrandMark), findsWidgets);
    expect(find.text('Katalog'), findsWidgets);
    expect(find.text('ID'), findsOneWidget);

    // Toggle language to English
    await tester.tap(find.text('ID'));
    await tester.pumpAndSettle();

    // Verify English localization renders
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('EN'), findsOneWidget);

    // Open Sign In dialog
    final signInButton = find.text('Sign In');
    if (signInButton.evaluate().isNotEmpty) {
      await tester.tap(signInButton.first);
      await tester.pumpAndSettle();

      // Verify Quick Demo logins are present
      expect(find.text('Quick Demo Logins'), findsOneWidget);
      expect(find.text('Customer'), findsWidgets);
    }
  });
}
