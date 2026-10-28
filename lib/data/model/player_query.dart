class PlayerQuery {
  final List<String> positions;
  final String? nation;
  final String? club;
  final String? cardVersion;
  final int? minOvr;
  final String sort;

  const PlayerQuery({
    this.positions = const [],
    this.nation,
    this.club,
    this.cardVersion,
    this.minOvr,
    this.sort = 'ovr_desc',
  });

  bool get isEmpty =>
      positions.isEmpty &&
          nation == null &&
          club == null &&
          cardVersion == null &&
          minOvr == null &&
          sort == 'ovr_desc';

  PlayerQuery copyWith({
    List<String>? positions,
    String? nation,
    String? club,
    String? cardVersion,
    int? minOvr,
    String? sort,
    bool clearNation = false,
    bool clearClub = false,
    bool clearCardVersion = false,
    bool clearMinOvr = false,
  }) {
    return PlayerQuery(
      positions: positions ?? this.positions,
      nation: clearNation ? null : (nation ?? this.nation),
      club: clearClub ? null : (club ?? this.club),
      cardVersion: clearCardVersion ? null : (cardVersion ?? this.cardVersion),
      minOvr: clearMinOvr ? null : (minOvr ?? this.minOvr),
      sort: sort ?? this.sort,
    );
  }
}