import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../domain/models/player.dart';

/// Đọc dữ liệu mẫu đóng gói trong app (`assets/data/players_sample.json`).
///
/// Chỉ là phương án cuối khi chưa có backend và chưa có cache, để phần C
/// chạy thử được độc lập. Thẻ mẫu có `isSample = true`.
class SamplePlayerService {
  SamplePlayerService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Map<String, Player>? _players;

  Future<Map<String, Player>> all() async {
    final cached = _players;
    if (cached != null) return cached;
    final raw = jsonDecode(await _bundle.loadString('assets/data/players_sample.json')) as Map<String, dynamic>;
    final version = raw['dataVersion'] as String? ?? 'sample';
    final players = {
      for (final e in raw['players'] as List)
        (e as Map)['id'] as String:
            Player.fromJson({...e.cast<String, dynamic>(), 'dataVersion': version}),
    };
    return _players = players;
  }
}
