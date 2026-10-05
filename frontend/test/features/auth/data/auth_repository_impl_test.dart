import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/network/session_store.dart';
import 'package:pathseek/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pathseek/features/auth/data/models/auth_response_model.dart';
import 'package:pathseek/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSessionStore extends Mock implements SessionStore {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockSessionStore sessionStore;
  late AuthRepositoryImpl repository;

  const response = AuthResponseModel(
    token: 'access-token',
    refreshToken: 'refresh-token',
    usuario: AuthUserModel(
      id: 'u1',
      nombre: 'Juan Perez',
      email: 'juan@ugel.edu.pe',
      rol: 'OPERADOR',
    ),
  );

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    sessionStore = MockSessionStore();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      sessionStore: sessionStore,
    );
  });

  group('AuthRepositoryImpl.login', () {
    test('returns AppUser and saves session on success', () async {
      when(() => remoteDataSource.login(
            email: 'juan@ugel.edu.pe',
            password: 'password123',
          )).thenAnswer((_) async => response);
      when(() => sessionStore.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            userJson: any(named: 'userJson'),
          )).thenAnswer((_) async {});

      final user = await repository.login(
        email: 'juan@ugel.edu.pe',
        password: 'password123',
      );

      expect(user, isA<AppUser>());
      expect(user.email, 'juan@ugel.edu.pe');
      expect(user.rol, 'OPERADOR');
      verify(() => sessionStore.saveSession(
            accessToken: 'access-token',
            refreshToken: 'refresh-token',
            userJson: any(named: 'userJson'),
          )).called(1);
    });

    test('maps 401 to UnauthorizedFailure', () async {
      when(() => remoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
            statusCode: 401,
            data: {'message': 'Credenciales invalidas'},
          ),
        ),
      );

      expect(
        () => repository.login(email: 'a@b.com', password: 'wrong'),
        throwsA(
          isA<UnauthorizedFailure>()
              .having((f) => f.message, 'message', 'Credenciales invalidas'),
        ),
      );
    });

    test('maps connection errors to NetworkFailure', () async {
      when(() => remoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          error: const NoConnectionException(),
        ),
      );

      expect(
        () => repository.login(email: 'a@b.com', password: '12345678'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
