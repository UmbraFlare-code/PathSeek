import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/routes/data/datasources/route_remote_datasource.dart';
import 'package:pathseek/features/routes/domain/entities/route_plan.dart';
import 'package:pathseek/features/routes/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<RoutePlan> generateRoutes({
    required String fechaOperacion,
    required double depositoLat,
    required double depositoLon,
    required double velocidadKmh,
    int tiempoServicioMin = 15,
  }) async {
    try {
      return await _remoteDataSource.generateRoutes({
        'fecha_operacion': fechaOperacion,
        'deposito': {'latitud': depositoLat, 'longitud': depositoLon},
        'velocidad_kmh': velocidadKmh,
        'tiempo_servicio_min': tiempoServicioMin,
      });
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<RoutePerformance> getPerformance() async {
    try {
      return await _remoteDataSource.getPerformance();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<bool> isLocked() async {
    try {
      return await _remoteDataSource.isLocked();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<RouteConfirmResult> confirmRoutes(List<String> pedidoIds) async {
    try {
      final json = await _remoteDataSource.confirmRoutes(pedidoIds);
      return RouteConfirmResult(
        confirmados: json['confirmados'] ?? 0,
        omitidos: json['omitidos'] ?? 0,
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
