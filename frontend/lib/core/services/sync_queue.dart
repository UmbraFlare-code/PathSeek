import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Cola persistida de acciones del conductor pendientes de sincronizar (EN-008).
/// Soporta registrar posición y completar entregas sin conexión; al recuperar
/// la conectividad se reintentan en orden hasta que la API las confirme.
class SyncQueue {
  static const _queueKey = 'offline_sync_queue_v1';
  static const _uuid = Uuid();

  Future<void> enqueue({
    required String tipo,
    required String rutaId,
    String? pedidoId,
    double? lat,
    double? lon,
  }) async {
    final items = await _read();
    items.add({
      'id': _uuid.v4(),
      'tipo': tipo,
      'ruta_id': rutaId,
      'pedido_id': ?pedidoId,
      'lat': ?lat,
      'lon': ?lon,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _write(items);
  }

  Future<List<SyncAction>> list() async {
    final items = await _read();
    return items
        .map(
          (item) => SyncAction(
            tipo: item['tipo'] as String,
            rutaId: item['ruta_id'] as String,
            pedidoId: item['pedido_id'] as String?,
            lat: (item['lat'] as num?)?.toDouble(),
            lon: (item['lon'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  Future<void> removeFirst() async {
    final items = await _read();
    if (items.isEmpty) return;
    items.removeAt(0);
    await _write(items);
  }

  Future<int> length() async => (await _read()).length;

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  Future<List<Map<String, dynamic>>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map>().map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  Future<void> _write(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queueKey, jsonEncode(items));
  }
}

class SyncAction {
  const SyncAction({
    required this.tipo,
    required this.rutaId,
    this.pedidoId,
    this.lat,
    this.lon,
  });

  final String tipo;
  final String rutaId;
  final String? pedidoId;
  final double? lat;
  final double? lon;
}
