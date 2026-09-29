abstract class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sesion expirada o no autorizada']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Sin permisos para esta accion']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexion con el servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}
