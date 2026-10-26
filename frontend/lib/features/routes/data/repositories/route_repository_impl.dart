import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/core/errors/exceptions.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/services/sync_queue.dart';
import 'package:pathseek/features/routes/data/datasources/route_remote_datasource.dart';
import 'package:pathseek/features/routes/data/models/delivery_route_model.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_update.dart';
import 'package:pathseek/features/routes/domain/entities/generate_routes_result.dart';
import 'package:pathseek/features/routes/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({
    required RouteRemoteDataSource remoteDataSource,
    SyncQueue? syncQueue,
  })  : _remoteDataSource = remoteDataSource,
        _syncQueue = syncQueue ?? SyncQueue();

  final RouteRemoteDataSource _remoteDataSource;
  final SyncQueue _syncQueue;

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

      final noAsignadosJson =
          data['pedidos_no_asignados'] ?? data['pedidosNoAsignados'];
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
  Future<void> deleteRoute(String id) async {
    try {
      await _remoteDataSource.deleteRoute(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<DeliveryUpdate> completeDelivery(
    String rutaId,
    String pedidoId,
  ) async {
    try {
      final data = await _remoteDataSource.completeDelivery(rutaId, pedidoId);
      return DeliveryUpdate(
        pedidoEstado: (data['pedido_estado'] ?? '').toString(),
        rutaEstado: (data['ruta_estado'] ?? '').toString(),
        cumplioVentana: data['cumplio_ventana'] as bool?,
        yaRegistrado: data['ya_registrado'] == true,
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<DeliveryUpdate> reportPosition(
    String rutaId,
    double lat,
    double lon,
  ) async {
    try {
      final data = await _remoteDataSource.reportPosition(rutaId, lat, lon);
      return DeliveryUpdate(
        pedidoEstado: data['pedido_estado']?.toString(),
        rutaEstado: (data['ruta_estado'] ?? '').toString(),
        cumplioVentana: data['cumplio_ventana'] as bool?,
        yaRegistrado: data['ya_registrado'] == true,
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> reportIncident(
    String rutaId,
    Map<String, dynamic> payload,
  ) async {
    try {
      await _remoteDataSource.reportIncident(rutaId, payload);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<ReoptimizationResult> reoptimize(Map<String, dynamic> payload) async {
    try {
      final data = await _remoteDataSource.reoptimize(payload);
      return ReoptimizationResult(
        rutasReoptimizadas: _listLength(data['rutas_reoptimizadas']),
        rutasSinCambios: _listLength(data['rutas_sin_cambios']),
        pedidosNoAsignados: _listLength(data['pedidos_no_asignados']),
        notificacionesGeneradas: _toInt(data['notificaciones_generadas']),
        tiempoCalculoMs: _toInt(data['tiempo_calculo_ms']),
      );
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<int> flushOfflineQueue() async {
    var synced = 0;
    while (await _syncQueue.length() > 0) {
      final actions = await _syncQueue.list();
      final action = actions.first;
      try {
        switch (action.tipo) {
          case 'posicion':
            await _remoteDataSource.reportPosition(
              action.rutaId,
              action.lat ?? 0,
              action.lon ?? 0,
            );
          case 'completar':
            await _remoteDataSource.completeDelivery(
              action.rutaId,
              action.pedidoId ?? '',
            );
          default:
            return synced;
        }
        await _syncQueue.removeFirst();
        synced++;
      } on Failure catch (failure) {
        if (failure is NetworkFailure) return synced;
        await _syncQueue.removeFirst();
      } on DioException catch (e) {
        if (e.error is NoConnectionException) return synced;
        await _syncQueue.removeFirst();
      }
    }
    return synced;
  }

  int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  int _listLength(dynamic value) => value is List ? value.length : 0;
}
