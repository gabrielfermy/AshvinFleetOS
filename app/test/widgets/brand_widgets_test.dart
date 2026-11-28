import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/core/theme/afos_colors.dart';
import 'package:afos_app/core/theme/afos_typography.dart';
import 'package:afos_app/core/widgets/afos_brand_mark.dart';
import 'package:afos_app/core/widgets/afos_status_badge.dart';

void main() {
  group('AFOS Brand Suite Widgets & Tokens Tests', () {
    testWidgets('AfosBrandMark renders monogram and wordmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AfosBrandMark(size: 40),
          ),
        ),
      );

      expect(find.byType(AfosBrandMark), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Ashvin FleetOS'), findsOneWidget);
      expect(find.text('AFOS'), findsOneWidget);
    });

    testWidgets('AfosBrandMark compact mode renders AFOS monogram', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AfosBrandMark(size: 28, compact: true),
          ),
        ),
      );

      expect(find.text('AFOS'), findsOneWidget);
    });

    testWidgets('AfosStatusBadge renders vehicle status correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AfosStatusBadge.vehicleStatus('AVAILABLE', localizedLabel: 'Tersedia'),
                AfosStatusBadge.vehicleStatus('ON_RENTAL', localizedLabel: 'Disewa'),
                AfosStatusBadge.serviceType('SELF_DRIVE', localizedLabel: 'Lepas Kunci'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('Disewa'), findsOneWidget);
      expect(find.text('Lepas Kunci'), findsOneWidget);
    });

    test('AfosColors tokens match official Brand Suite specifications', () {
      expect(AfosColors.primaryNavy, const Color(0xFF0F2537));
      expect(AfosColors.jogjaTeal, const Color(0xFF0E7C7B));
      expect(AfosColors.warmAmber, const Color(0xFFD97706));
      expect(AfosColors.emeraldVerified, const Color(0xFF15803D));
      expect(AfosColors.crimsonAlert, const Color(0xFFB91C1C));
      expect(AfosColors.slateMist, const Color(0xFFF8FAFC));
      expect(AfosColors.charcoalInk, const Color(0xFF1E293B));
    });

    test('AfosTypography exposes tabular figures for technical data', () {
      expect(AfosTypography.licensePlate.fontFamily, contains('JetBrainsMono'));
      expect(AfosTypography.odometer.fontFamily, contains('JetBrainsMono'));
      expect(AfosTypography.currency.fontFamily, contains('JetBrainsMono'));
      expect(AfosTypography.auditLog.fontFamily, contains('JetBrainsMono'));
    });
  });
}
