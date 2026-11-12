import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/clinical_code.dart';
import 'package:bov_mobile_app/clinical/domain/services/evaluation_sync_gateway.dart';
import 'package:bov_mobile_app/clinical/infrastructure/http/evaluation_sync_http_gateway.dart';
import 'package:bov_mobile_app/clinical/domain/model/aggregates/evaluation.dart';
import 'package:bov_mobile_app/shared/domain/exceptions/network_unavailable_exception.dart';
import 'package:bov_mobile_app/shared/domain/model/remote_sync_result.dart';
import 'package:bov_mobile_app/shared/infrastructure/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import 'sync_fakes.dart';

/// Records the request and answers with [status] and [body].
class _Recorder implements HttpClientAdapter {
  final int status;
  final Object? body;
  final bool unreachable;
  RequestOptions? last;
  Uint8List? bytes;

  _Recorder(this.status, [this.body, this.unreachable = false]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      bytes = Uint8List.fromList([for (final c in chunks) ...c]);
    }
    if (unreachable) {
      throw DioException.connectionError(requestOptions: options, reason: 'x');
    }
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

EvaluationSyncHttpGateway _gateway(_Recorder api, [_Recorder? s3]) {
  final dio = createApiClient(baseUrl: 'https://api.bovi.test/api/v1')
    ..httpClientAdapter = api;
  final storage = Dio()..httpClientAdapter = s3 ?? _Recorder(204);
  return EvaluationSyncHttpGateway(dio, storage);
}

void main() {
  late File photo;

  setUpAll(() async {
    photo = File('${Directory.systemTemp.path}/bovi_test_photo.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(64, 7)]);
  });

  test('upload URLs are read with their status and fields', () async {
    final api = _Recorder(200, {
      'items': [
        {
          'evaluation_id': 'e1',
          'status': 'ready',
          'image_key': 'evaluaciones/u/e1.jpg',
          'upload': {
            'url': 'https://s3.test/bucket',
            'fields': {'key': 'evaluaciones/u/e1.jpg', 'policy': 'p'},
            'expires_in': 900,
            'max_bytes': 512000,
          },
        },
        {'evaluation_id': 'e2', 'status': 'already_synced'},
        {'evaluation_id': 'e3', 'status': 'rejected'},
      ],
    });

    final tickets = await _gateway(
      api,
    ).requestUploads('tok', ['e1', 'e2', 'e3']);

    expect(api.last!.path, '/media/upload-url');
    expect(api.last!.headers['Authorization'], 'Bearer tok');
    expect(api.last!.data, {
      'evaluation_ids': ['e1', 'e2', 'e3'],
    });
    expect(tickets.map((t) => t.status), [
      UploadTicketStatus.ready,
      UploadTicketStatus.alreadySynced,
      UploadTicketStatus.rejected,
    ]);
    expect(tickets.first.fields['key'], 'evaluaciones/u/e1.jpg');
  });

  // S3 needs every field of the policy before the file.
  test('the photo is the last part of the form sent to S3', () async {
    final s3 = _Recorder(204);
    const ticket = UploadTicket(
      evaluationId: 'e1',
      status: UploadTicketStatus.ready,
      url: 'https://s3.test/bucket',
      fields: {
        'key': 'evaluaciones/u/e1.jpg',
        'Content-Type': 'image/jpeg',
        'policy': 'p',
        'x-amz-signature': 's',
      },
    );

    await _gateway(_Recorder(200), s3).uploadPhoto(ticket, photo.path);

    expect(s3.last!.uri.toString(), 'https://s3.test/bucket');
    final body = latin1.decode(s3.bytes!);
    final names = RegExp(
      r'form-data; name="([^"]+)"',
    ).allMatches(body).map((m) => m.group(1)).toList();
    expect(names, ['key', 'Content-Type', 'policy', 'x-amz-signature', 'file']);
    // The part of the file declares the JPEG the policy requires.
    expect(body.toLowerCase(), contains('content-type: image/jpeg'));
    expect(s3.last!.headers['Authorization'], isNull);
  });

  test('S3 refusing the file is a rejected photo', () async {
    const ticket = UploadTicket(
      evaluationId: 'e1',
      status: UploadTicketStatus.ready,
      url: 'https://s3.test/bucket',
    );

    await expectLater(
      _gateway(_Recorder(200), _Recorder(400)).uploadPhoto(ticket, photo.path),
      throwsA(isA<PhotoRejectedException>()),
    );
    // An expired URL is solved by asking a new one: retried later.
    await expectLater(
      _gateway(_Recorder(200), _Recorder(403)).uploadPhoto(ticket, photo.path),
      throwsA(isA<NetworkUnavailableException>()),
    );
    await expectLater(
      _gateway(
        _Recorder(200),
        _Recorder(0, null, true),
      ).uploadPhoto(ticket, photo.path),
      throwsA(isA<NetworkUnavailableException>()),
    );
  });

  test('the evaluation is sent as the backend expects it', () async {
    final api = _Recorder(200, {
      'results': [
        {'id': 'e1', 'status': 'accepted', 'canonical_id': 'e1'},
      ],
      'accepted': 1,
      'duplicates': 0,
      'merged': 0,
      'rejected': 0,
    });
    final base = evaluation('e1', animalId: 7);
    final withCodes = Evaluation(
      uuid: base.uuid,
      createdAt: DateTime.utc(2026, 11, 11, 21, 47),
      imagePath: base.imagePath,
      thumbnailPath: base.thumbnailPath,
      origin: base.origin,
      result: base.result,
      clinicalCodes: const [
        ClinicalCode(
          system: ClinicalCode.meshSystem,
          code: 'D008924',
          display: 'Mite Infestations',
        ),
      ],
      catalogVersion: '2026.1',
      animalId: 7,
      bodyZone: base.bodyZone,
    );

    final results = await _gateway(
      api,
    ).sync('tok', [EvaluationUpload(withCodes, 'animal-cloud-7')]);

    expect(api.last!.path, '/sync/evaluations');
    final sent = (api.last!.data as Map)['evaluations'].single as Map;
    expect(sent, {
      'id': 'e1',
      'evaluated_at': '2026-11-11T21:47:00.000Z',
      'image_origin': 'camera',
      'probabilities': [
        {'label': 'dermatofitosis', 'probability': 0.006108},
        {'label': 'miasis', 'probability': 0.000231},
        {'label': 'papilomatosis', 'probability': 0.015779},
        {'label': 'piel_sana', 'probability': 0.002489},
        {'label': 'sarna', 'probability': 0.975393},
      ],
      'predicted_class': 'sarna',
      'confidence': 0.975393,
      'outcome': 'lesion',
      'clinical_codes': [
        {
          'system': 'http://id.nlm.nih.gov/mesh',
          'code': 'D008924',
          'display': 'Mite Infestations',
        },
      ],
      'catalog_version': '2026.1',
      'model_version': 'v7c',
      'inference_ms': 180,
      'animal_id': 'animal-cloud-7',
      'body_zone': 'flank',
    });
    expect(results.single.status, RemoteSyncStatus.accepted);
  });

  test('a refused batch keeps the message of the backend', () async {
    final api = _Recorder(422, {
      'code': 'lote_muy_grande',
      'message':
          'Envíe como máximo 20 registros de evaluaciones por solicitud.',
      'details': [],
    });

    await expectLater(
      _gateway(api).sync('tok', [EvaluationUpload(evaluation('e1'), null)]),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'lote_muy_grande'),
      ),
    );
  });
}
