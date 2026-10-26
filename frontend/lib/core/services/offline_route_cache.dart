import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Caché local de las rutas propias del conductor (EN-008).
/// Guarda el JSON crudo recibido de la API para poder mostrarlo sin conexión
/// y sincronizar las acciones pendientes al recuperarla.
class OfflineRouteCache {
  static const _routesKey = 'offline_routes_v1';
  static const _detailPrefix = 'offline_route_detail_v1_';

  Future<void> saveRoutes(List<Map<String, dynamic>> rawRoutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _routesKey,
      jsonEncode(rawRoutes),
    );
  }

  Future<List<Map<String, dynamic>>?> readRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_routesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map>().map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveRouteDetail(
    String routeId,
    Map<String, dynamic> rawRoute,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_detailPrefix$routeId', jsonEncode(rawRoute));
  }

  Future<Map<String, dynamic>?> readRouteDetail(String routeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_detailPrefix$routeId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (key) => key == _routesKey || key.startsWith(_detailPrefix),
    );
    for (final key in keys.toList()) {
      await prefs.remove(key);
    }
  }
}
