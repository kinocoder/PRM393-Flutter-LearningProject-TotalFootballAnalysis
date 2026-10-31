import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AvatarUploadResult {
  final String url;
  final String publicId;

  const AvatarUploadResult({required this.url, required this.publicId});
}

class AvatarCloudinaryService {
  AvatarCloudinaryService({this.client});

  // An injected client is owned and closed by the caller.
  final http.Client? client;
  static const String _cloudName = 'ydzyh7bn';
  static const String _uploadPreset = 'totalfootball_avatars';

  Future<AvatarUploadResult> uploadAvatar(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await (client?.send(request) ?? request.send());
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $responseBody');
    }

    final data = jsonDecode(responseBody);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Cloudinary response must be an object');
    }

    final url = data['secure_url'];
    final publicId = data['public_id'];
    if (url is! String ||
        url.isEmpty ||
        publicId is! String ||
        publicId.isEmpty) {
      throw const FormatException('Cloudinary response is missing avatar data');
    }
    return AvatarUploadResult(url: url, publicId: publicId);
  }
}
