/// Whether a local record was already backed up in the cloud (HU12).
enum SyncStatus {
  pending('Pendiente de sincronizar'),
  synced('Sincronizado'),
  failed('Error al sincronizar');

  const SyncStatus(this.label);

  final String label;
}
