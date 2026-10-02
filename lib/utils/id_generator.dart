import 'dart:math';

final Random _random = Random.secure();

/// Sinh ID ngẫu nhiên 128-bit dạng hex (đủ dùng cho khoá đội hình/lịch sử).
String newId() {
  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
