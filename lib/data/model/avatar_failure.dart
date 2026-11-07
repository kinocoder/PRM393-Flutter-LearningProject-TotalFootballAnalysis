/// Upload failed before a usable Cloudinary result was received.
class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Cloudinary accepted the image, but the profile write was not confirmed.
/// Retain the asset for reconciliation; a timed-out write may still succeed.
class AvatarSaveException implements Exception {
  const AvatarSaveException({
    required this.uid,
    required this.avatarUrl,
    required this.avatarPublicId,
    required this.cause,
    this.timedOut = false,
  });

  final String uid;
  final String avatarUrl;
  final String avatarPublicId;
  final Object cause;
  final bool timedOut;

  @override
  String toString() => timedOut
      ? 'Ảnh đã tải lên nhưng chưa xác nhận được việc lưu hồ sơ. '
            'Hãy kiểm tra kết nối và tải lại hồ sơ trước khi thử đổi ảnh lần nữa.'
      : 'Ảnh đã tải lên nhưng lưu hồ sơ gặp lỗi. '
            'Hãy tải lại hồ sơ để kiểm tra trước khi thử đổi ảnh lần nữa.';
}
