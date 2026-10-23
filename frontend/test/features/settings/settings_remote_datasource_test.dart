import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/network/api_client.dart';
import 'package:pathseek/core/network/token_storage.dart';
import 'package:pathseek/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:pathseek/features/settings/domain/entities/settings_entities.dart';

class Storage extends Mock implements TokenStorage {}

class SettingsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    expect(options.headers['Authorization'], 'Bearer settings-token');
    final user = {
      'usuario_id': 'u1',
      'nombre': 'Usuario',
      'email': 'user@example.test',
      'rol': 'CLIENTE',
      'activo': true,
      'bloqueado_hasta': null,
      'ultimo_login': null,
    };
    final Object body = options.path.endsWith('/roles')
        ? [
            {
              'rol': 'CLIENTE',
              'nombre': 'Cliente',
              'descripcion': 'Pedidos propios',
              'permisos': ['Crear pedidos propios'],
            },
          ]
        : options.method == 'GET'
        ? {
            'contenido': [user],
            'pagina': 2,
            'total_paginas': 3,
            'total_elementos': 41,
          }
        : user;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late SettingsAdapter adapter;
  late SettingsRemoteDataSource source;
  setUp(() {
    final storage = Storage();
    when(
      () => storage.readAccessToken(),
    ).thenAnswer((_) async => 'settings-token');
    adapter = SettingsAdapter();
    source = SettingsRemoteDataSourceImpl(
      ApiClient(tokenStorage: storage, dio: Dio()..httpClientAdapter = adapter),
    );
  });
  test(
    'reads roles and filters the paged account endpoint using authenticated API',
    () async {
      final roles = await source.getRoles();
      final page = await source.getUsers(
        const UserQuery(
          page: 2,
          search: ' user ',
          role: 'CLIENTE',
          active: false,
        ),
      );
      expect(roles.single.code, 'CLIENTE');
      expect(adapter.requests.first.path, '/api/v1/configuracion/roles');
      expect(adapter.requests.last.path, '/api/v1/usuarios');
      expect(adapter.requests.last.queryParameters, {
        'pagina': 2,
        'tamano': 20,
        'buscar': 'user',
        'rol': 'CLIENTE',
        'activo': false,
      });
      expect(page.totalElements, 41);
      expect(page.users.single.id, 'u1');
    },
  );
  test(
    'create posts password; edit puts account details without password',
    () async {
      await source.saveUser(
        const UserChanges(
          name: 'Usuario',
          email: 'user@example.test',
          role: 'CLIENTE',
          password: 'Password1',
        ),
      );
      await source.saveUser(
        const UserChanges(
          id: 'u1',
          name: 'Usuario',
          email: 'user@example.test',
          role: 'CLIENTE',
          active: false,
        ),
      );
      expect(adapter.requests.first.method, 'POST');
      expect(adapter.requests.first.data['password'], 'Password1');
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/api/v1/usuarios/u1');
      expect(adapter.requests.last.data.containsKey('password'), false);
      expect(adapter.requests.last.data['activo'], false);
    },
  );
}
