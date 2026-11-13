import 'dart:typed_data';

import 'package:bov_mobile_app/clinical/domain/services/history_restore_gateway.dart';
import 'package:bov_mobile_app/clinical/infrastructure/http/history_restore_http_gateway.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/restore_history_page.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'restore_fakes.dart';

class _Answer implements HttpClientAdapter {
  final int status;
  final String body;
  _Answer(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Restore screen (HU13)', () {
    Future<RestoreHarness> pumpPage(
      WidgetTester tester, {
      int? cloudCount,
      VoidCallback? onDecline,
    }) async {
      final h = RestoreHarness();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => RestoreHistoryPage(
                      service: h.service,
                      cloudCount: cloudCount,
                      onDecline: onDecline,
                    ),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      return h;
    }

    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('confirming restores and shows the result', (tester) async {
      final h = await pumpPage(tester, cloudCount: 2);
      h.animalCloud.animals.add(cloudAnimal('vaca-1', 'PE-1'));
      h.cloud.evaluations.addAll([remote(1, animalUuid: 'vaca-1'), remote(2)]);
      await open(tester);

      expect(find.text('Tiene 2 evaluaciones en la nube'), findsOneWidget);
      await tester.tap(find.text(RestoreHistoryPage.restoreLabel));
      await tester.pumpAndSettle();

      expect(find.text('Historial restaurado'), findsOneWidget);
      expect(
        find.text('Se descargaron 2 evaluaciones y 1 animal.'),
        findsOneWidget,
      );
      await tester.tap(find.text(RestoreHistoryPage.doneLabel));
      await tester.pumpAndSettle();
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('opened from the profile it asks the cloud first', (
      tester,
    ) async {
      final h = await pumpPage(tester);
      h.cloud.evaluations.addAll([remote(1), remote(2), remote(3)]);
      await open(tester);

      expect(find.text('Tiene 3 evaluaciones en la nube'), findsOneWidget);
    });

    testWidgets('a cut restore can be retried', (tester) async {
      final h = await pumpPage(tester, cloudCount: 1);
      h.cloud.evaluations.add(remote(1));
      h.cloud.dropOn.add('cloud-1');
      await open(tester);

      await tester.tap(find.text(RestoreHistoryPage.restoreLabel));
      await tester.pumpAndSettle();
      expect(find.text('Se perdió la conexión'), findsOneWidget);

      await tester.tap(find.text(RestoreHistoryPage.retryLabel));
      await tester.pumpAndSettle();
      expect(find.text('Historial restaurado'), findsOneWidget);
    });

    testWidgets('"Ahora no" closes it and is remembered', (tester) async {
      var declined = 0;
      await pumpPage(tester, cloudCount: 5, onDecline: () => declined++);
      await open(tester);

      await tester.tap(find.text(RestoreHistoryPage.laterLabel));
      await tester.pumpAndSettle();

      expect(declined, 1);
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('offline it says that internet is needed', (tester) async {
      final h = await pumpPage(tester);
      h.cloud.offline = true;
      await open(tester);

      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.text(RestoreHistoryPage.restoreLabel), findsNothing);
    });
  });

  group('Restore gateway', () {
    test('a history page is read with every field', () async {
      final dio = createApiClient(baseUrl: 'https://api.bovi.test/api/v1')
        ..httpClientAdapter = _Answer(200, '''
{"items": [{"id": "e1", "evaluated_at": "2026-11-11T21:47:00Z",
  "image_origin": "gallery",
  "probabilities": [{"label": "sarna", "probability": 0.9},
                    {"label": "piel_sana", "probability": 0.1}],
  "predicted_class": "sarna", "confidence": 0.9, "outcome": "lesion",
  "clinical_codes": [{"system": "http://id.nlm.nih.gov/mesh",
                      "code": "D008924", "display": "Mite Infestations"}],
  "catalog_version": "2026.1", "model_version": "v7c", "inference_ms": 150,
  "animal_id": "vaca-1", "body_zone": "udder",
  "image_url": "https://s3.test/e1.jpg", "image_url_expires_in": 900}],
 "total": 7, "next_cursor": "abc"}''');

      final page = await HistoryRestoreHttpGateway(dio).fetchEvaluations('tok');

      expect(page.total, 7);
      expect(page.nextCursor, 'abc');
      final e = page.items.single;
      expect(e.evaluatedAt.toUtc(), DateTime.utc(2026, 11, 11, 21, 47));
      expect(e.origin.name, 'gallery');
      expect(e.result.top.label, 'sarna');
      expect(e.result.modelVersion, 'v7c');
      expect(e.clinicalCodes.single.code, 'D008924');
      expect(e.animalUuid, 'vaca-1');
      expect(e.bodyZone!.name, 'udder');
    });

    test('a photo that is gone and an expired URL are told apart', () async {
      final api = createApiClient(baseUrl: 'https://api.bovi.test/api/v1');
      final gone = HistoryRestoreHttpGateway(
        api,
        Dio()..httpClientAdapter = _Answer(404, ''),
      );
      final expired = HistoryRestoreHttpGateway(
        api,
        Dio()..httpClientAdapter = _Answer(403, ''),
      );

      await expectLater(
        gone.downloadPhoto('https://s3.test/x.jpg'),
        throwsA(isA<PhotoMissingException>()),
      );
      await expectLater(
        expired.downloadPhoto('https://s3.test/x.jpg'),
        throwsA(isA<NetworkUnavailableException>()),
      );
    });
  });
}
