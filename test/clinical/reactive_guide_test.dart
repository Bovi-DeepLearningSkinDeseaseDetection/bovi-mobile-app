import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/focus_ring.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/guide_frame.dart';
import 'package:bov_mobile_app/shared/infrastructure/sensors/device_motion_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SteadinessDetector', () {
    final start = DateTime(2026);
    DateTime at(int ms) => start.add(Duration(milliseconds: ms));

    test('becomes steady only after staying calm for the settle time', () {
      final detector = SteadinessDetector();
      expect(detector.add(0.01, at(0)), isFalse);
      expect(detector.add(0.01, at(200)), isFalse);
      expect(detector.add(0.01, at(450)), isTrue);
    });

    test('a shake makes it move again', () {
      final detector = SteadinessDetector();
      for (var ms = 0; ms <= 500; ms += 20) {
        detector.add(0.01, at(ms));
      }
      expect(detector.isSteady, isTrue);
      for (var ms = 520; ms <= 600; ms += 20) {
        detector.add(2.0, at(ms));
      }
      expect(detector.isSteady, isFalse);
    });

    test('a small tremor between both limits keeps the current state', () {
      final detector = SteadinessDetector();
      for (var ms = 0; ms <= 500; ms += 20) {
        detector.add(0.01, at(ms));
      }
      for (var ms = 520; ms <= 1000; ms += 20) {
        detector.add(0.2, at(ms));
      }
      expect(detector.isSteady, isTrue);
    });
  });

  group('tapToPreviewPoint', () {
    const viewfinder = Size(360, 624);
    const preview = Size(720, 1280); // Portrait.

    test('the center of the viewfinder is the center of the preview', () {
      final point = tapToPreviewPoint(
        const Offset(180, 312),
        viewfinder,
        preview,
      );
      expect(point.dx, closeTo(0.5, 1e-9));
      expect(point.dy, closeTo(0.5, 1e-9));
    });

    test('accounts for the edges cropped by BoxFit.cover', () {
      // The preview is shown at 360×640, so 8 px are cropped top and bottom.
      final point = tapToPreviewPoint(Offset.zero, viewfinder, preview);
      expect(point.dx, closeTo(0, 1e-9));
      expect(point.dy, closeTo(8 / 640, 1e-9));
    });
  });

  group('GuideFrame', () {
    testWidgets('asks to hold the phone still while it moves', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GuideFrame(isSteady: false))),
      );
      expect(find.text(GuideFrame.holdStillText), findsOneWidget);
      expect(find.text(GuideFrame.distanceText), findsOneWidget);
    });

    testWidgets('shows the framing instruction once the phone is steady', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GuideFrame(isSteady: false))),
      );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GuideFrame(isSteady: true))),
      );
      await tester.pumpAndSettle();
      expect(find.text(GuideFrame.instructionText), findsOneWidget);
      expect(find.text(GuideFrame.holdStillText), findsNothing);
    });
  });
}
