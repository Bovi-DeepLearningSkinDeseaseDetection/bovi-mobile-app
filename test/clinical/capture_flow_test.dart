import 'dart:typed_data';

import 'package:bov_mobile_app/clinical/application/internal/commandservices/detection_pipeline_service.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/captured_image.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/image_quality.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/model_input.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/image_preview_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/low_resolution_dialog.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/widgets/connection_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CapturedImage _image({
  ImageOrigin origin = ImageOrigin.camera,
  int width = 720,
  int height = 1280,
}) => CapturedImage(
  path: 'missing.jpg',
  origin: origin,
  width: width,
  height: height,
);

/// Pipeline that returns a fixed outcome without reading the image.
class _FakePipeline extends DetectionPipelineService {
  final DetectionOutcome outcome;

  _FakePipeline(this.outcome);

  @override
  Future<DetectionOutcome> run(CapturedImage image) async => outcome;
}

ImageQualityReport _report(List<ImageQualityIssue> issues) =>
    ImageQualityReport(
      sharpness: 0,
      meanBrightness: 0,
      darkRatio: 0,
      brightRatio: 0,
      issues: issues,
    );

final _ready = ReadyForInference(
  ModelInput(Float32List(224 * 224 * 3)),
  _report([]),
);

/// Pushes [page] and returns a getter for the value it pops with.
Future<T? Function()> _pushAndCapture<T>(
  WidgetTester tester,
  Widget Function(BuildContext) page,
) async {
  T? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await Navigator.of(
                context,
              ).push<T>(MaterialPageRoute(builder: page));
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  group('CapturedImage (RF1: minimum 720p)', () {
    test('accepts 720p in portrait and landscape', () {
      expect(_image(width: 720, height: 1280).meetsMinimumResolution, isTrue);
      expect(_image(width: 1280, height: 720).meetsMinimumResolution, isTrue);
    });

    test('rejects images below 720p', () {
      expect(_image(width: 640, height: 480).meetsMinimumResolution, isFalse);
      expect(_image(width: 719, height: 4000).meetsMinimumResolution, isFalse);
    });
  });

  group('ImagePreviewPage', () {
    // HU01, scenarios 1 and 3.
    testWidgets('a camera photo offers "Analizar" and "Repetir"', (
      tester,
    ) async {
      final result = await _pushAndCapture<PreviewDecision>(
        tester,
        (_) => ImagePreviewPage(image: _image()),
      );

      expect(find.text('Analizar'), findsOneWidget);
      expect(find.text('Repetir'), findsOneWidget);

      await tester.tap(find.text('Repetir'));
      await tester.pumpAndSettle();
      expect(result(), PreviewDecision.retake);
    });

    // HU02, scenario 1.
    testWidgets('a gallery image offers "Analizar" and "Elegir otra"', (
      tester,
    ) async {
      await _pushAndCapture<PreviewDecision>(
        tester,
        (_) => ImagePreviewPage(image: _image(origin: ImageOrigin.gallery)),
      );

      expect(find.text('Analizar'), findsOneWidget);
      expect(find.text('Elegir otra'), findsOneWidget);
    });

    // HU04, scenario 1 and HU05, scenario 3: no extra action is requested.
    testWidgets('a valid photo continues to the analysis', (tester) async {
      final result = await _pushAndCapture<PreviewDecision>(
        tester,
        (_) =>
            ImagePreviewPage(image: _image(), pipeline: _FakePipeline(_ready)),
      );

      await tester.tap(find.text('Analizar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(result(), PreviewDecision.analyze);
    });

    // HU04, scenario 2.
    testWidgets('a blurry photo is not analyzed and can be retaken', (
      tester,
    ) async {
      final result = await _pushAndCapture<PreviewDecision>(
        tester,
        (_) => ImagePreviewPage(
          image: _image(),
          pipeline: _FakePipeline(
            RejectedByQuality(_report([ImageQualityIssue.blurry])),
          ),
        ),
      );

      await tester.tap(find.text('Analizar'));
      await tester.pumpAndSettle();
      expect(find.text(ImageQualityIssue.blurry.message), findsOneWidget);

      await tester.tap(find.text('Tomar otra foto'));
      await tester.pumpAndSettle();
      expect(result(), PreviewDecision.retake);
    });

    // Doubtful photo: the user is guided but can still analyze it.
    testWidgets('a slightly blurry photo can be analyzed anyway', (
      tester,
    ) async {
      final result = await _pushAndCapture<PreviewDecision>(
        tester,
        (_) => ImagePreviewPage(
          image: _image(),
          pipeline: _FakePipeline(
            QualityWarning(
              ModelInput(Float32List(224 * 224 * 3)),
              ImageQualityReport(
                sharpness: 0,
                meanBrightness: 0,
                darkRatio: 0,
                brightRatio: 0,
                issues: const [],
                warnings: const [ImageQualityIssue.blurry],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Analizar'));
      await tester.pumpAndSettle();
      expect(find.text('La foto podría mejorar'), findsOneWidget);
      expect(
        find.text(ImageQualityIssue.blurry.warningMessage),
        findsOneWidget,
      );

      await tester.tap(find.text('Analizar de todos modos'));
      await tester.pumpAndSettle();
      expect(result(), PreviewDecision.analyze);
    });

    // HU04, scenario 3: the exposure message comes before the blur one.
    testWidgets('a dark photo shows the natural light advice', (tester) async {
      await _pushAndCapture<PreviewDecision>(
        tester,
        (_) => ImagePreviewPage(
          image: _image(),
          pipeline: _FakePipeline(
            RejectedByQuality(
              _report([ImageQualityIssue.dark, ImageQualityIssue.blurry]),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Analizar'));
      await tester.pumpAndSettle();
      expect(find.text(ImageQualityIssue.dark.message), findsOneWidget);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Analizar'), findsOneWidget);
    });
  });

  // HU02, scenario 2.
  testWidgets('the low-resolution warning suggests taking a new photo', (
    tester,
  ) async {
    LowResolutionChoice? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  choice = await showLowResolutionDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Resolución insuficiente'), findsOneWidget);
    await tester.tap(find.text('Tomar foto'));
    await tester.pumpAndSettle();
    expect(choice, LowResolutionChoice.takePhoto);
  });

  testWidgets('the connection chip shows the network status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConnectionStatusChip(isOnline: false)),
    );
    expect(find.text(ConnectionStatusChip.offlineText), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: ConnectionStatusChip(isOnline: true)),
    );
    expect(find.text(ConnectionStatusChip.onlineText), findsOneWidget);
  });
}
