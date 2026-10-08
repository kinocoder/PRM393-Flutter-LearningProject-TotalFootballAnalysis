/// Chuẩn hoá chuỗi để tìm kiếm không phân biệt dấu/hoa thường (B02, E01, C03).
///
/// Quy tắc này phải giống hệt `backend/src/normalize.js` để kết quả tìm
/// online (API) và offline (cache SQLite) nhất quán.
library;

const Map<String, String> _groups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵäåāą',
  'e': 'èéẹẻẽêềếệểễëēę',
  'i': 'ìíịỉĩïîī',
  'o': 'òóọỏõôồốộổỗơờớợởỡöøō',
  'u': 'ùúụủũưừứựửữüûū',
  'y': 'ỳýỵỷỹÿ',
  'd': 'đ',
  'c': 'çć',
  'n': 'ñń',
  's': 'šś',
  'z': 'žź',
};

final Map<int, String> _lookup = () {
  final map = <int, String>{};
  _groups.forEach((base, chars) {
    for (final rune in chars.runes) {
      map[rune] = base;
    }
  });
  return map;
}();

/// Bỏ dấu, về chữ thường, gộp khoảng trắng.
String normalizeForSearch(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    // Dấu tổ hợp (Unicode dạng NFD) U+0300–U+036F: bỏ qua.
    if (rune >= 0x0300 && rune <= 0x036F) continue;
    final mapped = _lookup[rune];
    if (mapped != null) {
      buffer.write(mapped);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// `true` nếu [text] chứa [query] sau khi chuẩn hoá. Query rỗng luôn khớp.
bool matchesSearch(String text, String query) {
  final q = normalizeForSearch(query);
  if (q.isEmpty) return true;
  return normalizeForSearch(text).contains(q);
}
