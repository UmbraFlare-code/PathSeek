import 'package:dio/dio.dart';

import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/offline_route_cache.dart';
import '../models/delivery_route_model.dart';

abstract class RouteRemoteDataSource {
  Future<List<DeliveryRouteModel>> getRoutes({String? fecha});

  Future<DeliveryRouteModel> getRouteById(String id);

  /// Devuelve las rutas generadas y los IDs de pedidos no asignados.
  Future<Map<String, dynamic>> generateRoutes();

  Future<void> deleteRoute(String id);

  Future<Map<String, dynamic>> completeDelivery(String rutaId, String pedidoId);

  Future<Map<String, dynamic>> reportPosition(
    String rutaId,
    double lat,
    double lon,
  );

  Future<void> reportIncident(String rutaId, Map<String, dynamic> payload);

  Future<Map<String, dynamic>> reoptimize(Map<String, dynamic> payload);
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  RouteRemoteDataSourceImpl(this._client, {OfflineRouteCache? cache})
      : _cache = cache ?? OfflineRouteCache();

  final ApiClient _client;
  final OfflineRouteCache _cache;

  @override
  Future<List<DeliveryRouteModel>> getRoutes({String? fecha}) async {
    final response = await _client.dio.get(
      ApiPaths.rutas,
      queryParameters: fecha != null ? {'fecha': fecha} : null,
    );
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    final raw = list.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
    await _saveSilently(() => _cache.saveRoutes(raw));
    return list
        .map(
          (item) => DeliveryRouteModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<DeliveryRouteModel> getRouteById(String id) async {
    final response = await _client.dio.get('${ApiPaths.rutas}/$id');
    var geometry = await _client.dio.get('${ApiPaths.rutas}/$id/geometria');
    var data = _unwrap(geometry.data);
    if (data['geometryStatus'] == 'PROVIDER_UNAVAILABLE' ||
        data['geometryStatus'] == 'RATE_LIMITED') {
      // One bounded retry; respect the provider's one request/second limit.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      geometry = await _client.dio.get('${ApiPaths.rutas}/$id/geometria');
      data = _unwrap(geometry.data);
    }
    final merged = <String, dynamic>{
      ..._unwrap(response.data),
      'encoded_polyline': data['encodedPolyline'] ?? data['encoded_polyline'],
      'geometrySource': data['geometrySource'],
      'geometryStatus': data['geometryStatus'],
      'roadDistanceKm': data['roadDistanceKm'],
      'roadTravelMinutes': data['roadTravelMinutes'],
    };
    await _saveSilently(() => _cache.saveRouteDetail(id, merged));
    return DeliveryRouteModel.fromJson(merged);
  }

  @override
  Future<Map<String, dynamic>> generateRoutes() async {
    // El SLA del motor de optimizacion es <= 45 s; se amplia el timeout
    // solo para esta peticion (RNF-001).
    final response = await _client.dio.post(
      ApiPaths.rutasGenerar,
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    return _unwrap(response.data);
  }

  @override
  Future<void> deleteRoute(String id) async {
    await _client.dio.delete('${ApiPaths.rutas}/$id');
  }

  @override
  Future<Map<String, dynamic>> completeDelivery(
    String rutaId,
    String pedidoId,
  ) async {
    final response = await _client.dio.post(
      '${ApiPaths.rutas}/$rutaId/entregas/$pedidoId/completar',
    );
    return _unwrap(response.data);
  }

  @override
  Future<Map<String, dynamic>> reportPosition(
    String rutaId,
    double lat,
    double lon,
  ) async {
    final response = await _client.dio.post(
      '${ApiPaths.rutas}/$rutaId/posicion',
      data: {'lat': lat, 'lon': lon},
    );
    return _unwrap(response.data);
  }

  @override
  Future<void> reportIncident(
    String rutaId,
    Map<String, dynamic> payload,
  ) async {
    await _client.dio.post(
      '${ApiPaths.rutas}/$rutaId/incidentes',
      data: payload,
    );
  }

  @override
  Future<Map<String, dynamic>> reoptimize(Map<String, dynamic> payload) async {
    final response = await _client.dio.post(
      ApiPaths.rutasReoptimizar,
      data: payload,
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    return _unwrap(response.data);
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }

  Future<void> _saveSilently(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      // La caché offline es best-effort: nunca debe romper el flujo en línea.
    }
  }
}
