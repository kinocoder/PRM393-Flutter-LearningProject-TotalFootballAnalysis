import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:united2/data/services/cloudinary_service.dart';
import 'package:united2/data/model/avatar_failure.dart';

class ControlledUploadClient extends http.BaseClient {
  ControlledUploadClient(this.respond);
  final Future<http.StreamedResponse> Function(http.BaseRequest) respond;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      respond(request);
  @override
  void close() => closed = true;
}

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
            contains('HTTP $status'),
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
  test('C04 network error has a useful message and retains cause', () async {
    final error = http.ClientException('offline');
    final client = MockClient((_) async => throw error);
    addTearDown(client.close);
    await expectLater(
      AvatarCloudinaryService(client: client).uploadAvatar(image),
      throwsA(
        isA<AvatarUploadException>().having(
          (e) => e.cause,
          'cause',
          same(error),
        ),
      ),
    );
  });

  for (final size in [0, 4]) {
    test('C05 invalid size $size rejected before HTTP send', () async {
      await File(image.path).writeAsBytes(List.filled(size, 1));
      var sent = false;
      final client = MockClient((_) async {
        sent = true;
        return http.Response('{}', 200);
      });
      addTearDown(client.close);
      await expectLater(
        AvatarCloudinaryService(
          client: client,
          maxFileBytes: 3,
        ).uploadAvatar(image),
        throwsA(isA<AvatarUploadException>()),
      );
      expect(sent, isFalse);
    });
  }

  test('C06 file exactly at size limit is allowed', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"secure_url":"https://example.test/a.png","public_id":"id"}',
        200,
      ),
    );
    addTearDown(client.close);
    final result = await AvatarCloudinaryService(
      client: client,
      maxFileBytes: 3,
    ).uploadAvatar(image);
    expect(result.publicId, 'id');
  });

  for (final bodyStalls in [false, true]) {
    test('C07 deadline aborts upload (body stalls=$bodyStalls)', () async {
      final headers = Completer<http.StreamedResponse>();
      final body = StreamController<List<int>>();
      final aborted = Completer<void>();
      final client = ControlledUploadClient((request) {
        expect(request, isA<http.AbortableMultipartRequest>());
        (request as http.AbortableMultipartRequest).abortTrigger!.then((_) {
          aborted.complete();
          if (bodyStalls) body.addError(http.RequestAbortedException());
        });
        return bodyStalls
            ? Future.value(http.StreamedResponse(body.stream, 200))
            : headers.future;
      });
      final service = AvatarCloudinaryService(
        client: client,
        uploadTimeout: const Duration(milliseconds: 100),
      );
      await expectLater(
        service.uploadAvatar(image),
        throwsA(
          isA<AvatarUploadException>().having(
            (e) => e.message,
            'message',
            contains('quá thời gian'),
          ),
        ),
      );
      await aborted.future;
      expect(client.closed, isFalse, reason: 'Injected client is caller owned');
      if (bodyStalls) {
        await body.close();
      } else {
        // A late successful response cannot turn the timed-out result into success.
        headers.complete(
          http.StreamedResponse(
            Stream.value(
              '{"secure_url":"https://example.test/a.png","public_id":"late"}'
                  .codeUnits,
            ),
            200,
          ),
        );
        // No listener was installed on this controller in the headers-only case.
        body.close();
      }
      client.close();
    });
  }
}
