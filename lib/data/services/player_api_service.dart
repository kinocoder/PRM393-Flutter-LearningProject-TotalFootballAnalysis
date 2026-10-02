import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/models/player.dart';
import '../../utils/app_exception.dart';

/// Gọi backend catalog (`GET /players/{id}`). Hợp đồng API do mảng B chốt.
class PlayerApiService {
  PlayerApiService({required this.baseUrl, http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  Future<Player> fetchPlayer(String id) async {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$base/players/${Uri.encodeComponent(id)}');
    final http.Response res;
    try {
      res = await _client.get(uri, headers: const {'Accept': 'application/json'}).timeout(timeout);
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    } on SocketException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    }
    if (res.statusCode == 404) throw NotFoundException('Không tìm thấy cầu thủ $id.');
    if (res.statusCode >= 500) throw const ServerException();
    if (res.statusCode != 200) throw AppException('Yêu cầu không hợp lệ (${res.statusCode}).');
    try {
      final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return Player.fromJson(json);
    } catch (e) {
      throw ServerException('Dữ liệu cầu thủ không hợp lệ.', e);
    }
  }

  void close() => _client.close();
}
