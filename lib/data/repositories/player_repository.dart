import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../utils/text_normalize.dart';
import '../model/player.dart';
import '../model/player_query.dart';
import '../model/skill.dart';
part 'player_repository.g.dart';

@riverpod
PlayerRepository playerRepository(Ref ref) {
  return PlayerRepository();
}

class PlayerRepository {
  final List<Player> players = [
    const Player(
      id: "9275",
      name: "O. Dembélé",
      fullName: "Ousmane Dembélé",
      position: "RW",
      cardVersion: "TOTS",
      ovr: 123,
      level: 10,
      positionRatings: {"RW": 123, "ST": 118, "RM": 115},
      stats: {
        "PAC": 128,
        "SHO": 112,
        "PAS": 116,
        "DRI": 124,
        "DEF": 55,
        "PHY": 89,
        "ATK": 120,
      },
      statDetails: {
        "Pace": {"Acceleration": 130, "Sprint Speed": 126}
      },
      skills: [
        Skill(
          id: "sk_01",
          name: "Speed Dribbler",
          type: "Special",
          description: "Rê bóng tốc độ cao",
        )
      ],
      nation: "Pháp",
      club: "FC Barcelona",
      age: 27,
      heightCm: 178,
      weightKg: 73,
      skillMoves: 5,
    ),
    const Player(
      id: "9278",
      name: "I. BENKHEDDA",
      fullName: "Ilias Benkhedda",
      position: "CM",
      cardVersion: "Huyền thoại",
      ovr: 97,
      level: 10,
      positionRatings: {"CM": 97, "CAM": 95, "CDM": 92},
      stats: {
        "PAC": 92,
        "SHO": 88,
        "PAS": 101,
        "DRI": 96,
        "DEF": 84,
        "PHY": 90,
      },
      statDetails: {
        "Passing": {"Vision": 103, "Short Passing": 100}
      },
      skills: [
        Skill(
          id: "sk_04",
          name: "Playmaker",
          type: "Midfield",
          description: "Chọc khe tinh tế",
        )
      ],
      nation: "Algérie",
      club: "Atlético Solano",
      age: 26,
      heightCm: 182,
      weightKg: 78,
      skillMoves: 4,
    ),
    const Player(
      id: "9279",
      name: "K. ADOMAH",
      fullName: "Kofi Adomah",
      position: "ST",
      cardVersion: "Huyền thoại",
      ovr: 97,
      level: 10,
      positionRatings: {"ST": 97, "CF": 94},
      stats: {
        "PAC": 102,
        "SHO": 99,
        "PAS": 82,
        "DRI": 94,
        "DEF": 40,
        "PHY": 95,
      },
      statDetails: {
        "Shooting": {"Finishing": 101, "Shot Power": 98}
      },
      skills: [
        Skill(
          id: "sk_05",
          name: "Power Header",
          type: "Attack",
          description: "Đánh đầu uy lực",
        )
      ],
      nation: "Ghana",
      club: "Riverside United",
      age: 24,
      heightCm: 185,
      weightKg: 80,
      skillMoves: 4,
    ),
    const Player(
      id: "9283",
      name: "M. SALCEDO",
      fullName: "Mateo Salcedo",
      position: "CB",
      cardVersion: "Huyền thoại",
      ovr: 95,
      level: 10,
      positionRatings: {"CB": 95, "CDM": 90},
      stats: {
        "PAC": 84,
        "SHO": 45,
        "PAS": 78,
        "DRI": 80,
        "DEF": 98,
        "PHY": 100,
      },
      statDetails: {
        "Defending": {"Standing Tackle": 99, "Heading Accuracy": 97}
      },
      skills: [
        Skill(
          id: "sk_09",
          name: "Power Header",
          type: "Defensive",
          description: "Cản phá không chiến",
        )
      ],
      nation: "Argentina",
      club: "Atlético Solano",
      age: 29,
      heightCm: 189,
      weightKg: 85,
      skillMoves: 2,
    ),
    const Player(
      id: "9284",
      name: "K. MBAPPÉ",
      fullName: "Kylian Mbappé",
      position: "ST",
      cardVersion: "TOTY",
      ovr: 125,
      level: 10,
      positionRatings: {"ST": 125, "LW": 122, "CF": 120},
      stats: {
        "PAC": 132,
        "SHO": 124,
        "PAS": 108,
        "DRI": 126,
        "DEF": 48,
        "PHY": 102,
      },
      statDetails: {
        "Pace": {"Acceleration": 134, "Sprint Speed": 130}
      },
      skills: [
        Skill(
          id: "sk_10",
          name: "Rapid Burst",
          type: "Special",
          description: "Bứt tốc thần tốc",
        )
      ],
      nation: "Pháp",
      club: "Real Madrid",
      age: 25,
      heightCm: 178,
      weightKg: 75,
      skillMoves: 5,
    ),
    const Player(
      id: "9285",
      name: "E. HAALAND",
      fullName: "Erling Haaland",
      position: "ST",
      cardVersion: "TOTS",
      ovr: 124,
      level: 10,
      positionRatings: {"ST": 124, "CF": 118},
      stats: {
        "PAC": 122,
        "SHO": 128,
        "PAS": 92,
        "DRI": 112,
        "DEF": 52,
        "PHY": 125,
      },
      statDetails: {
        "Shooting": {"Finishing": 130, "Shot Power": 128}
      },
      skills: [
        Skill(
          id: "sk_11",
          name: "Bulldozer",
          type: "Special",
          description: "Càn quét tì đè",
        )
      ],
      nation: "Na Uy",
      club: "Manchester City",
      age: 24,
      heightCm: 195,
      weightKg: 88,
      skillMoves: 4,
    ),
  ];

