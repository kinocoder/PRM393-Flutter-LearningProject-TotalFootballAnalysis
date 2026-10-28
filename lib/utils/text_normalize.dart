String normalizeForSearch(String input) {
  if (input.trim().isEmpty) return '';

  var str = input.toLowerCase().trim();

  const vietnameseMap = {
    'a': '[àáạảãâầấậẩẫăằắặẳẵ]',
    'e': '[èéẹẻẽêềếệểễ]',
    'i': '[ìíịỉĩ]',
    'o': '[òóọỏõôồốộổỗơờớợởỡ]',
    'u': '[ùúụủũưừứựửữ]',
    'y': '[ỳýỵỷỹ]',
    'd': '[đ]',
  };

  for (final entry in vietnameseMap.entries) {
    str = str.replaceAll(RegExp(entry.value), entry.key);
  }

  // 2. Loại bỏ các ký tự dấu tổ hợp Unicode U+0300 đến U+036F
  str = str.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  str = str.replaceAll(RegExp(r'\s+'), ' ');

  return str;
}