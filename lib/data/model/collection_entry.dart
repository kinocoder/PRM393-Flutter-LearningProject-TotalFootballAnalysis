class CollectionEntry {
  const CollectionEntry({
    required this.playerId,
    required this.addedAt,
    this.note = '',
  });

  final String playerId;
  final DateTime addedAt;
  final String note;
}
