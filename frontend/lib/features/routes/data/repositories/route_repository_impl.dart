import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/routes/data/datasources/route_remote_datasource.dart';
import 'package:pathseek/features/routes/data/models/delivery_route_model.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/generate_routes_result.dart';
import 'package:pathseek/features/routes/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<List<DeliveryRoute>> getRoutes({String? fecha}) async {
    try {
      final models = await _remoteDataSource.getRoutes(fecha: fecha);
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<DeliveryRoute> getRouteById(String id) async {
    try {
      final model = await _remoteDataSource.getRouteById(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<GenerateRoutesResult> generateRoutes() async {
    try {
      final data = await _remoteDataSource.generateRoutes();

      final rutasJson = data['rutas'];
      final rutas = rutasJson is List
          ? rutasJson
              .map(
                (r) => DeliveryRouteModel.fromJson(r as Map<String, dynamic>)
                    .toEntity(),
              )
              .toList()
          : <DeliveryRoute>[];

      final noAsignadosJson = data['pedidos_no_asignados'];
      final noAsignados = noAsignadosJson is List
          ? noAsignadosJson.map((id) => id.toString()).toList()
          : <String>[];

      return GenerateRoutesResult(
        rutas: rutas,
        pedidosNoAsignados: noAsignados,
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<DeliveryRoute> reoptimizeRoute(
    String id, {
    required String motivo,
    required double latitudIncidente,
    required double longitudIncidente,
    int radioBloqueoMetros = 250,
    List<String> pedidosCancelados = const [],
  }) async {
    try {
      final model = await _remoteDataSource.reoptimizeRoute(
        id,
        motivo: motivo,
        latitudIncidente: latitudIncidente,
        longitudIncidente: longitudIncidente,
        radioBloqueoMetros: radioBloqueoMetros,
        pedidosCancelados: pedidosCancelados,
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    try {
      await _remoteDataSource.deleteRoute(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
