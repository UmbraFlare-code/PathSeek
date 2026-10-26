import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/services/offline_route_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and reads the cached route list', () async {
    final cache = OfflineRouteCache();
    await cache.saveRoutes([
      {'ruta_id': 'r1', 'fecha': '2026-10-25', 'estado': 'EN_PROGRESO'},
    ]);

    final routes = await cache.readRoutes();
    expect(routes, hasLength(1));
    expect(routes!.first['ruta_id'], 'r1');
  });

  test('saves and reads a cached route detail', () async {
    final cache = OfflineRouteCache();
    await cache.saveRouteDetail('r9', {'ruta_id': 'r9', 'placa': 'ABC123'});

    final detail = await cache.readRouteDetail('r9');
    expect(detail!['placa'], 'ABC123');
    expect(await cache.readRouteDetail('r8'), isNull);
  });

  test('clear removes routes and details', () async {
    final cache = OfflineRouteCache();
    await cache.saveRoutes([
      {'ruta_id': 'r1'},
    ]);
    await cache.saveRouteDetail('r1', {'ruta_id': 'r1'});
    await cache.clear();

    expect(await cache.readRoutes(), isNull);
    expect(await cache.readRouteDetail('r1'), isNull);
  });
}
