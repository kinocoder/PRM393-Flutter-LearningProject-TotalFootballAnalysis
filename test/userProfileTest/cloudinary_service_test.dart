import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:united2/data/services/cloudinary_service.dart';

void main() {
  late Directory directory;
  late XFile image;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('d04_upload_');
    final file = await File('${directory.path}/avatar.png')
        .writeAsBytes([1, 2, 3]);
    image = XFile(file.path);
  });
  tearDown(() => directory.delete(recursive: true));

  test('C01 multipart upload parses secure_url and public_id', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, endsWith('/image/upload'));
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(request.body, contains('name="upload_preset"'));
      expect(request.body, contains('name="file"; filename="avatar.png"'));
      return http.Response(
        '{"secure_url":"https://example.test/a.png","public_id":"avatars/one"}',
        200,
      );
    });
    addTearDown(client.close);
    final result = await AvatarCloudinaryService(client: client)
        .uploadAvatar(image);
    expect(result.url, 'https://example.test/a.png');
    expect(result.publicId, 'avatars/one');
  });
  for (final status in [400, 401, 500]) {
    test('C02 HTTP $status reports upload failure', () async {
      final client = MockClient((_) async => http.Response('denied', status));
      addTearDown(client.close);
      await expectLater(
        AvatarCloudinaryService(client: client).uploadAvatar(image),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cloudinary upload failed'),
          ),
        ),
      );
    });
  }
  for (final body in [
    '{}',
    '{"secure_url":"url"}',
    '{"public_id":"id"}',
    '{"secure_url":"","public_id":"id"}',
    '{"secure_url":42,"public_id":"id"}',
    'invalid json',
    'null',
    '[]',
    '{"secure_url":"url","public_id":""}',
  ]) {
    test('C03 invalid response rejected: $body', () async {
      final client = MockClient((_) async => http.Response(body, 200));
      addTearDown(client.close);
      await expectLater(
        AvatarCloudinaryService(client: client).uploadAvatar(image),
        throwsFormatException,
      );
    });
  }
  test('C04 network error propagates unchanged', () async {
    final error = http.ClientException('offline');
    final client = MockClient((_) async => throw error);
    addTearDown(client.close);
    await expectLater(
      AvatarCloudinaryService(client: client).uploadAvatar(image),
      throwsA(same(error)),
    );
  });
}
