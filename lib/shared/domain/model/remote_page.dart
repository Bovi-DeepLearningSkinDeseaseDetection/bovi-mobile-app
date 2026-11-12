/// One page of a list of the backend (HU13): keyset pagination, so pages
/// never shift while records are added.
class RemotePage<T> {
  final List<T> items;

  /// Records of the farmer in the cloud.
  final int total;

  /// Send it back for the next page; null on the last one.
  final String? nextCursor;

  const RemotePage(this.items, this.total, this.nextCursor);
}
