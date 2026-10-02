/// Lỗi thống nhất cho toàn app. Màn hình chỉ hiển thị [userMessage].
class AppException implements Exception {
  const AppException(this.userMessage, {this.code, this.cause});

  final String userMessage;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException($code): $userMessage';
}

/// Không kết nối được máy chủ (mất mạng, timeout, sai địa chỉ).
class NetworkException extends AppException {
  const NetworkException([Object? cause])
      : super('Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.',
            code: 'network', cause: cause);
}

/// API trả 404.
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Không tìm thấy dữ liệu.'])
      : super(message, code: 'not_found');
}

/// API trả 5xx hoặc dữ liệu không đọc được.
class ServerException extends AppException {
  const ServerException([String message = 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.', Object? cause])
      : super(message, code: 'server', cause: cause);
}

/// Chuyển mọi lỗi thành câu tiếng Việt dễ hiểu.
String describeError(Object error) {
  if (error is AppException) return error.userMessage;
  return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
}
