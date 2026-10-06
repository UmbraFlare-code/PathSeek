import 'package:dio/dio.dart';

import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/delivery_route_model.dart';

abstract class RouteRemoteDataSource {
  Future<List<DeliveryRouteModel>> getRoutes({String? fecha});

  Future<DeliveryRouteModel> getRouteById(String id);

  /// Devuelve las rutas generadas y los IDs de pedidos no asignados.
  Future<Map<String, dynamic>> generateRoutes();

  Future<void> deleteRoute(String id);
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  RouteRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<DeliveryRouteModel>> getRoutes({String? fecha}) async {
    final response = await _client.dio.get(
      ApiPaths.rutas,
      queryParameters: fecha != null ? {'fecha': fecha} : null,
    );
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((item) => DeliveryRouteModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeliveryRouteModel> getRouteById(String id) async {
    final response = await _client.dio.get('${ApiPaths.rutas}/$id');
    return DeliveryRouteModel.fromJson(_unwrap(response.data));
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

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
