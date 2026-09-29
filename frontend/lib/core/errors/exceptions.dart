class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final dynamic detail;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}
