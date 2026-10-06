import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/constants/api_paths.dart';
import 'package:pathseek/core/constants/app_roles.dart';
import 'package:pathseek/core/config/environment.dart';
import 'package:pathseek/core/network/session_store.dart';
import 'package:pathseek/core/network/shared_prefs_token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiPaths', () {
    test('paths are prefixed with /api/v1', () {
      expect(ApiPaths.authLogin, '/api/v1/auth/login');
      expect(ApiPaths.vehiculos, '/api/v1/vehiculos');
      expect(ApiPaths.rutasGenerar, '/api/v1/rutas/generar');
      expect(ApiPaths.dashboardResumen, '/api/v1/dashboard/resumen');
    });
  });

  group('AppRoles', () {
    test('contains the 5 documented roles', () {
      expect(AppRoles.all,
          ['ADMIN', 'OPERADOR', 'CONDUCTOR', 'CLIENTE', 'AUDITOR']);
    });
  });

  group('Environment', () {
    test('current resolves to a valid environment', () {
      final env = Environment.current;
      expect(env.apiBaseUrl, isNotEmpty);
      expect(
        [AppEnvironment.dev, AppEnvironment.staging, AppEnvironment.prod],
        contains(env.name),
      );
    });

    test('isProduction only for prod', () {
      expect(Environment.prod.isProduction, isTrue);
      expect(Environment.dev.isProduction, isFalse);
    });
  });

  group('SharedPrefsTokenStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and reads tokens', () async {
      final storage = SharedPrefsTokenStorage();
      expect(await storage.readAccessToken(), isNull);

      await storage.saveTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );

      expect(await storage.readAccessToken(), 'access-1');
      expect(await storage.readRefreshToken(), 'refresh-1');
    });

    test('clear removes tokens', () async {
      final storage = SharedPrefsTokenStorage();
      await storage.saveTokens(accessToken: 'a', refreshToken: 'r');
      await storage.clear();

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
    });
  });

  group('SessionStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves session with tokens and user json', () async {
      final store = SessionStore(
        tokenStorage: SharedPrefsTokenStorage(),
      );

      await store.saveSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        userJson: '{"usuario_id":"u1","nombre":"Juan","email":"j@x.pe","rol":"OPERADOR"}',
      );

      final userJson = await store.readUserJson();
      expect(userJson, isNotNull);
      expect(userJson, contains('"usuario_id":"u1"'));
    });

    test('readUserJson returns null without session', () async {
      final store = SessionStore(
        tokenStorage: SharedPrefsTokenStorage(),
      );
      expect(await store.readUserJson(), isNull);
    });

    test('clear removes tokens and user', () async {
      final tokenStorage = SharedPrefsTokenStorage();
      final store = SessionStore(tokenStorage: tokenStorage);
      await store.saveSession(
        accessToken: 'a',
        refreshToken: 'r',
        userJson: '{}',
      );
      await store.clear();

      expect(await store.readUserJson(), isNull);
      expect(await tokenStorage.readAccessToken(), isNull);
    });
  });
}