  Future<List<Player>> getPlayers() async {
    return List<Player>.unmodifiable(players);
  }

  Future<Player?> getPlayerByID(String id) async {
    for (final player in players) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }

  Future<List<Player>> searchPlayers(String query) async {
    final keyword = normalizeForSearch(query);
    if (keyword.isEmpty) return [];

    return players.where((player) {
      final name = normalizeForSearch(player.name);
      final fullName = normalizeForSearch(player.fullName);
      return name.contains(keyword) || fullName.contains(keyword);
    }).toList();
  }

  /// Lấy danh sách các giá trị thuộc tính thực tế có trong dữ liệu (BR-11)
  Map<String, List<String>> getFilterOptions() {
    final positions = <String>{};
    final nations = <String>{};
    final clubs = <String>{};
    final versions = <String>{};

    for (final p in players) {
      if (p.position.isNotEmpty) positions.add(p.position);
      if (p.nation.isNotEmpty) nations.add(p.nation);
      if (p.club.isNotEmpty) clubs.add(p.club);
      if (p.cardVersion.isNotEmpty) versions.add(p.cardVersion);
    }

    return {
      'positions': positions.toList()..sort(),
      'nations': nations.toList()..sort(),
      'clubs': clubs.toList()..sort(),
      'cardVersions': versions.toList()..sort(),
    };
  }

  /// Lọc và đếm số lượng cầu thủ khớp với PlayerQuery
  List<Player> filterPlayers(PlayerQuery query) {
    var result = List<Player>.from(players);

    // Lọc theo danh sách vị trí
    if (query.positions.isNotEmpty) {
      result = result.where((p) => query.positions.contains(p.position)).toList();
    }
    // Lọc quốc gia
    if (query.nation != null && query.nation!.isNotEmpty) {
      result = result.where((p) => p.nation == query.nation).toList();
    }
    // Lọc CLB
    if (query.club != null && query.club!.isNotEmpty) {
      result = result.where((p) => p.club == query.club).toList();
    }
    // Lọc mùa thẻ
    if (query.cardVersion != null && query.cardVersion!.isNotEmpty) {
      result = result.where((p) => p.cardVersion == query.cardVersion).toList();
    }
    // Lọc OVR tối thiểu
    if (query.minOvr != null) {
      result = result.where((p) => p.ovr >= query.minOvr!).toList();
    }

    // Sắp xếp kết quả
    if (query.sort == 'ovr_asc') {
      result.sort((a, b) => a.ovr.compareTo(b.ovr));
    } else if (query.sort == 'name_asc') {
      result.sort((a, b) => a.name.compareTo(b.name));
    } else {
      // Mặc định: ovr_desc
      result.sort((a, b) => b.ovr.compareTo(a.ovr));
    }

    return result;
  }
}
