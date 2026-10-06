import 'package:dio/dio.dart';

import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/route_plan_model.dart';

abstract class RouteRemoteDataSource {
  Future<RoutePlanModel> generateRoutes(Map<String, dynamic> body);

  Future<Map<String, int>> confirmRoutes(List<String> pedidoIds);

  Future<RoutePerformanceModel> getPerformance();

  Future<bool> isLocked();
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  RouteRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<RoutePlanModel> generateRoutes(Map<String, dynamic> body) async {
    final response = await _client.dio.post(
      ApiPaths.rutasGenerar,
      data: body,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    final data = response.data;
    final json = (data is Map<String, dynamic> && data.containsKey('ruta_id'))
        ? data
        : (data['data'] as Map<String, dynamic>? ?? data as Map<String, dynamic>);
    return RoutePlanModel.fromJson(json);
  }

  @override
  Future<Map<String, int>> confirmRoutes(List<String> pedidoIds) async {
    final response = await _client.dio.post(
      ApiPaths.rutasConfirmar,
      data: {
        'pedido_ids': pedidoIds,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final json = data.containsKey('confirmados')
        ? data
        : (data['data'] as Map<String, dynamic>);
    return {
      'confirmados': (json['confirmados'] as num? ?? 0).toInt(),
      'omitidos': (json['omitidos'] as num? ?? 0).toInt(),
    };
  }

  @override
  Future<RoutePerformanceModel> getPerformance() async {
    final response = await _client.dio.get(ApiPaths.rutasMetricas);
    final data = response.data as Map<String, dynamic>;
    final json = data.containsKey('total_solicitudes')
        ? data
        : (data['data'] as Map<String, dynamic>);
    return RoutePerformanceModel.fromJson(json);
  }

  @override
  Future<bool> isLocked() async {
    final response = await _client.dio.get(ApiPaths.rutasLock);
    final data = response.data as Map<String, dynamic>;
    final json = data.containsKey('en_ejecucion')
        ? data
        : (data['data'] as Map<String, dynamic>);
    return json['en_ejecucion'] == true;
  }
}
