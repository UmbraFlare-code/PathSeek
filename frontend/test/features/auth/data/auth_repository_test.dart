import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/network/session_store.dart';
import 'package:pathseek/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pathseek/features/auth/data/repositories/auth_repository_impl.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockSessionStore extends Mock implements SessionStore {}

class _FakeFailure implements Failure {
  @override
  String get message => 'sin red';
}

void main() {
  late _MockAuthRemoteDataSource remote;
  late _MockSessionStore sessionStore;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockAuthRemoteDataSource();
    sessionStore = _MockSessionStore();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      sessionStore: sessionStore,
    );
  });

  group('logout', () {
    test('revoca el refresh token en el backend y limpia la sesión local',
        () async {
      when(() => sessionStore.readRefreshToken())
          .thenAnswer((_) async => 'refresh-123');
      when(() => remote.logout(refreshToken: 'refresh-123'))
          .thenAnswer((_) async {});
      when(() => sessionStore.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => remote.logout(refreshToken: 'refresh-123')).called(1);
      verify(() => sessionStore.clear()).called(1);
    });

    test('limpia la sesión local aunque el backend falle', () async {
      when(() => sessionStore.readRefreshToken())
          .thenAnswer((_) async => 'refresh-123');
      when(() => remote.logout(refreshToken: 'refresh-123'))
          .thenThrow(_FakeFailure());
      when(() => sessionStore.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => sessionStore.clear()).called(1);
    });

    test('no llama al backend si no hay refresh token guardado', () async {
      when(() => sessionStore.readRefreshToken()).thenAnswer((_) async => null);
      when(() => sessionStore.clear()).thenAnswer((_) async {});

      await repository.logout();

      verifyNever(() => remote.logout(refreshToken: any(named: 'refreshToken')));
      verify(() => sessionStore.clear()).called(1);
    });
  });
}
