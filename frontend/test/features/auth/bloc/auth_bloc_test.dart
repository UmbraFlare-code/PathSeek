import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/domain/repositories/auth_repository.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthBloc bloc;

  const user = AppUser(
    id: 'u1',
    nombre: 'Juan Perez',
    email: 'juan@ugel.edu.pe',
    rol: 'OPERADOR',
  );

  setUp(() {
    repository = MockAuthRepository();
    bloc = AuthBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('AuthBloc', () {
    test('initial state is unknown', () {
      expect(bloc.state, const AuthState.unknown());
    });

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no session exists',
      build: () {
        when(() => repository.currentUser())
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits authenticated when session exists',
      build: () {
        when(() => repository.currentUser())
            .thenAnswer((_) async => user);
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [AuthState.authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits loading then authenticated on successful login',
      build: () {
        when(() => repository.login(
              email: 'juan@ugel.edu.pe',
              password: 'password123',
            )).thenAnswer((_) async => user);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'juan@ugel.edu.pe',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure when login throws',
      build: () {
        when(() => repository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const UnauthorizedFailure('Credenciales invalidas'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'juan@ugel.edu.pe',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.failure('Credenciales invalidas'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated on logout',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => AuthState.authenticated(user),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });
}
