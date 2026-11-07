import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/text_normalize.dart';
import '../model/player.dart';
import '../model/player_query.dart';
import '../model/skill.dart';
import '../services/local_database_service.dart';
part 'player_repository.g.dart';

@riverpod
PlayerRepository playerRepository(Ref ref) {
  return PlayerRepository(ref.watch(localDatabaseServiceProvider));
}

class PlayerRepository {
  PlayerRepository(this._databaseService);

  final LocalDatabaseService _databaseService;

  static final List<Player> _seedPlayers = [
    const Player(
      id: "9275",
      name: "O. Dembélé",
      fullName: "Ousmane Dembélé",
      image: "https://media.api-sports.io/football/players/154.png",
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
        "Pace": {"Acceleration": 130, "Sprint Speed": 126},
      },
      skills: [
        Skill(
          id: "sk_01",
          name: "Speed Dribbler",
          type: "Special",
          description: "Rê bóng tốc độ cao",
        ),
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
        "Passing": {"Vision": 103, "Short Passing": 100},
      },
      skills: [
        Skill(
          id: "sk_04",
          name: "Playmaker",
          type: "Midfield",
          description: "Chọc khe tinh tế",
        ),
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
        "Shooting": {"Finishing": 101, "Shot Power": 98},
      },
      skills: [
        Skill(
          id: "sk_05",
          name: "Power Header",
          type: "Attack",
          description: "Đánh đầu uy lực",
        ),
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
        "Defending": {"Standing Tackle": 99, "Heading Accuracy": 97},
      },
      skills: [
        Skill(
          id: "sk_09",
          name: "Power Header",
          type: "Defensive",
          description: "Cản phá không chiến",
        ),
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
      image: "https://media.api-sports.io/football/players/278.png",
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
        "Pace": {"Acceleration": 134, "Sprint Speed": 130},
      },
      skills: [
        Skill(
          id: "sk_10",
          name: "Rapid Burst",
          type: "Special",
          description: "Bứt tốc thần tốc",
        ),
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
      image: "https://media.api-sports.io/football/players/1100.png",
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
        "Shooting": {"Finishing": 130, "Shot Power": 128},
      },
      skills: [
        Skill(
          id: "sk_11",
          name: "Bulldozer",
          type: "Special",
          description: "Càn quét tì đè",
        ),
      ],
      nation: "Na Uy",
      club: "Manchester City",
      age: 24,
      heightCm: 195,
      weightKg: 88,
      skillMoves: 4,
    ),
  ];

  static List<Player> get seedPlayers => List.unmodifiable(_seedPlayers);

  Future<List<Player>> getPlayers() async {
    final db = await _databaseService.database;
    await _seedIfNeeded(db);
    final rows = await db.query('players', orderBy: 'ovr DESC, name ASC');
    return rows.map(_toPlayer).toList(growable: false);
  }

  Future<Player?> getPlayerByID(String id) async {
    final db = await _databaseService.database;
    await _seedIfNeeded(db);
    final rows = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _toPlayer(rows.first);
  }

  Future<List<Player>> searchPlayers(String query) async {
    final keyword = normalizeForSearch(query);
    if (keyword.isEmpty) return [];
    final players = await getPlayers();
    return players
        .where((player) {
          final name = normalizeForSearch(player.name);
          final fullName = normalizeForSearch(player.fullName);
          return name.contains(keyword) || fullName.contains(keyword);
        })
        .toList(growable: false);
  }

  Future<Map<String, List<String>>> getFilterOptions() async {
    final players = await getPlayers();
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

  Future<List<Player>> filterPlayers(PlayerQuery query) async {
    var result = List<Player>.from(await getPlayers());

    // Lọc theo danh sách vị trí
    if (query.positions.isNotEmpty) {
      result = result
          .where((p) => query.positions.contains(p.position))
          .toList();
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

  Future<void> _seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM players'),
    );
    if (count != 0) return;

    final batch = db.batch();
    for (final player in _seedPlayers) {
      batch.insert('players', _toRow(player));
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _toRow(Player player) => {
    'id': player.id,
    'name': player.name,
    'full_name': player.fullName,
    'image': player.image,
    'position': player.position,
    'card_version': player.cardVersion,
    'ovr': player.ovr,
    'level': player.level,
    'nation': player.nation,
    'club': player.club,
    'age': player.age,
    'height_cm': player.heightCm,
    'weight_kg': player.weightKg,
    'skill_moves': player.skillMoves,
    'position_ratings_json': jsonEncode(player.positionRatings),
    'stats_json': jsonEncode(player.stats),
    'stat_details_json': jsonEncode(player.statDetails),
    'skills_json': player.skills == null
        ? null
        : jsonEncode(player.skills!.map((skill) => skill.toJson()).toList()),
  };

  Player _toPlayer(Map<String, Object?> row) {
    return Player.fromJson({
      'id': row['id'],
      'name': row['name'],
      'fullName': row['full_name'],
      'image': row['image'],
      'position': row['position'],
      'cardVersion': row['card_version'],
      'ovr': row['ovr'],
      'level': row['level'],
      'nation': row['nation'],
      'club': row['club'],
      'age': row['age'],
      'heightCm': row['height_cm'],
      'weightKg': row['weight_kg'],
      'skillMoves': row['skill_moves'],
      'positionRatings': jsonDecode(row['position_ratings_json'] as String),
      'stats': jsonDecode(row['stats_json'] as String),
      'statDetails': jsonDecode(row['stat_details_json'] as String),
      'skills': row['skills_json'] == null
          ? null
          : jsonDecode(row['skills_json'] as String),
    });
  }
}
