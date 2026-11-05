import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../model/avatar_failure.dart';

class AvatarUploadResult {
  final String url;
  final String publicId;

  const AvatarUploadResult({required this.url, required this.publicId});
}

class AvatarCloudinaryService {
  AvatarCloudinaryService({
    this.client,
    this.uploadTimeout = const Duration(seconds: 30),
    this.maxFileBytes = 5 * 1024 * 1024,
  }) : assert(uploadTimeout > Duration.zero),
       assert(maxFileBytes > 0);

  // An injected client is owned and closed by the caller.
  final http.Client? client;
  final Duration uploadTimeout;
  final int maxFileBytes;
  static const String _cloudName = 'ydzyh7bn';
  static const String _uploadPreset = 'totalfootball_avatars';

  Future<AvatarUploadResult> uploadAvatar(XFile image) async {
    final abort = Completer<void>();
    // Mỗi lượt tải lên trong môi trường production tự quản lý kết nối của mình;
    // các client được truyền vào vẫn được giữ mở.
    final activeClient = client ?? http.Client();
    try {
      return await _upload(image, activeClient, abort).timeout(
        uploadTimeout,
        onTimeout: () {
          abort.complete();
          throw const AvatarUploadException(
            'Tải ảnh quá thời gian chờ. Hãy kiểm tra kết nối và thử lại.',
          );
        },
      );
    } on http.ClientException catch (error) {
      throw AvatarUploadException(
        'Không thể tải ảnh lên. Hãy kiểm tra kết nối và thử lại.',
        cause: error,
      );
    } finally {
      if (client == null) activeClient.close();
    }
  }

  void _validateSize(int length) {
    if (length == 0) {
      throw const AvatarUploadException('Ảnh đã chọn không có dữ liệu.');
    }
    if (length > maxFileBytes) {
      final limit = (maxFileBytes / (1024 * 1024)).toStringAsFixed(1);
      throw AvatarUploadException(
        'Ảnh vượt quá dung lượng cho phép ($limit MiB).',
      );
    }
  }

  Future<AvatarUploadResult> _upload(
    XFile image,
    http.Client activeClient,
    Completer<void> abort,
  ) async {
    _validateSize(await image.length());
    if (abort.isCompleted) {
      throw const AvatarUploadException('Đã dừng tải ảnh.');
    }
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final file = await http.MultipartFile.fromPath('file', image.path);
    _validateSize(file.length);
    // File preparation can finish after the overall deadline. Never send then.
    if (abort.isCompleted) {
      throw const AvatarUploadException('Đã dừng tải ảnh.');
    }
    final request =
        http.AbortableMultipartRequest('POST', uri, abortTrigger: abort.future)
          ..fields['upload_preset'] = _uploadPreset
          ..files.add(file);

    final response = await activeClient.send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw AvatarUploadException(
        'Dịch vụ ảnh từ chối tải lên (HTTP ${response.statusCode}). '
        'Vui lòng thử lại sau.',
      );
    }

    final dynamic data;
    try {
      data = jsonDecode(responseBody);
    } on FormatException {
      throw const FormatException('Dịch vụ ảnh trả về dữ liệu không hợp lệ.');
    }
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Dịch vụ ảnh trả về dữ liệu không hợp lệ.');
    }

    final url = data['secure_url'];
    final publicId = data['public_id'];
    if (url is! String ||
        url.isEmpty ||
        publicId is! String ||
        publicId.isEmpty) {
      throw const FormatException('Dịch vụ ảnh chưa trả về đủ thông tin ảnh.');
    }
    return AvatarUploadResult(url: url, publicId: publicId);
  }
}
