import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/settings/data/models/settings_models.dart';
import 'package:pathseek/features/settings/domain/entities/settings_entities.dart';
import 'package:pathseek/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:pathseek/features/settings/presentation/widgets/user_form_dialog.dart';
import 'settings_test_support.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 15));

void main() {
  test(
    'read-only initialization never requests users or allows writes',
    () async {
      final repo = FakeSettingsRepository();
      final bloc = SettingsBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(SettingsLoaded(manageUsers: false));
      bloc.add(SettingsUsersLoaded(const UserQuery()));
      bloc.add(
        SettingsUserSaved(
          const UserChanges(
            name: 'Test',
            email: 'test@example.test',
            role: 'ADMIN',
          ),
        ),
      );
      await settle();
      expect(bloc.state.roles, testRoles);
      expect(repo.userRequests, 0);
      expect(repo.changes, isEmpty);
    },
  );

  test(
    'late search response cannot replace the newest filter result',
    () async {
      final old = Completer<UserPage>();
      final recent = Completer<UserPage>();
      final repo = FakeSettingsRepository();
      final bloc = SettingsBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(SettingsLoaded(manageUsers: true));
      await settle();
      repo.loadUsers = (query) =>
          query.search == 'old' ? old.future : recent.future;
      bloc.add(SettingsUsersLoaded(const UserQuery(search: 'old')));
      await settle();
      bloc.add(SettingsUsersLoaded(const UserQuery(search: 'new')));
      await settle();
      recent.complete(
        const UserPage(
          users: [otherAccount],
          page: 0,
          totalPages: 1,
          totalElements: 1,
        ),
      );
      await settle();
      old.complete(
        const UserPage(
          users: [ownAccount],
          page: 0,
          totalPages: 1,
          totalElements: 1,
        ),
      );
      await settle();
      expect(bloc.state.userPage!.users, [otherAccount]);
      expect(bloc.state.query.search, 'new');
    },
  );

  test('save failure retains list and allows a successful retry', () async {
    final repo = FakeSettingsRepository()
      ..saveFailure = const ValidationFailure('El correo ya existe');
    final bloc = SettingsBloc(repository: repo);
    addTearDown(bloc.close);
    bloc.add(SettingsLoaded(manageUsers: true));
    await settle();
    const change = UserChanges(
      name: 'Nuevo',
      email: 'new@example.test',
      role: 'CLIENTE',
      password: 'Password12',
    );
    bloc.add(SettingsUserSaved(change));
    await settle();
    expect(bloc.state.saveError, 'El correo ya existe');
    expect(bloc.state.userPage!.users, isNotEmpty);
    expect(bloc.state.savedRevision, 0);
    repo.saveFailure = null;
    bloc.add(SettingsUserSaved(change));
    await settle();
    expect(bloc.state.saveError, isNull);
    expect(bloc.state.savedRevision, 1);
    expect(repo.userRequests, 2);
  });

  test(
    'edit payload excludes passwords; create excludes active and identifiers',
    () {
      expect(
        SettingsModels.payload(
          const UserChanges(
            id: 'user',
            name: 'Nombre',
            email: 'a@example.test',
            role: 'OPERADOR',
            active: false,
            password: 'ignored',
          ),
        ),
        {
          'nombre': 'Nombre',
          'email': 'a@example.test',
          'rol': 'OPERADOR',
          'activo': false,
        },
      );
      expect(
        SettingsModels.payload(
          const UserChanges(
            name: 'Nombre',
            email: 'a@example.test',
            role: 'CLIENTE',
            password: 'Password1',
          ),
        ),
        {
          'nombre': 'Nombre',
          'email': 'a@example.test',
          'rol': 'CLIENTE',
          'password': 'Password1',
        },
      );
    },
  );

  test('nullable account dates and pagination map from backend contract', () {
    final page = SettingsModels.page({
      'contenido': [
        {
          'usuario_id': 'u',
          'nombre': 'User',
          'email': 'user@example.test',
          'rol': 'CLIENTE',
          'activo': false,
          'bloqueado_hasta': null,
          'ultimo_login': '2026-10-22T15:00:00Z',
        },
      ],
      'pagina': 1,
      'total_paginas': 3,
      'total_elementos': 42,
    });
    expect(page.users.single.active, false);
    expect(page.users.single.blockedUntil, null);
    expect(page.users.single.lastLogin, DateTime.utc(2026, 10, 22, 15));
    expect(page.totalElements, 42);
  });

  test(
    'new passwords require mixed characters and at least eight characters',
    () {
      for (final value in [
        null,
        '',
        'short1A',
        'lowercase1',
        'UPPERCASE1',
        'NoNumbers',
      ]) {
        expect(validateAccountPassword(value), isNotNull);
      }
      expect(validateAccountPassword('Password1'), isNull);
      expect(
        validateAccountPassword('Password1${List.filled(35, 'ñ').join()}'),
        isNotNull,
      );
    },
  );
}
