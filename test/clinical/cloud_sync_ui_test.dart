import 'dart:async';

import 'package:bov_mobile_app/clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'package:bov_mobile_app/clinical/domain/model/aggregates/evaluation.dart';
import 'package:bov_mobile_app/clinical/domain/model/queries/evaluation_filter.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/body_zone.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_repository.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/history_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/viewmodels/cloud_sync_view_model.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/history/sync_banner.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/result/evaluation_animal_section.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:provider/provider.dart';

import 'sync_fakes.dart';

class _Harness {
  final connectivity = StreamController<bool>.broadcast();
  final pending = StreamController<int>.broadcast();
  var calls = 0;
  var signedOut = 0;
  SyncReport answer = const SyncReport(SyncOutcome.completed);
  late final model = CloudSyncViewModel(
    sync: () async {
      calls++;
      return answer;
    },
    connectivity: connectivity.stream,
    pendingCount: pending.stream,
    onSignedOut: () => signedOut++,
  )..start();

  /// Leaves no timer running when the test ends.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    model.dispose();
  }

  Future<void> emit(WidgetTester tester, {bool? online, int? count}) async {
    model; // listening before the first event
    if (online != null) connectivity.add(online);
    if (count != null) pending.add(count);
    await tester.pump();
  }
}

class _Repo implements EvaluationRepository {
  final List<Evaluation> items;
  _Repo(this.items);
  @override
  Future<Evaluation> save(Evaluation e) async => e;
  @override
  Stream<List<Evaluation>> watch([
    EvaluationFilter f = EvaluationFilter.none,
  ]) => Stream.value(items);
  @override
  Future<Evaluation> assignAnimal(
    int id, {
    required int animalId,
    required String animalEarTag,
    required BodyZone bodyZone,
  }) => throw UnimplementedError();
}

void main() {
  group(
    'CloudSyncViewModel (scenario 1: without the farmer doing anything)',
    () {
      testWidgets('getting the connection back starts a sync', (tester) async {
        final h = _Harness();
        h.model;

        await h.emit(tester, online: false);
        expect(h.calls, 0);

        await h.emit(tester, online: true);
        expect(h.calls, 1);

        h.model.dispose();
      });

      testWidgets('a new evaluation is sent once its settle time passes', (
        tester,
      ) async {
        final h = _Harness();
        await h.emit(tester, online: true);
        h.calls = 0;

        await h.emit(tester, count: 1);
        await tester.pump(const Duration(minutes: 1));
        expect(h.calls, 0);

        await tester.pump(const Duration(minutes: 2));
        expect(h.calls, 1);

        h.model.dispose();
      });

      testWidgets('without internet nothing is attempted', (tester) async {
        final h = _Harness();
        await h.emit(tester, online: false, count: 3);

        await h.model.syncNow();
        await tester.pump(const Duration(minutes: 20));

        expect(h.calls, 0);
        h.model.dispose();
      });

      testWidgets('a revoked session sends the farmer to sign in', (
        tester,
      ) async {
        final h = _Harness()..answer = const SyncReport(SyncOutcome.signedOut);

        await h.emit(tester, online: true);

        expect(h.signedOut, 1);
        h.model.dispose();
      });
    },
  );

  group('What the farmer sees', () {
    Future<_Harness> pumpBanner(
      WidgetTester tester, {
      required bool online,
      required int pending,
    }) async {
      final h = _Harness();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: h.model,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: SyncBanner()),
          ),
        ),
      );
      await h.emit(tester, online: online, count: pending);
      h.calls = 0;
      return h;
    }

    testWidgets('pending evaluations and a button to send them', (
      tester,
    ) async {
      final h = await pumpBanner(tester, online: true, pending: 3);

      expect(
        find.text('3 evaluaciones pendientes de respaldo'),
        findsOneWidget,
      );
      await tester.tap(find.text(SyncBanner.syncNowLabel));
      await tester.pump();

      expect(h.calls, 1);
      await h.finish(tester);
    });

    testWidgets('offline it explains they will go up on their own', (
      tester,
    ) async {
      final h = await pumpBanner(tester, online: false, pending: 1);

      expect(find.text('1 evaluación pendiente de respaldo'), findsOneWidget);
      expect(find.text(SyncBanner.offlineText), findsOneWidget);
      expect(find.text(SyncBanner.syncNowLabel), findsNothing);
      await h.finish(tester);
    });

    testWidgets('with everything backed up it shows nothing', (tester) async {
      final h = await pumpBanner(tester, online: true, pending: 0);

      expect(find.textContaining('pendiente'), findsNothing);
      await h.finish(tester);
    });

    testWidgets('the history tells synced, pending and failed apart', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HistoryPage(
            onScan: () {},
            repository: _Repo([
              evaluation('a', status: SyncStatus.synced),
              evaluation('b'),
              evaluation('c', status: SyncStatus.failed),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sincronizado'), findsOneWidget);
      expect(find.text('Pendiente'), findsWidgets);
      expect(find.text('Error al sincronizar'), findsOneWidget);
    });

    testWidgets('a synced evaluation can no longer change its animal', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EvaluationAnimalSection(
              evaluation: evaluation('a', status: SyncStatus.synced),
            ),
          ),
        ),
      );

      expect(find.text(EvaluationAnimalSection.lockedText), findsOneWidget);
      expect(find.text(EvaluationAnimalSection.assignLabel), findsNothing);
    });
  });
}
