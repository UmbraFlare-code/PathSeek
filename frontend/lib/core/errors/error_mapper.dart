import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

Failure mapDioExceptionToFailure(DioException exception) {
  if (exception.error is NoConnectionException) {
    return const NetworkFailure();
  }

  final statusCode = exception.response?.statusCode;
  final data = exception.response?.data;

  String extractMessage() {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ??
          data['error'] ??
          data['detail'];
      if (message != null) return message.toString();
    }
    return 'Error del servidor';
  }

  switch (statusCode) {
    case 400:
    case 422:
      return ValidationFailure(extractMessage());
    case 401:
      return const UnauthorizedFailure();
    case 403:
      return const ForbiddenFailure();
    case 404:
      return const NotFoundFailure();
    case 500:
    case 502:
    case 503:
      return ServerFailure(extractMessage(), statusCode: statusCode);
    default:
      return ServerFailure(
        extractMessage(),
        statusCode: statusCode,
      );
  }
}
