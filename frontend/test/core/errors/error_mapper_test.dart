import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:dio/dio.dart';

void main() {
  group('mapDioExceptionToFailure', () {
    test('maps connection errors to NetworkFailure', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        error: const NoConnectionException(),
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });

    test('maps 400/422 to ValidationFailure with server message', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 422,
          data: {'message': 'La placa ya existe'},
        ),
      );

      final failure = mapDioExceptionToFailure(exception);
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'La placa ya existe');
    });

    test('maps 401 to UnauthorizedFailure', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 401,
        ),
      );

      expect(
        mapDioExceptionToFailure(exception),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps 403 to ForbiddenFailure', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 403,
        ),
      );

      expect(
        mapDioExceptionToFailure(exception),
        isA<ForbiddenFailure>(),
      );
    });

    test('maps 404 to NotFoundFailure', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 404,
        ),
      );

      expect(
        mapDioExceptionToFailure(exception),
        isA<NotFoundFailure>(),
      );
    });

    test('maps 500 to ServerFailure with status code', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 500,
          data: {'error': 'Error interno'},
        ),
      );

      final failure = mapDioExceptionToFailure(exception);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });
  });
}
