import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';

void main() {
  group('Exceptions', () {
    test('ServerException holds message and status', () {
      const exception = ServerException('Error', statusCode: 500, detail: {});

      expect(exception.message, 'Error');
      expect(exception.statusCode, 500);
      expect(exception.detail, isNotNull);
      expect(exception.toString(), 'ServerException(500): Error');
    });

    test('NoConnectionException has toString', () {
      const exception = NoConnectionException();
      expect(exception.toString(), 'NoConnectionException');
    });
  });

  group('Failures', () {
    test('ServerFailure stores message and status', () {
      const failure = ServerFailure('msg', statusCode: 502);
      expect(failure.message, 'msg');
      expect(failure.statusCode, 502);
      expect(failure.toString(), contains('ServerFailure'));
    });

    test('UnauthorizedFailure has default message', () {
      const failure = UnauthorizedFailure();
      expect(failure.message, isNotEmpty);
    });

    test('ForbiddenFailure has default message', () {
      const failure = ForbiddenFailure();
      expect(failure.message, isNotEmpty);
    });

    test('NotFoundFailure has default message', () {
      const failure = NotFoundFailure();
      expect(failure.message, isNotEmpty);
    });

    test('ValidationFailure stores message', () {
      const failure = ValidationFailure('campo invalido');
      expect(failure.message, 'campo invalido');
    });

    test('NetworkFailure and CacheFailure are Failures', () {
      expect(const NetworkFailure(), isA<Failure>());
      expect(const CacheFailure(), isA<Failure>());
    });
  });
}
