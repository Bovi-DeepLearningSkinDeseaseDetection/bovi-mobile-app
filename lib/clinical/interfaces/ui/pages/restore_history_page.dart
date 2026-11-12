import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../../application/internal/commandservices/history_restore_service.dart';
import '../viewmodels/history_restore_view_model.dart';

/// Restore the history on a new phone or after reinstalling (HU13).
/// Pops with true when the history was restored.
class RestoreHistoryPage extends StatelessWidget {
  static const title = 'Restaurar historial';
  static const restoreLabel = 'Restaurar ahora';
  static const laterLabel = 'Ahora no';
  static const doneLabel = 'Ver historial';
  static const retryLabel = 'Reintentar';

  final HistoryRestoreService? service;

  /// Already known when the app offers it after signing in.
  final int? cloudCount;

  /// Called when the farmer answers "Ahora no".
  final VoidCallback? onDecline;

  const RestoreHistoryPage({
    super.key,
    this.service,
    this.cloudCount,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryRestoreViewModel(
        service ?? locator<HistoryRestoreService>(),
        cloudCount: cloudCount,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text(title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Consumer<HistoryRestoreViewModel>(
              builder: (context, model, _) =>
                  _Body(model: model, onDecline: onDecline),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final HistoryRestoreViewModel model;
  final VoidCallback? onDecline;

  const _Body({required this.model, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final (icon, heading, text) = _texts();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Align(child: IconBubble(icon: Icon(icon), size: 72)),
        const SizedBox(height: 24),
        Text(
          heading,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.bodyText),
        ),
        if (model.stage == RestoreStage.running) ...[
          const SizedBox(height: 28),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: model.progress.total == 0 ? null : model.progress.fraction,
              minHeight: 10,
            ),
          ),
        ],
        const Spacer(),
        ..._actions(context),
      ],
    );
  }

  (IconData, String, String) _texts() {
    final count = model.cloudCount;
    switch (model.stage) {
      case RestoreStage.loading:
        return (
          Icons.cloud_sync_outlined,
          'Buscando su historial…',
          'Consultando las evaluaciones respaldadas en la nube.',
        );
      case RestoreStage.ready:
        if (count == null) {
          return (
            Icons.cloud_off_outlined,
            'Sin conexión',
            'Para restaurar su historial necesita internet.',
          );
        }
        if (count == 0) {
          return (
            Icons.cloud_done_outlined,
            'Nada que restaurar',
            'No tiene evaluaciones respaldadas en la nube.',
          );
        }
        return (
          Icons.cloud_download_outlined,
          count == 1
              ? 'Tiene 1 evaluación en la nube'
              : 'Tiene $count evaluaciones en la nube',
          'Se descargarán con sus fotos y sus animales a este celular. Si '
              'puede, use Wi-Fi.',
        );
      case RestoreStage.running:
        final p = model.progress;
        return (
          Icons.cloud_download_outlined,
          'Restaurando ${p.done} de ${p.total}…',
          'Puede tardar unos minutos. No cierre la app.',
        );
      case RestoreStage.finished:
        final report = model.report!;
        return switch (report.outcome) {
          RestoreOutcome.completed => (
            Icons.cloud_done_outlined,
            'Historial restaurado',
            _done(report),
          ),
          RestoreOutcome.offline => (
            Icons.cloud_off_outlined,
            'Se perdió la conexión',
            'Se restauraron ${report.restored}. Vuelva a intentarlo: '
                'continuará donde quedó.',
          ),
          RestoreOutcome.signedOut => (
            Icons.lock_outline_rounded,
            'Su sesión venció',
            'Inicie sesión de nuevo para restaurar su historial.',
          ),
        };
    }
  }

  static String _done(RestoreReport report) {
    final evaluations = report.restored == 1
        ? '1 evaluación'
        : '${report.restored} evaluaciones';
    final animals = report.animals == 1
        ? '1 animal'
        : '${report.animals} animales';
    final missing = report.missingPhotos == 0
        ? ''
        : ' ${report.missingPhotos} no se pudieron descargar porque su foto '
              'ya no está en la nube.';
    return 'Se descargaron $evaluations y $animals.$missing';
  }

  List<Widget> _actions(BuildContext context) {
    final navigator = Navigator.of(context);
    final count = model.cloudCount ?? 0;
    switch (model.stage) {
      case RestoreStage.loading:
      case RestoreStage.running:
        return const [];
      case RestoreStage.ready:
        return [
          if (count > 0)
            FilledButton.icon(
              onPressed: model.restore,
              icon: const Icon(Icons.cloud_download_rounded),
              label: const Text(RestoreHistoryPage.restoreLabel),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              onDecline?.call();
              navigator.pop(false);
            },
            child: Text(count > 0 ? RestoreHistoryPage.laterLabel : 'Volver'),
          ),
        ];
      case RestoreStage.finished:
        final outcome = model.report!.outcome;
        return [
          if (outcome == RestoreOutcome.offline)
            FilledButton(
              onPressed: model.restore,
              child: const Text(RestoreHistoryPage.retryLabel),
            )
          else
            FilledButton(
              onPressed: () =>
                  navigator.pop(outcome == RestoreOutcome.completed),
              child: Text(
                outcome == RestoreOutcome.completed
                    ? RestoreHistoryPage.doneLabel
                    : 'Volver',
              ),
            ),
        ];
    }
  }
}
