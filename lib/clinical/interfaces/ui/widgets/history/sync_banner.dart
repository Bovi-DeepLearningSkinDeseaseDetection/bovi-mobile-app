import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../application/internal/commandservices/cloud_sync_service.dart';
import '../../viewmodels/cloud_sync_view_model.dart';

/// State of the cloud backup above the history (HU12): what is still on
/// the phone only, and a way to send it now.
class SyncBanner extends StatelessWidget {
  static const syncNowLabel = 'Sincronizar ahora';
  static const syncingText = 'Respaldando en la nube…';
  static const offlineText =
      'Se enviarán solas cuando el celular tenga internet.';
  static const settleText =
      'Las evaluaciones nuevas se envían 2 minutos después del análisis.';

  const SyncBanner({super.key});

  /// The banner only exists with a sync running (signed in); the history
  /// alone (tests, previews) shows without it.
  static CloudSyncViewModel? _of(BuildContext context) {
    try {
      return Provider.of<CloudSyncViewModel>(context);
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = _of(context);
    if (sync == null) return const SizedBox.shrink();
    final pending = sync.pendingCount;
    final failed = sync.lastReport?.failed ?? 0;
    if (pending == 0 && !sync.isSyncing && failed == 0) {
      return const SizedBox.shrink();
    }
    final textTheme = TextTheme.of(context);
    final title = sync.isSyncing
        ? SyncBanner.syncingText
        : pending == 1
        ? '1 evaluación pendiente de respaldo'
        : '$pending evaluaciones pendientes de respaldo';
    final detail = !sync.isOnline
        ? offlineText
        : sync.lastReport?.outcome == SyncOutcome.offline
        ? 'Se perdió la conexión: se reintentará solo.'
        : settleText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mint),
        ),
        child: Row(
          children: [
            sync.isSyncing
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Icon(
                    sync.isOnline
                        ? Icons.cloud_upload_outlined
                        : Icons.cloud_off_outlined,
                    color: sync.isOnline
                        ? AppColors.primaryGreen
                        : AppColors.offline,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall),
                  if (!sync.isSyncing) Text(detail, style: textTheme.bodySmall),
                  if (failed > 0)
                    Text(
                      failed == 1
                          ? '1 evaluación no se pudo respaldar.'
                          : '$failed evaluaciones no se pudieron respaldar.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.lesionText,
                      ),
                    ),
                ],
              ),
            ),
            if (sync.isOnline && !sync.isSyncing && pending > 0)
              TextButton(
                onPressed: sync.syncNow,
                child: const Text(syncNowLabel),
              ),
          ],
        ),
      ),
    );
  }
}
